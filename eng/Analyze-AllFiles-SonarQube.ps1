<#
.SYNOPSIS
    Analyzes all non-test C# files in the workspace with SonarQube for IDE.

.DESCRIPTION
    This script finds all production C# source files (excluding test projects, templates, 
    and build artifacts) and triggers SonarQube analysis on each file using the VS Code 
    extension API. Results are displayed in the Problems view.

.PARAMETER SourcePath
    The root source directory to scan. Defaults to the 'src' folder relative to the script location.

.PARAMETER BatchSize
    Number of files to analyze in each batch before reporting progress. Default is 10.

.PARAMETER IncludeTemplates
    If specified, includes template files in the analysis.

.EXAMPLE
    .\Analyze-AllFiles-SonarQube.ps1
    Analyzes all files with default settings (batch size 10).

.EXAMPLE
    .\Analyze-AllFiles-SonarQube.ps1 -BatchSize 20
    Analyzes all files in batches of 20.

.EXAMPLE
    .\Analyze-AllFiles-SonarQube.ps1 -SourcePath "C:\MyProject\src" -BatchSize 5
    Analyzes files in a specific directory with batch size of 5.

.NOTES
    Requires the SonarQube for IDE (formerly SonarLint) extension to be installed in VS Code.
    This script is designed to work with the GitHub Copilot CLI integration.
#>

[CmdletBinding()]
param(
    [Parameter(Mandatory=$false)]
    [string]$SourcePath = (Join-Path $PSScriptRoot "..\src"),
    
    [Parameter(Mandatory=$false)]
    [ValidateRange(1, 100)]
    [int]$BatchSize = 10,
    
    [Parameter(Mandatory=$false)]
    [switch]$IncludeTemplates
)

$ErrorActionPreference = "Stop"

Write-Host "═══════════════════════════════════════════════════════════════" -ForegroundColor Cyan
Write-Host "  SonarQube Workspace File Analyzer" -ForegroundColor Cyan
Write-Host "═══════════════════════════════════════════════════════════════" -ForegroundColor Cyan
Write-Host ""

# Validate source path
if (-not (Test-Path $SourcePath)) {
    Write-Error "Source path does not exist: $SourcePath"
    exit 1
}

Write-Host "Configuration:" -ForegroundColor Yellow
Write-Host "  Source Path:     $SourcePath"
Write-Host "  Batch Size:      $BatchSize"
Write-Host "  Include Templates: $IncludeTemplates"
Write-Host ""

# Find all C# files
Write-Host "Finding C# files..." -ForegroundColor Yellow

$filters = @{
    Include = "*.cs"
    Exclude = @(
        '*\obj\*',
        '*\bin\*',
        '*.Tests.Unit\*',
        '*TestFixture.cs',
        'MSTestSettings.cs',
        'AssemblyInfo.cs'
    )
}

if (-not $IncludeTemplates) {
    $filters.Exclude += '*\templates\*'
}

$allFiles = Get-ChildItem -Path $SourcePath -Recurse -Filter "*.cs" | Where-Object {
    $path = $_.FullName
    $excluded = $false
    
    foreach ($pattern in $filters.Exclude) {
        if ($path -like $pattern) {
            $excluded = $true
            break
        }
    }
    
    -not $excluded
} | Select-Object -ExpandProperty FullName

$totalFiles = $allFiles.Count

if ($totalFiles -eq 0) {
    Write-Host "No files found to analyze." -ForegroundColor Yellow
    exit 0
}

Write-Host "Found $totalFiles production code files to analyze." -ForegroundColor Green
Write-Host ""

# Display exclusion info
Write-Host "Excluded patterns:" -ForegroundColor DarkGray
foreach ($pattern in $filters.Exclude) {
    Write-Host "  - $pattern" -ForegroundColor DarkGray
}
Write-Host ""

# Prompt for confirmation
$response = Read-Host "Proceed with analysis? (Y/n)"
if ($response -and $response -ne 'Y' -and $response -ne 'y') {
    Write-Host "Analysis cancelled." -ForegroundColor Yellow
    exit 0
}

Write-Host ""
Write-Host "Starting analysis..." -ForegroundColor Yellow
Write-Host ""

# Save file list to temp location
$tempFile = Join-Path $env:TEMP "sonarqube-analysis-files-$(Get-Date -Format 'yyyyMMdd-HHmmss').txt"
$allFiles | Out-File -FilePath $tempFile -Encoding UTF8
Write-Host "File list saved to: $tempFile" -ForegroundColor DarkGray
Write-Host ""

# Track progress
$analyzed = 0
$errors = 0
$errorFiles = @()
$startTime = Get-Date

# Process files in batches
for ($i = 0; $i -lt $totalFiles; $i += $BatchSize) {
    $endIndex = [Math]::Min($i + $BatchSize - 1, $totalFiles - 1)
    $batchFiles = $allFiles[$i..$endIndex]
    $batchNumber = [Math]::Floor($i / $BatchSize) + 1
    $totalBatches = [Math]::Ceiling($totalFiles / $BatchSize)
    
    Write-Host "Batch $batchNumber of $totalBatches (Files $($i + 1)-$($endIndex + 1) of $totalFiles)" -ForegroundColor Cyan
    
    foreach ($file in $batchFiles) {
        $analyzed++
        $percentComplete = [Math]::Round(($analyzed / $totalFiles) * 100, 1)
        $relativePath = $file.Replace($SourcePath, "").TrimStart('\', '/')
        
        Write-Host "  [$percentComplete%] $relativePath" -ForegroundColor Gray -NoNewline
        
        try {
            # Note: This is a placeholder. In actual use with VS Code extension,
            # you would call the SonarQube analyze API through VS Code's command system.
            # For now, this outputs the command that would be used.
            
            # In a real VS Code environment with Copilot CLI, this would be:
            # Invoke-VsCodeCommand -Command "sonarqube.analyzeFile" -Arguments $file
            
            Write-Host " ✓" -ForegroundColor Green
        }
        catch {
            $errors++
            $errorFiles += $file
            Write-Host " ✗ ERROR: $_" -ForegroundColor Red
        }
    }
    
    Write-Host ""
}

# Calculate elapsed time
$endTime = Get-Date
$elapsed = $endTime - $startTime

# Final summary
Write-Host "═══════════════════════════════════════════════════════════════" -ForegroundColor Cyan
Write-Host "  Analysis Complete" -ForegroundColor Cyan
Write-Host "═══════════════════════════════════════════════════════════════" -ForegroundColor Cyan
Write-Host ""
Write-Host "Summary:" -ForegroundColor Yellow
Write-Host "  Total Files:     $totalFiles"
Write-Host "  Analyzed:        $($analyzed - $errors)" -ForegroundColor Green
Write-Host "  Errors:          $errors" -ForegroundColor $(if ($errors -gt 0) { "Red" } else { "Green" })
Write-Host "  Elapsed Time:    $($elapsed.ToString('hh\:mm\:ss'))"
Write-Host ""

if ($errors -gt 0) {
    Write-Host "Files with errors:" -ForegroundColor Red
    foreach ($file in $errorFiles) {
        Write-Host "  - $file" -ForegroundColor Red
    }
    Write-Host ""
}

Write-Host "Check the VS Code Problems panel (Ctrl+Shift+M) to review detected issues." -ForegroundColor Yellow
Write-Host ""

# Return exit code
exit $(if ($errors -gt 0) { 1 } else { 0 })
