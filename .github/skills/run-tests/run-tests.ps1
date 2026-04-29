#!/usr/bin/env pwsh
<#
.SYNOPSIS
    Runs all unit tests with comprehensive code coverage analysis.

.DESCRIPTION
    Executes the full test suite with code coverage collection, merges coverage files,
    and generates detailed reports broken down by assembly, class, method, and blocks.

.PARAMETER Detailed
    When specified, generates additional detailed analysis including method-level coverage
    and uncovered code blocks.

.PARAMETER AssemblyFilter
    Regex pattern to filter assemblies for coverage analysis.
    Default: 'Elements\.' (matches all Elements assemblies)

.PARAMETER SkipTests
    When specified, skips test execution and only analyzes existing coverage data.

.PARAMETER OutputJson
    When specified, outputs coverage data in JSON format for CI/CD integration.

.EXAMPLE
    .\run-tests.ps1
    Runs tests and displays basic coverage summary.

.EXAMPLE
    .\run-tests.ps1 -Detailed
    Runs tests and displays comprehensive coverage analysis.

.EXAMPLE
    .\run-tests.ps1 -SkipTests -Detailed
    Analyzes existing coverage data without running tests.

.NOTES
    Author: GitHub Copilot
    Date: February 13, 2026
    Requires: dotnet CLI, dotnet-coverage tool
#>

[CmdletBinding()]
param(
    [Parameter(Mandatory=$false)]
    [switch]$Detailed,

    [Parameter(Mandatory=$false)]
    [string]$AssemblyFilter = 'Elements\.',

    [Parameter(Mandatory=$false)]
    [switch]$SkipTests,

    [Parameter(Mandatory=$false)]
    [switch]$OutputJson
)

$ErrorActionPreference = "Stop"
$ProgressPreference = "SilentlyContinue"

# Ensure we're in the src directory
if (-not (Test-Path "src.sln")) {
    Write-Error "Must be run from the src directory containing src.sln"
    exit 1
}

# Clean previous results
if (-not $SkipTests) {
    Write-Host "`n🧹 Cleaning previous test results..." -ForegroundColor Cyan
    Remove-Item -Path "test-results" -Recurse -Force -ErrorAction SilentlyContinue
    
    # Verify required dotnet tools are installed
    Write-Host "🔧 Verifying dotnet tools..." -ForegroundColor Cyan
    
    $coverageTool = dotnet tool list -g | Select-String "dotnet-coverage"
    if (-not $coverageTool) {
        Write-Host "   Installing dotnet-coverage..." -ForegroundColor Yellow
        dotnet tool install --global dotnet-coverage | Out-Null
    }
    
    $reportGenTool = dotnet tool list -g | Select-String "dotnet-reportgenerator-globaltool"
    if (-not $reportGenTool) {
        Write-Host "   Installing dotnet-reportgenerator-globaltool..." -ForegroundColor Yellow
        dotnet tool install --global dotnet-reportgenerator-globaltool | Out-Null
    }
    
    # Clean solution
    Write-Host "🧹 Cleaning solution..." -ForegroundColor Cyan
    dotnet clean src.sln --verbosity quiet | Out-Null
    
    # Build solution
    Write-Host "🔨 Building solution..." -ForegroundColor Cyan
    $buildOutput = dotnet build src.sln --verbosity quiet 2>&1
    
    if ($LASTEXITCODE -ne 0) {
        Write-Error "Build failed. See output above."
        exit $LASTEXITCODE
    }
}

# Run tests with coverage
if (-not $SkipTests) {
    Write-Host "🧪 Running tests with code coverage..." -ForegroundColor Cyan
    $testOutput = dotnet test src.sln `
        --collect "Code Coverage" `
        --settings codecoverage.runsettings `
        --logger "trx;LogFileName=test_results.trx" `
        --results-directory ./test-results `
        --verbosity quiet 2>&1
    
    if ($LASTEXITCODE -ne 0) {
        Write-Error "Tests failed. See output above."
        exit $LASTEXITCODE
    }
    
    Write-Host "✅ Tests completed successfully`n" -ForegroundColor Green
}

# Merge coverage files
Write-Host "📊 Merging coverage files..." -ForegroundColor Cyan
$mergeOutput = dotnet-coverage merge ./test-results/**/*.coverage `
    --output-format cobertura `
    --output ./test-results/coverage.xml 2>&1

if ($LASTEXITCODE -ne 0) {
    Write-Error "Coverage merge failed. Ensure dotnet-coverage is installed: dotnet tool install -g dotnet-coverage"
    exit $LASTEXITCODE
}

# Load coverage XML
[xml]$xml = Get-Content ./test-results/coverage.xml

# Generate reports
Write-Host "`n╔════════════════════════════════════════════════════════════════════════════╗" -ForegroundColor Blue
Write-Host "║          COMPREHENSIVE CODE COVERAGE SUMMARY REPORT                        ║" -ForegroundColor Blue
Write-Host "║                      $(Get-Date -Format 'MMMM dd, yyyy')                                     ║" -ForegroundColor Blue
Write-Host "╚════════════════════════════════════════════════════════════════════════════╝" -ForegroundColor Blue

# Executive Summary
Write-Host "`n━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━" -ForegroundColor Yellow
Write-Host "                           EXECUTIVE SUMMARY" -ForegroundColor Yellow
Write-Host "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━`n" -ForegroundColor Yellow

$allPackages = $xml.coverage.packages.package | Where-Object { $_.name -match $AssemblyFilter }

# Calculate overall statistics
$stats = @()
foreach ($pkg in $allPackages) {
    $lineRate = [double]$pkg.'line-rate'
    $branchRate = [double]$pkg.'branch-rate'
    $classes = $pkg.classes.class
    $classCount = if ($classes -is [Array]) { $classes.Count } else { 1 }
    
    $methods = $classes | ForEach-Object { $_.methods.method }
    $methodCount = if ($methods -is [Array]) { $methods.Count } else { if ($methods) { 1 } else { 0 } }
    
    $lines = $classes | ForEach-Object { $_.lines.line }
    $lineCount = if ($lines -is [Array]) { $lines.Count } else { if ($lines) { 1 } else { 0 } }
    $linesCovered = [int]($lineCount * $lineRate)
    
    $stats += [PSCustomObject]@{
        Assembly = $pkg.name
        Classes = $classCount
        Methods = $methodCount
        Lines = $lineCount
        LinesCovered = $linesCovered
        LineRate = [math]::Round($lineRate * 100, 2)
        BranchRate = [math]::Round($branchRate * 100, 2)
        Complexity = $pkg.complexity
    }
}

$totalClasses = ($stats | Measure-Object -Property Classes -Sum).Sum
$totalMethods = ($stats | Measure-Object -Property Methods -Sum).Sum
$totalLines = ($stats | Measure-Object -Property Lines -Sum).Sum
$totalCovered = ($stats | Measure-Object -Property LinesCovered -Sum).Sum
$avgCoverage = [math]::Round(($totalCovered / $totalLines) * 100, 2)

$passing = ($stats | Where-Object { $_.LineRate -ge 90 }).Count
$total = $stats.Count

Write-Host "🎯 Overall average: $avgCoverage% line coverage"
Write-Host "✅ $passing of $total assemblies achieved 90%+ coverage"
Write-Host "📊 $totalClasses classes analyzed across $($stats.Count) assemblies"
Write-Host "🔧 $totalMethods total methods"
Write-Host "📏 $totalLines executable lines ($totalCovered covered)"

if (-not $SkipTests) {
    Write-Host "🧪 All tests passing (0 failures)"
}

# Assembly-Level Metrics
Write-Host "`n━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━" -ForegroundColor Yellow
Write-Host "                       ASSEMBLY-LEVEL METRICS" -ForegroundColor Yellow
Write-Host "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━`n" -ForegroundColor Yellow

$allPackages | Sort-Object name | Select-Object `
    @{N='Assembly';E={$_.name}}, `
    @{N='Line %';E={[math]::Round([double]$_.'line-rate' * 100, 2)}}, `
    @{N='Branch %';E={[math]::Round([double]$_.'branch-rate' * 100, 2)}}, `
    @{N='Classes';E={$_.classes.class.Count}}, `
    @{N='Complexity';E={$_.complexity}}, `
    @{N='Status';E={
        $c=[math]::Round([double]$_.'line-rate' * 100, 2)
        if($c -ge 90){"✅ PASS"}
        elseif($c -ge 80){"⚠️  NEAR"}
        else{"❌ FAIL"}
    }} | Format-Table -AutoSize

# Detailed analysis if requested
if ($Detailed) {
    # Detailed Assembly, Class, and Method-Level Breakdown
    Write-Host "`n━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━" -ForegroundColor Yellow
    Write-Host "              DETAILED COVERAGE: ASSEMBLY → CLASS → METHOD" -ForegroundColor Yellow
    Write-Host "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━`n" -ForegroundColor Yellow
    
    foreach ($pkg in $allPackages | Sort-Object name) {
        $pkgLineCov = [math]::Round([double]$pkg.'line-rate' * 100, 2)
        $pkgBranchCov = [math]::Round([double]$pkg.'branch-rate' * 100, 2)
        $pkgStatus = if ($pkgLineCov -ge 90) { "✅" } elseif ($pkgLineCov -ge 80) { "⚠️" } else { "❌" }
        
        Write-Host "`n╔═══════════════════════════════════════════════════════════════════════════╗" -ForegroundColor Cyan
        Write-Host "║ $pkgStatus ASSEMBLY: $($pkg.name)" -ForegroundColor Cyan
        Write-Host "║ Line Coverage: $pkgLineCov% | Branch Coverage: $pkgBranchCov% | Complexity: $($pkg.complexity)" -ForegroundColor Cyan
        Write-Host "╚═══════════════════════════════════════════════════════════════════════════╝`n" -ForegroundColor Cyan
        
        $classes = $pkg.classes.class | Where-Object { $_.name -notmatch '<>c' -and $_.name -notmatch '<.*>d__\d+' } | Sort-Object name
        
        foreach ($class in $classes) {
            $className = $class.name -replace '^MyOrg\.Elements\.', ''
            $classCov = [math]::Round([double]$class.'line-rate' * 100, 2)
            $classBranchCov = [math]::Round([double]$class.'branch-rate' * 100, 2)
            $classStatus = if ($classCov -eq 100) { "✅" } elseif ($classCov -ge 90) { "✓" } else { "⚠️" }
            
            Write-Host "  ┌─────────────────────────────────────────────────────────────────────────┐" -ForegroundColor White
            Write-Host "  │ $classStatus CLASS: $className" -ForegroundColor White
            Write-Host "  │ Line: $classCov% | Branch: $classBranchCov% | Complexity: $($class.complexity)" -ForegroundColor White
            Write-Host "  └─────────────────────────────────────────────────────────────────────────┘" -ForegroundColor White
            
            if ($class.methods.method) {
                $methods = if ($class.methods.method -is [Array]) { $class.methods.method } else { @($class.methods.method) }
                
                # Create method table data
                $methodData = $methods | ForEach-Object {
                    $methodCov = [math]::Round([double]$_.'line-rate' * 100, 2)
                    $methodBranchCov = [math]::Round([double]$_.'branch-rate' * 100, 2)
                    $methodName = $_.name -replace '<', '' -replace '>', '' -replace '__', '.'
                    $status = if ($methodCov -eq 100) { "✅" } elseif ($methodCov -ge 90) { "✓" } else { "⚠️" }
                    
                    # Get line coverage stats
                    $lines = if ($_.lines.line -is [Array]) { $_.lines.line } else { @($_.lines.line) }
                    $totalLines = $lines.Count
                    $coveredLines = ($lines | Where-Object { [int]$_.hits -gt 0 }).Count
                    
                    [PSCustomObject]@{
                        Status = $status
                        Method = $methodName
                        'Line %' = $methodCov
                        'Branch %' = $methodBranchCov
                        'Lines' = "$coveredLines/$totalLines"
                        'Hits' = ($lines | Measure-Object -Property hits -Sum).Sum
                    }
                }
                
                Write-Host ""
                $methodData | Format-Table -AutoSize | Out-String | ForEach-Object { 
                    $_.Split("`n") | ForEach-Object { 
                        if ($_.Trim()) { Write-Host "    $_" -ForegroundColor Gray }
                    }
                }
            } else {
                Write-Host "    No methods found`n" -ForegroundColor DarkGray
            }
        }
    }
    
    # Uncovered Code Blocks
    Write-Host "`n━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━" -ForegroundColor Yellow
    Write-Host "                       UNCOVERED CODE BLOCKS" -ForegroundColor Yellow
    Write-Host "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━`n" -ForegroundColor Yellow
    
    foreach ($pkg in $allPackages) {
        $classesWithUncovered = $pkg.classes.class | Where-Object { [double]$_.'line-rate' -lt 1.0 -and $_.name -notmatch '<>c' }
        
        if ($classesWithUncovered) {
            Write-Host "📦 $($pkg.name)`n" -ForegroundColor Cyan
            
            foreach ($class in $classesWithUncovered) {
                $className = $class.name -replace '^MyOrg\.Elements\.', ''
                $classCov = [math]::Round([double]$class.'line-rate' * 100, 2)
                
                Write-Host "   Class: $className ($classCov% coverage)"
                
                $uncoveredLines = $class.lines.line | Where-Object { [int]$_.hits -eq 0 } | Select-Object -First 10
                
                if ($uncoveredLines) {
                    Write-Host "   Uncovered lines: $(($uncoveredLines | ForEach-Object { $_.number }) -join ', ')"
                }
                Write-Host ""
            }
        }
    }
}

# JSON output for CI/CD integration
if ($OutputJson) {
    $jsonOutput = @{
        Timestamp = Get-Date -Format "o"
        OverallCoverage = $avgCoverage
        Assemblies = $stats
        PassingAssemblies = $passing
        TotalAssemblies = $total
    }
    
    $jsonOutput | ConvertTo-Json -Depth 10 | Out-File "./test-results/coverage-summary.json" -Encoding UTF8
    Write-Host "`n📄 JSON report saved to test-results/coverage-summary.json" -ForegroundColor Green
}

Write-Host "`n━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━`n" -ForegroundColor Yellow

# Exit with appropriate code
if ($passing -lt $total) {
    Write-Host "⚠️  Some assemblies below 90% threshold" -ForegroundColor Yellow
    exit 1
} else {
    Write-Host "✅ All assemblies meet coverage threshold" -ForegroundColor Green
    exit 0
}
