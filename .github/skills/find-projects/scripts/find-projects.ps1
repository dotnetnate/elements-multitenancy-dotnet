<#
.SYNOPSIS
    Enumerate buildable projects across one or more roots.

.DESCRIPTION
    Walks each root and locates project manifest files, mapping each to a
    canonical "project type" label. Supports VS Code workspaces, IntelliJ
    projects, and explicit paths. Cross-platform via PowerShell Core.

.PARAMETER Roots
    One or more directory or file paths. A file path resolves to its parent
    directory unless it's a workspace descriptor (.code-workspace, .idea,
    .iml). Required unless -Workspace is supplied.

.PARAMETER Workspace
    Auto-detect VS Code or IntelliJ workspace from the current directory
    upward. See SKILL.md for resolution rules.

.PARAMETER Languages
    Optional list of language IDs to filter results: dotnet, nodejs,
    python, java, kotlin, go, rust, ruby, php. Default: all.

.PARAMETER MaxDepth
    Maximum recursion depth from each root. Default: 8.

.PARAMETER IncludeIgnored
    When set, skip the standard ignore-list pruning and walk node_modules,
    bin, obj, .venv, target, dist, build, .git, .idea, .vs, out.

.PARAMETER Format
    Output format: 'table' (default markdown), 'json', 'csv'.

.EXAMPLE
    pwsh find-projects.ps1 -Roots l:\repos\entitlements,l:\repos\swarm

.EXAMPLE
    pwsh find-projects.ps1 -Workspace -Languages dotnet,nodejs -Format json
#>
[CmdletBinding()]
param(
    [Parameter(Position = 0)]
    [string[]] $Roots,

    [switch] $Workspace,

    [string[]] $Languages,

    [int] $MaxDepth = 8,

    [switch] $IncludeIgnored,

    [ValidateSet('table', 'json', 'csv')]
    [string] $Format = 'table'
)

$ErrorActionPreference = 'Stop'

# ----- Detection table ---------------------------------------------------

# Each entry: pattern (file name or wildcard), language id, type label.
$detectionTable = @(
    @{ Pattern = '*.csproj';            Language = 'dotnet'; Type = '.NET'                       },
    @{ Pattern = '*.fsproj';            Language = 'dotnet'; Type = '.NET'                       },
    @{ Pattern = '*.vbproj';            Language = 'dotnet'; Type = '.NET'                       },
    @{ Pattern = '*.sln';               Language = 'dotnet'; Type = '.NET (Solution)'            },
    @{ Pattern = 'package.json';        Language = 'nodejs'; Type = 'Node.js'                    },
    @{ Pattern = 'pyproject.toml';      Language = 'python'; Type = 'Python'                     },
    @{ Pattern = 'requirements.txt';    Language = 'python'; Type = 'Python (legacy)'            },
    @{ Pattern = 'pom.xml';             Language = 'java';   Type = 'Java (Maven)'               },
    @{ Pattern = 'build.gradle';        Language = 'java';   Type = 'Java/Kotlin (Gradle)'       },
    @{ Pattern = 'build.gradle.kts';    Language = 'kotlin'; Type = 'Java/Kotlin (Gradle)'       },
    @{ Pattern = 'settings.gradle';     Language = 'java';   Type = 'Java/Kotlin (Gradle)'       },
    @{ Pattern = 'settings.gradle.kts'; Language = 'kotlin'; Type = 'Java/Kotlin (Gradle)'       },
    @{ Pattern = 'Cargo.toml';          Language = 'rust';   Type = 'Rust'                       },
    @{ Pattern = 'go.mod';              Language = 'go';     Type = 'Go'                         },
    @{ Pattern = 'Gemfile';             Language = 'ruby';   Type = 'Ruby'                       },
    @{ Pattern = 'composer.json';       Language = 'php';    Type = 'PHP'                        }
)

$ignoredDirs = @(
    'node_modules', 'bin', 'obj', '.venv', 'venv', '__pycache__',
    'target', 'dist', 'build', '.git', '.idea', '.vs', 'out',
    '.gradle', '.next', '.nuxt'
)

# ----- Root resolution ---------------------------------------------------

function Resolve-VSCodeWorkspace {
    param([string] $StartDir)
    $dir = Resolve-Path -LiteralPath $StartDir
    while ($null -ne $dir) {
        $candidates = Get-ChildItem -LiteralPath $dir -Filter '*.code-workspace' -File -ErrorAction SilentlyContinue
        if ($candidates) {
            $ws = Get-Content -Raw -LiteralPath $candidates[0].FullName | ConvertFrom-Json
            if ($ws.folders) {
                return @($ws.folders | ForEach-Object {
                    $p = $_.path
                    if (-not [System.IO.Path]::IsPathRooted($p)) {
                        $p = Join-Path $candidates[0].DirectoryName $p
                    }
                    (Resolve-Path -LiteralPath $p -ErrorAction SilentlyContinue)?.Path
                } | Where-Object { $_ })
            }
        }
        $parent = Split-Path -Parent $dir
        if (-not $parent -or $parent -eq $dir) { break }
        $dir = $parent
    }
    return @()
}

function Resolve-IntelliJWorkspace {
    param([string] $StartDir)
    $dir = Resolve-Path -LiteralPath $StartDir
    while ($null -ne $dir) {
        $idea = Join-Path $dir '.idea'
        if (Test-Path -LiteralPath $idea -PathType Container) {
            $modulesXml = Join-Path $idea 'modules.xml'
            $roots = @()
            if (Test-Path -LiteralPath $modulesXml) {
                try {
                    [xml] $xml = Get-Content -LiteralPath $modulesXml -Raw
                    foreach ($m in $xml.SelectNodes('//module')) {
                        $url = $m.fileurl
                        if ($url -and $url -match 'file://\$PROJECT_DIR\$/?(.*)') {
                            $rel = $matches[1] -replace '/[^/]+\.iml$', ''
                            $abs = if ($rel) { Join-Path $dir $rel } else { $dir }
                            $resolved = (Resolve-Path -LiteralPath $abs -ErrorAction SilentlyContinue)?.Path
                            if ($resolved) { $roots += $resolved }
                        }
                    }
                } catch { }
            }
            if (-not $roots) {
                # Fallback: directories of any *.iml files at or below .idea's parent
                $imls = Get-ChildItem -LiteralPath $dir -Filter '*.iml' -Recurse -File -ErrorAction SilentlyContinue -Depth 3
                $roots = $imls | ForEach-Object { $_.DirectoryName } | Sort-Object -Unique
            }
            if (-not $roots) { $roots = @($dir.Path) }
            return $roots
        }
        $parent = Split-Path -Parent $dir
        if (-not $parent -or $parent -eq $dir) { break }
        $dir = $parent
    }
    return @()
}

function Resolve-Roots {
    param([string[]] $InputRoots, [switch] $UseWorkspace)

    $resolved = New-Object System.Collections.Generic.List[string]

    function Add-Range {
        param($List, $Items)
        if ($null -eq $Items) { return }
        foreach ($it in $Items) { if ($it) { [void] $List.Add($it) } }
    }

    if ($InputRoots) {
        foreach ($r in $InputRoots) {
            if (-not (Test-Path -LiteralPath $r)) {
                Write-Warning "Path not found: $r"
                continue
            }
            $item = Get-Item -LiteralPath $r
            if ($item.PSIsContainer) {
                if ($item.Name -eq '.idea') {
                    Add-Range $resolved (Resolve-IntelliJWorkspace -StartDir $item.Parent.FullName)
                } else {
                    [void] $resolved.Add($item.FullName)
                }
            } else {
                if ($item.Extension -eq '.code-workspace') {
                    Add-Range $resolved (Resolve-VSCodeWorkspace -StartDir $item.DirectoryName)
                } elseif ($item.Extension -eq '.iml') {
                    [void] $resolved.Add($item.DirectoryName)
                } else {
                    [void] $resolved.Add($item.DirectoryName)
                }
            }
        }
    } elseif ($UseWorkspace -or -not $InputRoots) {
        $cwd = (Get-Location).Path
        $vs = Resolve-VSCodeWorkspace -StartDir $cwd
        if ($vs) {
            Add-Range $resolved $vs
        } else {
            $ij = Resolve-IntelliJWorkspace -StartDir $cwd
            if ($ij) {
                Add-Range $resolved $ij
            } else {
                [void] $resolved.Add($cwd)
            }
        }
    }

    return ($resolved | Where-Object { $_ } | Sort-Object -Unique)
}

# ----- Walk ---------------------------------------------------------------

function Walk-Root {
    param([string] $Root, [int] $MaxDepth, [bool] $IncludeIgnored, [string[]] $LangFilter)

    $results = New-Object System.Collections.Generic.List[psobject]
    $rootInfo = Get-Item -LiteralPath $Root
    $rootFull = $rootInfo.FullName.TrimEnd([System.IO.Path]::DirectorySeparatorChar)

    $stack = New-Object System.Collections.Generic.Stack[psobject]
    $stack.Push([pscustomobject]@{ Dir = $rootFull; Depth = 0 })

    while ($stack.Count -gt 0) {
        $current = $stack.Pop()
        if ($current.Depth -gt $MaxDepth) { continue }

        $entries = $null
        try {
            $entries = Get-ChildItem -LiteralPath $current.Dir -Force -ErrorAction Stop
        } catch { continue }

        # Files in this dir
        foreach ($entry in $entries | Where-Object { -not $_.PSIsContainer }) {
            foreach ($det in $detectionTable) {
                if ($entry.Name -like $det.Pattern) {
                    if ($LangFilter -and ($LangFilter -notcontains $det.Language)) { continue }

                    # Special case: requirements.txt is suppressed if pyproject.toml sits beside it
                    if ($entry.Name -eq 'requirements.txt') {
                        $sibling = Join-Path $current.Dir 'pyproject.toml'
                        if (Test-Path -LiteralPath $sibling) { continue }
                    }

                    $results.Add([pscustomobject]@{
                        Path     = $entry.FullName
                        Type     = $det.Type
                        Language = $det.Language
                        Repo     = $rootFull
                    })
                    break
                }
            }
        }

        # Recurse subdirs
        foreach ($entry in $entries | Where-Object { $_.PSIsContainer }) {
            if (-not $IncludeIgnored -and ($ignoredDirs -contains $entry.Name)) { continue }
            $stack.Push([pscustomobject]@{ Dir = $entry.FullName; Depth = $current.Depth + 1 })
        }
    }

    return $results
}

# ----- Main ---------------------------------------------------------------

$resolvedRoots = Resolve-Roots -InputRoots $Roots -UseWorkspace:$Workspace

if (-not $resolvedRoots -or $resolvedRoots.Count -eq 0) {
    Write-Error 'No roots could be resolved. Pass -Roots <path> or -Workspace.'
    exit 1
}

$langFilter = if ($Languages) { $Languages | ForEach-Object { $_.ToLowerInvariant() } } else { $null }

$all = New-Object System.Collections.Generic.List[psobject]
foreach ($root in $resolvedRoots) {
    $found = Walk-Root -Root $root -MaxDepth $MaxDepth -IncludeIgnored $IncludeIgnored.IsPresent -LangFilter $langFilter
    if ($found) { foreach ($p in $found) { $all.Add($p) } }
}

$sorted = $all | Sort-Object Path

$multiRoot = $resolvedRoots.Count -gt 1

switch ($Format) {
    'json' {
        if (-not $multiRoot) {
            $sorted | ForEach-Object {
                [pscustomobject]@{ path = $_.Path; type = $_.Type; language = $_.Language }
            } | ConvertTo-Json -Depth 4
        } else {
            $sorted | ForEach-Object {
                [pscustomobject]@{ path = $_.Path; type = $_.Type; language = $_.Language; repo = $_.Repo }
            } | ConvertTo-Json -Depth 4
        }
    }
    'csv' {
        if ($multiRoot) {
            'path,type,language,repo'
            $sorted | ForEach-Object { '{0},{1},{2},{3}' -f $_.Path, $_.Type, $_.Language, $_.Repo }
        } else {
            'path,type,language'
            $sorted | ForEach-Object { '{0},{1},{2}' -f $_.Path, $_.Type, $_.Language }
        }
    }
    default {
        if (-not $sorted -or $sorted.Count -eq 0) {
            Write-Output ('No projects found under {0}.' -f ($resolvedRoots -join ', '))
            return
        }
        if ($multiRoot) {
            Write-Output '| Repo | Path | Project Type |'
            Write-Output '|---|---|---|'
            foreach ($row in $sorted) {
                $repoName = Split-Path -Leaf $row.Repo
                Write-Output ('| {0} | {1} | {2} |' -f $repoName, $row.Path, $row.Type)
            }
        } else {
            Write-Output '| Path | Project Type |'
            Write-Output '|---|---|'
            foreach ($row in $sorted) {
                Write-Output ('| {0} | {1} |' -f $row.Path, $row.Type)
            }
        }
    }
}
