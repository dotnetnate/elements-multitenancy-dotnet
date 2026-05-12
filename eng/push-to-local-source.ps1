<#
.SYNOPSIS
    Packs all packable projects in the solution and pushes the resulting
    NuGet packages to a local filesystem repository.

.PARAMETER Configuration
    Build configuration. Defaults to Release.

.PARAMETER Source
    NuGet source name. Defaults to dotnetnate-github-packages.

.PARAMETER NoBuild
    Skip building before packing (use when the solution is already built).

.EXAMPLE
    .\eng\pack-and-push.ps1
    .\eng\pack-and-push.ps1 -Configuration Debug
    .\eng\pack-and-push.ps1 -Source other-feed
#>
[CmdletBinding()]
param(
    [string] $Configuration = 'Release',
    [string] $Source = 'dotnetnate-github-packages',
    [switch] $NoBuild
)

Set-StrictMode -Version Latest
$ErrorActionPreference = "Stop"

$repoRoot = Split-Path -Parent $PSScriptRoot
$srcRoot = Join-Path $repoRoot "src"
$artifactsDir = Join-Path (Join-Path $repoRoot "artifacts") "packages"

# Ensure output directories exist
if (-not (Test-Path $artifactsDir)) {
    New-Item -ItemType Directory -Path $artifactsDir -Force | Out-Null
    Write-Host "Created artifacts directory: $artifactsDir"
}

if (-not (Test-Path $Source)) {
    New-Item -ItemType Directory -Path $Source -Force | Out-Null
    Write-Host "Created NuGet source directory: $Source"
}

# Clean previous artifacts
if (Test-Path $artifactsDir) {
    Get-ChildItem -Path $artifactsDir -Filter *.nupkg | Remove-Item -Force
    Get-ChildItem -Path $artifactsDir -Filter *.snupkg | Remove-Item -Force
}

# Discover all .csproj files under src/, excluding test projects and the Daemon
$allProjects = Get-ChildItem -Path $srcRoot -Filter *.csproj -Recurse |
    Where-Object { $_.FullName -notmatch '\.Tests\.' } |
    Where-Object { $_.FullName -notmatch 'samples' }

Write-Host ""
Write-Host "=== Packing $($allProjects.Count) project(s) ($Configuration) ==="  -ForegroundColor Cyan

$failedProjects = @()

foreach ($proj in $allProjects) {
    Write-Host "  Packing $($proj.Name)..."
    $packArgs = @(
        "pack", $proj.FullName,
        "--configuration", $Configuration,
        "--output", $artifactsDir
    )

    if ($NoBuild) {
        $packArgs += "--no-build"
    }

    & dotnet @packArgs
    if ($LASTEXITCODE -ne 0) {
        Write-Warning "  Failed to pack $($proj.Name) - skipping (IsPackable may be false)"
        $failedProjects += $proj.Name
    }
}

# Push
$packages = Get-ChildItem -Path $artifactsDir -Filter *.nupkg
if ($packages.Count -eq 0) {
    Write-Warning "No .nupkg files found in $artifactsDir - nothing to push."
    exit 0
}

Write-Host ""
Write-Host "=== Pushing $($packages.Count) package(s) to $Source ===" -ForegroundColor Cyan

foreach ($pkg in $packages) {
    Write-Host "  Pushing $($pkg.Name)..."
    & dotnet nuget push $pkg.FullName --source $Source --skip-duplicate
    if ($LASTEXITCODE -ne 0) {
        Write-Error "Failed to push $($pkg.Name)"
        exit $LASTEXITCODE
    }
}

Write-Host ""
Write-Host "=== Done - $($packages.Count) package(s) published to $Source ===" -ForegroundColor Green
