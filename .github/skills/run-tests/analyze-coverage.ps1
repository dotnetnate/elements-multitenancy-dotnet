#!/usr/bin/env pwsh
<#
.SYNOPSIS
    Analyzes existing code coverage data without running tests.

.DESCRIPTION
    Loads and analyzes existing comprehensive-coverage.xml file,
    generating detailed coverage reports. Use this when coverage data
    already exists and you don't want to re-run tests.

.PARAMETER AssemblyFilter
    Regex pattern to filter assemblies for coverage analysis.
    Default: 'Elements\.' (matches all Elements assemblies)

.PARAMETER RunTests
    When specified, runs tests and merges coverage before analysis.

.PARAMETER ShowAllClasses
    When specified, shows coverage for all classes, not just those below 100%.

.PARAMETER ExportHtml
    When specified, generates an HTML coverage report.

.EXAMPLE
    .\analyze-coverage.ps1
    Analyzes coverage with default filters.

.EXAMPLE
    .\analyze-coverage.ps1 -RunTests
    Runs tests, merges coverage, then analyzes results.

.EXAMPLE
    .\analyze-coverage.ps1 -ShowAllClasses
    Shows coverage for all classes including those at 100%.

.NOTES
    Author: GitHub Copilot
    Date: February 13, 2026
    Requires: comprehensive-coverage.xml file in current directory
#>

[CmdletBinding()]
param(
    [Parameter(Mandatory=$false)]
    [string]$AssemblyFilter = 'Elements\.',

    [Parameter(Mandatory=$false)]
    [switch]$RunTests,

    [Parameter(Mandatory=$false)]
    [switch]$ShowAllClasses,

    [Parameter(Mandatory=$false)]
    [switch]$ExportHtml
)

$ErrorActionPreference = "Stop"
$ProgressPreference = "SilentlyContinue"

# Ensure we're in the src directory
if (-not (Test-Path "src.sln")) {
    Write-Error "Must be run from the src directory containing src.sln"
    exit 1
}

# Run tests and merge coverage if requested or if coverage file doesn't exist
if ($RunTests -or -not (Test-Path "./test-results/coverage.xml")) {
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
    
    Write-Host "✅ Tests completed successfully" -ForegroundColor Green
    
    Write-Host "📊 Merging coverage files..." -ForegroundColor Cyan
    $mergeOutput = dotnet-coverage merge ./test-results/**/*.coverage `
        --output-format cobertura `
        --output ./test-results/coverage.xml 2>&1
    
    if ($LASTEXITCODE -ne 0) {
        Write-Error "Coverage merge failed. Ensure dotnet-coverage is installed: dotnet tool install -g dotnet-coverage"
        exit $LASTEXITCODE
    }
}

# Check for coverage file
if (-not (Test-Path "./test-results/coverage.xml")) {
    Write-Error "Coverage file not found. Run with -RunTests switch or ensure test-results/coverage.xml exists."
    exit 1
}

# Load coverage XML
Write-Host "`n📊 Loading coverage data..." -ForegroundColor Cyan
[xml]$xml = Get-Content ./test-results/coverage.xml

$allPackages = $xml.coverage.packages.package | Where-Object { $_.name -match $AssemblyFilter }

if (-not $allPackages) {
    Write-Error "No assemblies found matching filter: $AssemblyFilter"
    exit 1
}

# Display header
Write-Host "`n╔════════════════════════════════════════════════════════════════════════════╗" -ForegroundColor Blue
Write-Host "║                    CODE COVERAGE ANALYSIS REPORT                           ║" -ForegroundColor Blue
Write-Host "║                      $(Get-Date -Format 'MMMM dd, yyyy')                                     ║" -ForegroundColor Blue
Write-Host "╚════════════════════════════════════════════════════════════════════════════╝`n" -ForegroundColor Blue

# Summary
Write-Host "Assembly Summary:" -ForegroundColor Yellow
$allPackages | Sort-Object name | ForEach-Object {
    $lineCov = [math]::Round([double]$_.'line-rate' * 100, 2)
    $status = if ($lineCov -ge 90) { "✅" } elseif ($lineCov -ge 80) { "⚠️" } else { "❌" }
    Write-Host "  $status $($_.name): $lineCov%"
}

Write-Host "`n━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━`n" -ForegroundColor Yellow

# Detailed class analysis
foreach ($pkg in $allPackages) {
    $pkgCov = [math]::Round([double]$pkg.'line-rate' * 100, 2)
    Write-Host "📦 $($pkg.name) - $pkgCov%`n" -ForegroundColor Cyan
    
    $classes = if ($ShowAllClasses) {
        $pkg.classes.class | Where-Object { $_.name -notmatch '<>c' }
    } else {
        $pkg.classes.class | Where-Object { [double]$_.'line-rate' -lt 1.0 -and $_.name -notmatch '<>c' }
    }
    
    if ($classes) {
        foreach ($class in $classes) {
            $className = $class.name -replace '^MyOrg\.Elements\.', ''
            $classCov = [math]::Round([double]$class.'line-rate' * 100, 2)
            $status = if ($classCov -eq 100) { "✅" } else { "⚠️" }
            
            Write-Host "   $status $className - $classCov%" -ForegroundColor White
            
            # Show uncovered lines for classes below 100%
            if ($classCov -lt 100) {
                $uncoveredLines = $class.lines.line | Where-Object { [int]$_.hits -eq 0 }
                
                if ($uncoveredLines) {
                    $lineNumbers = ($uncoveredLines | ForEach-Object { $_.number }) -join ', '
                    Write-Host "      Uncovered: lines $lineNumbers" -ForegroundColor DarkGray
                }
                
                # Show method breakdown
                if ($class.methods.method) {
                    $methods = if ($class.methods.method -is [Array]) { $class.methods.method } else { @($class.methods.method) }
                    $uncoveredMethods = $methods | Where-Object { [double]$_.'line-rate' -lt 1.0 }
                    
                    if ($uncoveredMethods) {
                        Write-Host "      Methods needing coverage:" -ForegroundColor DarkGray
                        foreach ($method in $uncoveredMethods) {
                            $methodCov = [math]::Round([double]$method.'line-rate' * 100, 2)
                            $methodName = $method.name -replace '<', '' -replace '>', ''
                            Write-Host "        • $methodName - $methodCov%" -ForegroundColor DarkGray
                        }
                    }
                }
            }
            Write-Host ""
        }
    } else {
        Write-Host "   ✅ All classes at 100% coverage`n" -ForegroundColor Green
    }
}

# HTML export if requested
if ($ExportHtml) {
    Write-Host "📄 Generating HTML report..." -ForegroundColor Cyan
    
    $html = @"
<!DOCTYPE html>
<html>
<head>
    <title>Code Coverage Report - $(Get-Date -Format 'yyyy-MM-dd')</title>
    <style>
        body { font-family: 'Segoe UI', Tahoma, Geneva, Verdana, sans-serif; margin: 20px; background: #f5f5f5; }
        h1 { color: #2c3e50; border-bottom: 3px solid #3498db; padding-bottom: 10px; }
        h2 { color: #34495e; margin-top: 30px; }
        table { width: 100%; border-collapse: collapse; background: white; box-shadow: 0 2px 4px rgba(0,0,0,0.1); }
        th { background: #3498db; color: white; padding: 12px; text-align: left; }
        td { padding: 10px; border-bottom: 1px solid #ecf0f1; }
        tr:hover { background: #ecf0f1; }
        .pass { color: #27ae60; font-weight: bold; }
        .near { color: #f39c12; font-weight: bold; }
        .fail { color: #e74c3c; font-weight: bold; }
        .summary { background: white; padding: 20px; margin: 20px 0; border-radius: 5px; box-shadow: 0 2px 4px rgba(0,0,0,0.1); }
        .metric { display: inline-block; margin: 10px 20px; }
        .metric-value { font-size: 2em; font-weight: bold; color: #3498db; }
        .metric-label { color: #7f8c8d; font-size: 0.9em; }
    </style>
</head>
<body>
    <h1>Code Coverage Report</h1>
    <div class="summary">
        <div class="metric">
            <div class="metric-value">$($allPackages.Count)</div>
            <div class="metric-label">Assemblies</div>
        </div>
        <div class="metric">
            <div class="metric-value">$(($allPackages | ForEach-Object { $_.classes.class }).Count)</div>
            <div class="metric-label">Classes</div>
        </div>
        <div class="metric">
            <div class="metric-value">Generated: $(Get-Date -Format 'yyyy-MM-dd HH:mm')</div>
            <div class="metric-label">Timestamp</div>
        </div>
    </div>
    
    <h2>Assembly Coverage</h2>
    <table>
        <thead>
            <tr>
                <th>Assembly</th>
                <th>Line Coverage</th>
                <th>Branch Coverage</th>
                <th>Classes</th>
                <th>Status</th>
            </tr>
        </thead>
        <tbody>
"@
    
    foreach ($pkg in ($allPackages | Sort-Object name)) {
        $lineCov = [math]::Round([double]$pkg.'line-rate' * 100, 2)
        $branchCov = [math]::Round([double]$pkg.'branch-rate' * 100, 2)
        $statusClass = if ($lineCov -ge 90) { "pass" } elseif ($lineCov -ge 80) { "near" } else { "fail" }
        $statusText = if ($lineCov -ge 90) { "✅ PASS" } elseif ($lineCov -ge 80) { "⚠️ NEAR" } else { "❌ FAIL" }
        
        $html += @"
            <tr>
                <td>$($pkg.name)</td>
                <td>$lineCov%</td>
                <td>$branchCov%</td>
                <td>$($pkg.classes.class.Count)</td>
                <td class="$statusClass">$statusText</td>
            </tr>
"@
    }
    
    $html += @"
        </tbody>
    </table>
</body>
</html>
"@
    
    $html | Out-File "./test-results/coverage-report.html" -Encoding UTF8
    Write-Host "✅ HTML report saved to test-results/coverage-report.html" -ForegroundColor Green
    
    # Try to open in default browser
    if ($IsWindows -or $PSVersionTable.PSVersion.Major -lt 6) {
        Start-Process "./test-results/coverage-report.html"
    }
}

Write-Host "`n━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━`n" -ForegroundColor Yellow

# Calculate pass/fail
$passing = ($allPackages | Where-Object { [math]::Round([double]$_.'line-rate' * 100, 2) -ge 90 }).Count
$total = $allPackages.Count

if ($passing -lt $total) {
    Write-Host "⚠️  $($total - $passing) of $total assemblies below 90% threshold" -ForegroundColor Yellow
    exit 0
} else {
    Write-Host "✅ All $total assemblies meet 90% coverage threshold" -ForegroundColor Green
    exit 0
}
