#!/usr/bin/env pwsh
<#
.SYNOPSIS
    Aggregate a .NET workspace's public API into a cross-linked documentation tree.

.DESCRIPTION
    Drives the full doc-gen pipeline for a workspace folder:

      1. Discovers projects (or accepts an explicit manifest).
      2. Ensures the DocSurfaceScan tool is built.
      3. Determines which projects need regeneration:
         - If no prior state or -Force  -> regenerate all.
         - Else, diffs workspace HEAD against state.commit to find changed
           .cs / .csproj / docs.xml paths, maps to owning projects.
      4. For each project to regenerate:
            a. Runs DocSurfaceScan on the project source -> api-surface.json
            b. Runs normalize-dotnet.ps1 (surface + docs.xml) -> model.json
      5. Renders all models together so cross-references resolve.
      6. Writes the workspace README.
      7. Deletes stale generated pages no longer in the current surface.
      8. Persists new state: { commit, generatedAt }.
#>
[CmdletBinding()]
param(
    [Parameter(Mandatory)][string]$Workspace,
    [string]$OutputDir,
    [string]$Projects,
    [string[]]$Roots,
    [string]$XmlPattern = 'bin/docs/docs.xml',
    [string]$Style = 'msdn',
    [string]$Format = 'md',
    [switch]$Force,
    [string[]]$ProjectsOnly
)

$ErrorActionPreference = 'Stop'
Set-StrictMode -Version Latest

$scriptsDir = $PSScriptRoot
$agentRoot  = Split-Path -Parent $scriptsDir
$toolsDir   = Join-Path $agentRoot 'tools'
$surfaceProj = Join-Path $toolsDir 'DocSurfaceScan/DocSurfaceScan.csproj'
$surfaceDll  = Join-Path $toolsDir 'DocSurfaceScan/bin/Release/net10.0/docsurface.dll'

if (-not $OutputDir) { $OutputDir = Join-Path $Workspace 'docs' }
if (-not (Test-Path -LiteralPath $OutputDir)) { New-Item -ItemType Directory -Path $OutputDir -Force | Out-Null }
$OutputDir = (Resolve-Path -LiteralPath $OutputDir).Path
$Workspace = (Resolve-Path -LiteralPath $Workspace).Path
$statePath = Join-Path $OutputDir '.doc-gen-state.json'
$modelsDir = Join-Path $OutputDir '.doc-gen-models'
$surfaceDir = Join-Path $OutputDir '.doc-gen-surface'

# -------------------------------------------------------- Ensure surface tool

function Ensure-SurfaceTool {
    if (Test-Path -LiteralPath $surfaceDll) { return }
    Write-Host "building DocSurfaceScan..." -ForegroundColor DarkGray
    $buildOut = & dotnet build $surfaceProj -c Release -nologo --verbosity quiet 2>&1
    if ($LASTEXITCODE -ne 0) {
        throw "Failed to build DocSurfaceScan tool:`n$buildOut"
    }
    if (-not (Test-Path -LiteralPath $surfaceDll)) {
        throw "DocSurfaceScan built without producing $surfaceDll"
    }
}

Ensure-SurfaceTool

# -------------------------------------------------------- Resolve project list

if ($Projects) {
    $projectList = $Projects | ConvertFrom-Json -Depth 16
} else {
    if (-not $Roots -or $Roots.Count -eq 0) { $Roots = @($Workspace) }
    $json = & (Join-Path $scriptsDir 'discover-projects.ps1') -Folders $Roots -XmlPattern $XmlPattern
    $projectList = $json | ConvertFrom-Json -Depth 16
}
if (-not $projectList) { $projectList = @() }
$projectList = @($projectList | Where-Object { $_.type -eq 'dotnet' })

if ($ProjectsOnly -and $ProjectsOnly.Count -gt 0) {
    $projectList = @($projectList | Where-Object { $ProjectsOnly -contains $_.project })
}

# -------------------------------------------------------- Load state

$state = [pscustomobject]@{ commit = ''; generatedAt = '' }
if (Test-Path -LiteralPath $statePath) {
    try { $state = Get-Content -LiteralPath $statePath -Raw | ConvertFrom-Json }
    catch { $state = [pscustomobject]@{ commit = ''; generatedAt = '' } }
}
if (-not ($state.PSObject.Properties['commit']))      { $state | Add-Member -NotePropertyName commit      -NotePropertyValue '' -Force }
if (-not ($state.PSObject.Properties['generatedAt'])) { $state | Add-Member -NotePropertyName generatedAt -NotePropertyValue '' -Force }

# -------------------------------------------------------- Current HEAD

function Get-RepoHead([string]$Repo) {
    try {
        $h = & git -C $Repo rev-parse HEAD 2>$null
        if ($LASTEXITCODE -eq 0 -and $h) { return ($h | Out-String).Trim() }
    } catch { }
    return ''
}
$currentCommit = Get-RepoHead $Workspace

# -------------------------------------------------------- Determine what to regen

function Get-ChangedPaths([string]$Repo, [string]$FromCommit) {
    if (-not $FromCommit) { return @() }
    try {
        $out = & git -C $Repo diff --name-only "$FromCommit" HEAD 2>$null
        if ($LASTEXITCODE -ne 0) { return @() }
        # include untracked / working-tree changes too
        $status = & git -C $Repo status --porcelain 2>$null
        $wt = @()
        if ($LASTEXITCODE -eq 0 -and $status) {
            $wt = @($status | ForEach-Object { ($_ -replace '^.{3}', '').Trim() })
        }
        return @(@($out) + @($wt) | Where-Object { $_ })
    } catch {
        return @()
    }
}

$projectsToRegen = @()
if ($Force -or -not $state.commit) {
    $projectsToRegen = @($projectList)
} else {
    $changed = Get-ChangedPaths $Workspace $state.commit
    if ($changed.Count -eq 0) {
        $projectsToRegen = @()
    } else {
        # Map changed paths to projects by path-prefix containment.
        foreach ($p in $projectList) {
            $projRel = (Resolve-Path -LiteralPath $p.path).Path.Substring($Workspace.Length).TrimStart('\','/').Replace('\','/')
            foreach ($c in $changed) {
                $norm = $c -replace '\\','/'
                if ($norm -like "$projRel/*" -or $norm -eq $projRel) {
                    if ($projectsToRegen -notcontains $p) { $projectsToRegen += $p }
                    break
                }
            }
        }
        # Also regen anything whose model is missing.
        foreach ($p in $projectList) {
            $mp = Join-Path $modelsDir "$($p.project).json"
            if (-not (Test-Path -LiteralPath $mp) -and ($projectsToRegen -notcontains $p)) {
                $projectsToRegen += $p
            }
        }
    }
}

# -------------------------------------------------------- Run surface + normalize

if (-not (Test-Path -LiteralPath $modelsDir))  { New-Item -ItemType Directory -Path $modelsDir  -Force | Out-Null }
if (-not (Test-Path -LiteralPath $surfaceDir)) { New-Item -ItemType Directory -Path $surfaceDir -Force | Out-Null }

$statuses = [System.Collections.Generic.List[object]]::new()

foreach ($p in $projectList) {
    $shouldRegen = $projectsToRegen -contains $p
    if (-not $shouldRegen) {
        $statuses.Add([pscustomobject]@{ name = $p.project; status = 'skipped'; reason = 'no changes since last run' })
        continue
    }

    if (-not $p.xmlPath -or -not (Test-Path -LiteralPath $p.xmlPath)) {
        $statuses.Add([pscustomobject]@{ name = $p.project; status = 'failed'; reason = "xmlPath missing ($XmlPattern not found under $($p.path))" })
        continue
    }

    $surfacePath = Join-Path $surfaceDir "$($p.project).surface.json"
    $modelPath   = Join-Path $modelsDir  "$($p.project).json"

    # Surface scan
    try {
        $scanOut = & dotnet $surfaceDll --project $p.path --assembly-name $p.project --output $surfacePath 2>&1
        if ($LASTEXITCODE -ne 0) { throw ($scanOut -join "`n") }
    } catch {
        $statuses.Add([pscustomobject]@{ name = $p.project; status = 'failed'; reason = "surface scan: $($_.Exception.Message)" })
        continue
    }

    # Normalize
    try {
        & (Join-Path $scriptsDir 'normalize-dotnet.ps1') `
            -XmlPath $p.xmlPath `
            -SurfacePath $surfacePath `
            -Project $p.project `
            -OutputModel $modelPath | Out-Null
    } catch {
        $statuses.Add([pscustomobject]@{ name = $p.project; status = 'failed'; reason = "normalize: $($_.Exception.Message)" })
        continue
    }

    $statuses.Add([pscustomobject]@{ name = $p.project; status = ($(if ($Force) {'forced'} else {'generated'})); reason = $currentCommit })
}

# Build the render list from ALL projects that have a model (skipped projects
# still need to participate so xrefs from regen'd projects resolve).
$modelsToRender = @()
foreach ($p in $projectList) {
    $mp = Join-Path $modelsDir "$($p.project).json"
    if (Test-Path -LiteralPath $mp) { $modelsToRender += $mp }
}

# -------------------------------------------------------- Render

$renderResult = $null
if ($modelsToRender.Count -gt 0) {
    $renderResult = & (Join-Path $scriptsDir 'render.ps1') `
        -ModelPaths $modelsToRender `
        -Style $Style -Format $Format `
        -OutputDir $OutputDir -WriteProjectIndex | ConvertFrom-Json
}

# -------------------------------------------------------- Workspace README

function Get-Preferences {
    $prefPath = Join-Path $agentRoot 'preferences.yaml'
    if (-not (Test-Path -LiteralPath $prefPath)) { return @{} }
    $lines = Get-Content -LiteralPath $prefPath
    $h = @{}
    foreach ($l in $lines) {
        if ($l -match '^\s*([A-Za-z0-9_.]+)\s*:\s*(.+?)\s*$') {
            $val = $Matches[2] -replace '^"|"$','' -replace "^'|'$",''
            $h[$Matches[1]] = $val
        }
    }
    $h
}

$prefs = Get-Preferences
$workspaceName = Split-Path -Leaf $Workspace
$description = ''
if ($prefs.ContainsKey('workspaceDescription')) { $description = $prefs['workspaceDescription'] }

# Collect per-project facts for the workspace index.
$projectRows = @()
foreach ($p in $projectList) {
    $mp = Join-Path $modelsDir "$($p.project).json"
    $defaultNs = ''
    $assembly = ''
    $typeCount = 0
    $projSummary = ''
    if (Test-Path -LiteralPath $mp) {
        try {
            $m = Get-Content -LiteralPath $mp -Raw | ConvertFrom-Json -Depth 32
            if ($m.PSObject.Properties['defaultNamespace']) { $defaultNs = $m.defaultNamespace }
            if ($m.PSObject.Properties['assembly']) { $assembly = $m.assembly }
            $typeKinds = @('class','interface','struct','record','record struct','enum','delegate')
            $typeCount = @($m.elements | Where-Object { $typeKinds -contains $_.kind }).Count
        } catch { }
    }
    $projectRows += [pscustomobject]@{
        name             = $p.project
        href             = "$($p.project -replace '[\\/:*?"|]','_')/README.$Format"
        assembly         = $assembly
        defaultNamespace = $defaultNs
        typeCount        = $typeCount
        summary          = $projSummary
    }
}

# Compute a common default namespace across the whole workspace.
function Get-CommonPrefix([string[]]$items) {
    $items = @($items | Where-Object { $_ })
    if ($items.Count -eq 0) { return '' }
    $parts = @($items[0] -split '\.')
    for ($i = 1; $i -lt $items.Count; $i++) {
        $p = @($items[$i] -split '\.')
        $max = [Math]::Min($parts.Count, $p.Count)
        $k = 0
        while ($k -lt $max -and $parts[$k] -eq $p[$k]) { $k++ }
        $parts = $parts[0..($k-1)]
        if ($parts.Count -eq 0) { break }
    }
    if (-not $parts) { return '' }
    ($parts -join '.')
}

$workspaceDefaultNs = Get-CommonPrefix (@($projectRows | ForEach-Object { $_.defaultNamespace }))
$generatedAt = (Get-Date).ToUniversalTime().ToString('o')

$rmdLines = @()
$rmdLines += "# $workspaceName API Reference"
$rmdLines += ''
if ($description) {
    $rmdLines += $description
    $rmdLines += ''
}
$rmdLines += "_Generated: $generatedAt"
$rmdLines += ''
$rmdLines += '## Overview'
$rmdLines += ''
if ($workspaceDefaultNs) {
    $rmdLines += "- **Default namespace**: ``$workspaceDefaultNs``"
}
$rmdLines += "- **Assemblies**: $($projectRows.Count)"
$rmdLines += ''
$rmdLines += '## Assemblies'
$rmdLines += ''
$rmdLines += '| Assembly | Default Namespace | Types | Description |'
$rmdLines += '|---|---|--:|---|'
foreach ($row in $projectRows) {
    $asm = if ($row.assembly) { "``$($row.assembly)``" } else { "``$($row.name)``" }
    $ns  = if ($row.defaultNamespace) { "``$($row.defaultNamespace)``" } else { '' }
    $rmdLines += "| [$($row.name)]($($row.href)) | $ns | $($row.typeCount) | $($row.summary) |"
}
$rmdLines += ''
Set-Content -LiteralPath (Join-Path $OutputDir "README.$Format") -Value ($rmdLines -join "`n") -Encoding UTF8

# -------------------------------------------------------- Delete stale pages

# Consider only files with our generation marker.
$marker = '<!-- doc-gen -->'
$seenFiles = @{}
if ($renderResult -and $renderResult.PSObject.Properties['writtenFiles']) {
    foreach ($f in $renderResult.writtenFiles) { $seenFiles[$f.Replace('\','/')] = $true }
}
# Also mark README as seen.
$seenFiles["README.$Format"] = $true

$staleDeleted = 0
if ($seenFiles.Count -gt 0) {
    Get-ChildItem -LiteralPath $OutputDir -Recurse -File -Filter "*.$Format" | ForEach-Object {
        $rel = $_.FullName.Substring($OutputDir.Length).TrimStart('\','/').Replace('\','/')
        if ($seenFiles.ContainsKey($rel)) { return }
        # Only delete files written by doc-gen (marker in first few lines).
        try {
            $head = Get-Content -LiteralPath $_.FullName -TotalCount 3 -ErrorAction Stop
            if (($head -join "`n") -match [regex]::Escape($marker)) {
                Remove-Item -LiteralPath $_.FullName -Force
                $staleDeleted++
            }
        } catch { }
    }
}

# -------------------------------------------------------- Persist state

$newState = [pscustomobject]@{
    commit      = $currentCommit
    generatedAt = $generatedAt
}
$newState | ConvertTo-Json | Set-Content -LiteralPath $statePath -Encoding UTF8

# -------------------------------------------------------- Summary

$totals = [pscustomobject]@{
    generated = @($statuses | Where-Object { $_.status -eq 'generated' }).Count
    skipped   = @($statuses | Where-Object { $_.status -eq 'skipped' }).Count
    forced    = @($statuses | Where-Object { $_.status -eq 'forced' }).Count
    failed    = @($statuses | Where-Object { $_.status -eq 'failed' }).Count
    staleDeleted = $staleDeleted
}

[pscustomobject]@{
    output   = $OutputDir
    commit   = $currentCommit
    projects = $statuses
    totals   = $totals
    render   = $renderResult
} | ConvertTo-Json -Depth 16


