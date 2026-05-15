#Requires -Version 7
# discover-projects.ps1 <folder> [<folder> ...]
# Walks each folder, prunes well-known noise dirs, and emits a JSON array:
# [{path, type, tool, manifest, projectCount}, ...]
#
# projectCount is set for .NET sln entries to show how many .csproj/.fsproj
# files exist under that solution folder — auditing runs at the sln level but
# the count reflects the true scope.

. "$PSScriptRoot/_lib.ps1"

if ($args.Count -lt 1) { Exit-Fail "usage: discover-projects.ps1 <folder> [<folder> ...]" }

$PruneDirs = @('node_modules','.git','bin','obj','target','build','dist','.venv','venv','.tox','.gradle','out','.idea','.vs','.angular','__pycache__','.pytest_cache','coverage')

function Get-FilesRecursive {
    param([string]$Root, [string]$Pattern)
    Get-ChildItem -LiteralPath $Root -Recurse -File -Filter $Pattern -ErrorAction SilentlyContinue |
        Where-Object {
            $parts = $_.FullName.Replace('\','/').Split('/')
            $inPrune = $false
            foreach ($seg in $parts | Select-Object -SkipLast 1) {
                if ($PruneDirs -contains $seg) { $inPrune = $true; break }
            }
            -not $inPrune
        } |
        Select-Object -ExpandProperty FullName
}

# Check whether $candidate is the same as or under any path in $Parents
function Test-UnderAny {
    param([string]$Candidate, [string[]]$Parents)
    foreach ($p in $Parents) {
        if ($Candidate -eq $p -or $Candidate.StartsWith("$p$([IO.Path]::DirectorySeparatorChar)") -or $Candidate.StartsWith("$p/")) {
            return $true
        }
    }
    return $false
}

$projects = [System.Collections.Generic.List[hashtable]]::new()

function Add-Project {
    param([string]$Path, [string]$Type, [string]$Tool, [string]$Manifest, [int]$ProjectCount = -1)
    $entry = [ordered]@{
        path     = $Path
        type     = $Type
        tool     = $Tool
        manifest = $Manifest
    }
    if ($ProjectCount -ge 0) { $entry['projectCount'] = $ProjectCount }
    $projects.Add($entry)
}

function Scan-Root {
    param([string]$RawRoot)

    $root = Resolve-AbsPath $RawRoot
    if ([string]::IsNullOrEmpty($root) -or -not (Test-Path $root -PathType Container)) {
        Write-Error "refresh-deps: discover: skipping $RawRoot — not found"
        return
    }

    # Collect manifests by type
    $slnFiles     = Get-FilesRecursive $root '*.sln'
    $csprojFiles  = Get-FilesRecursive $root '*.csproj'
    $fsprojFiles  = Get-FilesRecursive $root '*.fsproj'
    $vbprojFiles  = Get-FilesRecursive $root '*.vbproj'
    $pkgJsonFiles = Get-FilesRecursive $root 'package.json'
    $pomFiles     = Get-FilesRecursive $root 'pom.xml'
    $gradleFiles  = @(Get-FilesRecursive $root 'build.gradle') + @(Get-FilesRecursive $root 'build.gradle.kts')
    $pyprojectFiles = Get-FilesRecursive $root 'pyproject.toml'
    $reqsFiles    = Get-FilesRecursive $root 'requirements*.txt'
    $uvLockFiles  = Get-FilesRecursive $root 'uv.lock'
    $poetryLocks  = Get-FilesRecursive $root 'poetry.lock'

    # ── .NET ────────────────────────────────────────────────────────────────
    $dotnetRoots = [System.Collections.Generic.List[string]]::new()

    foreach ($f in $slnFiles) {
        $dir = Split-Path $f -Parent
        # Count all project files under this sln folder to show true scope
        $allProj = @($csprojFiles) + @($fsprojFiles) + @($vbprojFiles) |
            Where-Object { $_ -and $_.StartsWith($dir) }
        $count = ($allProj | Measure-Object).Count
        Add-Project -Path $dir -Type 'dotnet' -Tool 'dotnet' `
                    -Manifest (Split-Path $f -Leaf) -ProjectCount $count
        $dotnetRoots.Add($dir)
    }

    # Orphan project files not covered by any sln
    foreach ($f in (@($csprojFiles) + @($fsprojFiles) + @($vbprojFiles))) {
        if (-not $f) { continue }
        $dir = Split-Path $f -Parent
        if (Test-UnderAny $dir $dotnetRoots.ToArray()) { continue }
        Add-Project -Path $dir -Type 'dotnet' -Tool 'dotnet' `
                    -Manifest (Split-Path $f -Leaf) -ProjectCount 1
        $dotnetRoots.Add($dir)
    }

    # ── Node (npm / pnpm / yarn) ─────────────────────────────────────────
    foreach ($f in $pkgJsonFiles) {
        if (-not $f) { continue }
        $dir = Split-Path $f -Parent
        if (Test-Path (Join-Path $dir 'pnpm-lock.yaml') -PathType Leaf) {
            Add-Project -Path $dir -Type 'pnpm' -Tool 'pnpm' -Manifest 'package.json'
        } elseif (Test-Path (Join-Path $dir 'yarn.lock') -PathType Leaf) {
            Add-Project -Path $dir -Type 'yarn' -Tool 'yarn' -Manifest 'package.json'
        } else {
            Add-Project -Path $dir -Type 'npm'  -Tool 'npm'  -Manifest 'package.json'
        }
    }

    # ── Python ──────────────────────────────────────────────────────────
    $pyRoots = [System.Collections.Generic.List[string]]::new()
    foreach ($f in $pyprojectFiles) {
        if (-not $f) { continue }
        $dir  = Split-Path $f -Parent
        $text = Get-Content $f -Raw -ErrorAction SilentlyContinue
        if ($text -match '\[tool\.poetry' -or (Test-Path (Join-Path $dir 'poetry.lock') -PathType Leaf)) {
            Add-Project -Path $dir -Type 'python-poetry' -Tool 'poetry' -Manifest 'pyproject.toml'
            $pyRoots.Add($dir)
        } elseif ($text -match '\[tool\.uv' -or (Test-Path (Join-Path $dir 'uv.lock') -PathType Leaf)) {
            Add-Project -Path $dir -Type 'python-uv' -Tool 'uv' -Manifest 'pyproject.toml'
            $pyRoots.Add($dir)
        }
    }
    foreach ($f in $uvLockFiles) {
        if (-not $f) { continue }
        $dir = Split-Path $f -Parent
        if (Test-UnderAny $dir $pyRoots.ToArray()) { continue }
        Add-Project -Path $dir -Type 'python-uv' -Tool 'uv' -Manifest 'uv.lock'
        $pyRoots.Add($dir)
    }
    foreach ($f in $poetryLocks) {
        if (-not $f) { continue }
        $dir = Split-Path $f -Parent
        if (Test-UnderAny $dir $pyRoots.ToArray()) { continue }
        Add-Project -Path $dir -Type 'python-poetry' -Tool 'poetry' -Manifest 'poetry.lock'
        $pyRoots.Add($dir)
    }
    foreach ($f in $reqsFiles) {
        if (-not $f) { continue }
        $dir = Split-Path $f -Parent
        if (Test-UnderAny $dir $pyRoots.ToArray()) { continue }
        Add-Project -Path $dir -Type 'python-pip' -Tool 'pip' `
                    -Manifest (Split-Path $f -Leaf)
        $pyRoots.Add($dir)
    }

    # ── Maven (topmost pom.xml per subtree) ─────────────────────────────
    $mvnRoots = [System.Collections.Generic.List[string]]::new()
    $sortedPoms = $pomFiles | Where-Object { $_ } |
        Sort-Object { ($_ -replace '\\','/').Split('/').Count }
    foreach ($f in $sortedPoms) {
        $dir = Split-Path $f -Parent
        if (Test-UnderAny $dir $mvnRoots.ToArray()) { continue }
        Add-Project -Path $dir -Type 'maven' -Tool 'mvn' -Manifest 'pom.xml'
        $mvnRoots.Add($dir)
    }

    # ── Gradle (topmost build file per subtree) ──────────────────────────
    $grdRoots = [System.Collections.Generic.List[string]]::new()
    $sortedGradle = $gradleFiles | Where-Object { $_ } |
        Sort-Object { ($_ -replace '\\','/').Split('/').Count }
    foreach ($f in $sortedGradle) {
        $dir = Split-Path $f -Parent
        if (Test-UnderAny $dir $grdRoots.ToArray()) { continue }
        Add-Project -Path $dir -Type 'gradle' -Tool 'gradle' `
                    -Manifest (Split-Path $f -Leaf)
        $grdRoots.Add($dir)
    }
}

foreach ($folder in $args) {
    Scan-Root -RawRoot $folder
}

Write-Output ($projects.ToArray() | ConvertTo-Json -Compress -Depth 5)
