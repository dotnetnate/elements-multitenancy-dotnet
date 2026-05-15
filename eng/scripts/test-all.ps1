#!/usr/bin/env pwsh
<#
.SYNOPSIS
    Runs tests (optionally with code coverage) for a .slnx solution.

.PARAMETER Solution
    Path to a .slnx solution file. Defaults to ../src/full-solution.slnx.

.PARAMETER Coverage
    When set, collects code coverage and generates an HTML+markdown report.

.PARAMETER TestTypes
    One or more test categories to run, matched against the project name
    segment "Tests.<Type>" (e.g. Unit, Integration). Defaults to @("Unit").

.PARAMETER OutputDirectory
    Root directory for produced artifacts. Defaults to ../temp.
    Only these subdirectories are owned (cleaned/written):
      - test-results
      - reports/coverage
      - reports/benchmarks

.PARAMETER Build
    When $true (default), builds the solution before running tests.

.PARAMETER Clean
    When $true (default), removes owned output subdirectories before running.

.PARAMETER Configuration
    Build configuration. Defaults to Release.

.PARAMETER Open
    When set with -Coverage, opens the generated HTML report.

.NOTES
    The repo's global.json enables Microsoft.Testing.Platform (MTP) mode of
    `dotnet test`, so this script uses MTP CLI syntax (--project, --report-trx).
    Coverage is collected by wrapping `dotnet test` with `dotnet-coverage collect`,
    which honors the runsettings module/source filters across both runners.
#>
param(
    [string]$Solution,
    [switch]$Coverage,
    [string[]]$TestTypes = @("Unit"),
    [string]$OutputDirectory = "temp",
    [bool]$Build = $true,
    [bool]$Clean = $true,
    [string]$Configuration = "Release",
    [switch]$Open
)

$ErrorActionPreference = "Stop"
$RepoRoot = Split-Path (Split-Path $PSScriptRoot -Parent) -Parent
$SolutionRoot = Join-Path $RepoRoot "src"

if (-not $Solution) {
    $Solution = Join-Path $SolutionRoot "full-solution.slnx"
}
if (-not (Test-Path $Solution)) {
    Write-Host "BUILD FAILED: solution not found: $Solution" -ForegroundColor Red
    exit 1
}
$Solution = (Resolve-Path $Solution).Path
$SolutionDir = Split-Path $Solution -Parent

if (-not $OutputDirectory) {
    $OutputDirectory = Join-Path $RepoRoot "temp"
}
else {
    $OutputDirectory = Join-Path $RepoRoot $OutputDirectory
}
New-Item -ItemType Directory -Path $OutputDirectory -Force | Out-Null
$OutputDirectory = (Resolve-Path $OutputDirectory).Path

# Owned output subdirectories
$ResultsDir = Join-Path $OutputDirectory "test-results"
$ReportsRoot = Join-Path $OutputDirectory "reports"
$CoverageReport = Join-Path $ReportsRoot "coverage"
$BenchmarksReport = Join-Path $ReportsRoot "benchmarks"

$RunSettings = Join-Path $SolutionRoot "codecoverage.runsettings"

# Normalize requested test types — capitalize to match csproj naming
$normalizedTypes = $TestTypes |
ForEach-Object { $_.Trim() } |
Where-Object { $_ } |
ForEach-Object {
    $_.Substring(0, 1).ToUpperInvariant() + $_.Substring(1).ToLowerInvariant()
} |
Sort-Object -Unique

Write-Host "Solution         : $Solution"
Write-Host "Output directory : $OutputDirectory"
Write-Host "Test types       : $($normalizedTypes -join ', ')"
Write-Host "Coverage         : $Coverage"
Write-Host "Build            : $Build"
Write-Host "Clean            : $Clean"
Write-Host "Configuration    : $Configuration"

# ---------- Clean (owned subdirectories only) ----------
if ($Clean) {
    Write-Host "`n=== Cleaning owned output subdirectories ===" -ForegroundColor Cyan
    foreach ($d in @($ResultsDir, $CoverageReport, $BenchmarksReport)) {
        if (Test-Path $d) {
            Write-Host "  Removing $d" -ForegroundColor Gray
            Remove-Item $d -Recurse -Force
        }
    }
}
New-Item -ItemType Directory -Path $ResultsDir -Force | Out-Null

# ---------- Discover test projects from the solution ----------
Write-Host "`n=== Discovering test projects ===" -ForegroundColor Cyan
[xml]$slnXml = Get-Content -Raw -Path $Solution
$allProjects = $slnXml.SelectNodes("//Project") | ForEach-Object {
    $rel = $_.GetAttribute("Path")
    [pscustomobject]@{
        Path = (Join-Path $SolutionDir $rel)
        Name = [System.IO.Path]::GetFileNameWithoutExtension($rel)
    }
}

$testProjects = @()
foreach ($type in $normalizedTypes) {
    $pattern = "*.Tests.$type"
    $matched = $allProjects | Where-Object { $_.Name -like $pattern }
    $testProjects += $matched
}
$testProjects = $testProjects | Sort-Object -Property Path -Unique

if ($testProjects.Count -eq 0) {
    Write-Host "BUILD FAILED: no test projects matched test types: $($normalizedTypes -join ', ')" -ForegroundColor Red
    exit 1
}
Write-Host "  Matched $($testProjects.Count) project(s):"
$testProjects | ForEach-Object { Write-Host "    $($_.Name)" -ForegroundColor Gray }

# ---------- Tool verification (only when generating coverage) ----------
if ($Coverage) {
    Write-Host "`n=== Checking coverage tools ===" -ForegroundColor Cyan
    foreach ($tool in @("dotnet-coverage", "reportgenerator")) {
        if (-not (Get-Command $tool -ErrorAction SilentlyContinue)) {
            Write-Host "Installing $tool..." -ForegroundColor Yellow
            if ($tool -eq "reportgenerator") {
                dotnet tool install --global dotnet-reportgenerator-globaltool
            }
            else {
                dotnet tool install --global $tool
            }
        }
        Write-Host "  $tool -> $(Get-Command $tool -ErrorAction SilentlyContinue | Select-Object -ExpandProperty Source)" -ForegroundColor Gray
    }
}

# ---------- Build ----------
if ($Build) {
    Write-Host "`n=== Building ===" -ForegroundColor Cyan
    dotnet build $Solution -c $Configuration --nologo -v q
    if ($LASTEXITCODE -ne 0) {
        Write-Host "BUILD FAILED" -ForegroundColor Red
        exit 1
    }
}

# ---------- Run tests ----------
Write-Host "`n=== Running tests ===" -ForegroundColor Cyan
$testFailed = $false
$coverageOutputs = @()

foreach ($proj in $testProjects) {
    Write-Host "`n--- $($proj.Name) ---" -ForegroundColor Yellow

    # MTP-mode dotnet test CLI: --project / --report-trx / --results-directory
    # --ignore-exit-code 8 — MTP returns 8 when a project contains no executable tests.
    $dotnetTestArgs = @(
        "test",
        "--project", $proj.Path,
        "-c", $Configuration,
        "--report-trx",
        "--results-directory", $ResultsDir,
        "--ignore-exit-code", "8"
    )
    if (-not $Build) { $dotnetTestArgs += "--no-build" }

    if ($Coverage) {
        $covFile = Join-Path $ResultsDir "$($proj.Name).cobertura.xml"
        $coverageOutputs += $covFile
        & dotnet-coverage collect `
            --settings $RunSettings `
            --output-format cobertura `
            --output $covFile `
            -- dotnet @dotnetTestArgs
    }
    else {
        & dotnet @dotnetTestArgs
    }

    if ($LASTEXITCODE -ne 0) {
        Write-Host "  [exit $LASTEXITCODE] $($proj.Name)" -ForegroundColor Red
        $testFailed = $true
    }
}

if ($testFailed -and -not $Coverage) {
    Write-Host "`nBUILD FAILED: one or more test projects reported failures" -ForegroundColor Red
    exit 1
}
if ($testFailed) {
    Write-Warning "Some tests failed — continuing with coverage report"
}

# ---------- Coverage report ----------
if ($Coverage) {
    $existing = $coverageOutputs | Where-Object { Test-Path $_ }
    Write-Host "`n=== Merging coverage ===" -ForegroundColor Cyan
    Write-Host "  Cobertura files: $($existing.Count)"
    if ($existing.Count -eq 0) {
        Write-Host "BUILD FAILED: no coverage files produced" -ForegroundColor Red
        exit 1
    }

    New-Item -ItemType Directory -Path $CoverageReport -Force | Out-Null
    Write-Host "`n=== Generating HTML report ===" -ForegroundColor Cyan
    $reportsArg = "-reports:" + ($existing -join ";")
    reportgenerator `
        $reportsArg `
        "-targetdir:$CoverageReport" `
        "-reporttypes:Html;MarkdownSummaryGithub" `
        "-assemblyfilters:+*;-*.Tests.*;-FakeItEasy;-Castle.*" `
        "-verbosity:Info"
    if ($LASTEXITCODE -ne 0) {
        Write-Host "BUILD FAILED: report generation failed" -ForegroundColor Red
        exit 1
    }

    Write-Host "`nCoverage report: $(Join-Path $CoverageReport 'index.html')" -ForegroundColor Green
    if ($Open) { Start-Process (Join-Path $CoverageReport "index.html") }
}

Write-Host "`nDone." -ForegroundColor Green
exit 0
