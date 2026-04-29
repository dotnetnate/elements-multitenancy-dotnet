#!/usr/bin/env pwsh
# Local coverage pipeline — mirrors the CI workflow for validation.
# Usage: .\eng\test-coverage.ps1
# Output: .\coverage-report\index.html

param(
    [string]$Configuration = "Release",
    [switch]$Open
)

$ErrorActionPreference = "Stop"
$RepoRoot = Split-Path $PSScriptRoot -Parent
$SolutionRoot = Join-Path $RepoRoot "src"
$Solution = Join-Path $SolutionRoot "src.sln"
$ResultsDir = Join-Path $RepoRoot "test-results"
$ReportDir = Join-Path $RepoRoot "coverage-report"
$RunSettings = Join-Path $SolutionRoot "codecoverage.runsettings"

# ---------- Clean ----------
Write-Host "`n=== Cleaning previous results ===" -ForegroundColor Cyan
if (Test-Path $ResultsDir) { Remove-Item $ResultsDir -Recurse -Force }
if (Test-Path $ReportDir)  { Remove-Item $ReportDir  -Recurse -Force }
New-Item -ItemType Directory -Path $ResultsDir -Force | Out-Null

# ---------- Verify tools ----------
Write-Host "`n=== Checking tools ===" -ForegroundColor Cyan
foreach ($tool in @("dotnet-coverage", "reportgenerator")) {
    if (-not (Get-Command $tool -ErrorAction SilentlyContinue)) {
        Write-Host "Installing $tool..." -ForegroundColor Yellow
        if ($tool -eq "reportgenerator") {
            dotnet tool install --global dotnet-reportgenerator-globaltool
        } else {
            dotnet tool install --global $tool
        }
    }
    Write-Host "  $tool -> $(Get-Command $tool -ErrorAction SilentlyContinue | Select-Object -ExpandProperty Source)" -ForegroundColor Gray
}

# ---------- Build ----------
Write-Host "`n=== Building ===" -ForegroundColor Cyan
dotnet build $Solution -c $Configuration --nologo -v q
if ($LASTEXITCODE -ne 0) { throw "Build failed" }

# ---------- Test + Coverage ----------
# Data collector writes binary .coverage files; dotnet-coverage merge
# converts them to cobertura XML for ReportGenerator.
Write-Host "`n=== Running tests with coverage ===" -ForegroundColor Cyan
dotnet test $Solution `
    --no-build -c $Configuration `
    --collect "Code Coverage" `
    --settings $RunSettings `
    --logger trx `
    --results-directory $ResultsDir

if ($LASTEXITCODE -ne 0) {
    Write-Warning "Some tests may have failed — continuing with coverage report"
}

# ---------- Merge to Cobertura ----------
Write-Host "`n=== Merging coverage to cobertura ===" -ForegroundColor Cyan
$coverageFiles = Get-ChildItem $ResultsDir -Filter "*.coverage" -Recurse
Write-Host "  Binary .coverage files found: $($coverageFiles.Count)"
foreach ($f in $coverageFiles) {
    Write-Host "    $($f.FullName) ($($f.Length) bytes)" -ForegroundColor Gray
}

if ($coverageFiles.Count -eq 0) {
    Write-Error "No .coverage files found — data collector did not produce output!"
    Get-ChildItem $ResultsDir -Recurse | ForEach-Object { Write-Host "  $($_.FullName)" }
    exit 1
}

$CoberturaFile = Join-Path $ResultsDir "coverage.cobertura.xml"
$coveragePaths = $coverageFiles | ForEach-Object { $_.FullName }
& dotnet-coverage merge --output-format cobertura --output $CoberturaFile @coveragePaths

$cobInfo = Get-Item $CoberturaFile
Write-Host "  Cobertura: $CoberturaFile ($($cobInfo.Length) bytes)"

if ($cobInfo.Length -lt 300) {
    Write-Warning "Cobertura file is suspiciously small — may be empty"
    Get-Content $CoberturaFile | Select-Object -First 5
}

# ---------- Generate Report ----------
Write-Host "`n=== Generating HTML report ===" -ForegroundColor Cyan
reportgenerator `
    "-reports:$CoberturaFile" `
    "-targetdir:$ReportDir" `
    "-reporttypes:Html;MarkdownSummaryGithub" `
    "-assemblyfilters:+*;-*.Tests.*" `
    "-verbosity:Info"

if ($LASTEXITCODE -ne 0) { throw "Report generation failed" }

# ---------- Summary ----------
Write-Host "`n=== TRX files ===" -ForegroundColor Cyan
Get-ChildItem $ResultsDir -Filter "*.trx" -Recurse | ForEach-Object { Write-Host "  $($_.FullName)" }

$reportIndex = Join-Path $ReportDir "index.html"
Write-Host "`n=== Done ===" -ForegroundColor Green
Write-Host "Report: $reportIndex"

if ($Open -or $Host.UI.PromptForChoice("Open report?", "Open the coverage report in your browser?", @("&Yes","&No"), 0) -eq 0) {
    Start-Process $reportIndex
}
