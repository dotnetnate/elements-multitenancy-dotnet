# Run Tests with Comprehensive Coverage Analysis

## Overview
Executes a complete test workflow following code review guidelines: cleans previous results, verifies/installs required tools, cleans and builds the solution, runs all unit tests with code coverage collection, merges coverage results, and generates comprehensive reports broken down by assembly, class, method, and blocks. Output is saved to `src/test-results/`.

## Usage

### Quick Test Run (Clean, Build, Test, Report)
```powershell
cd src
.\..\.github\skills\run-tests\run-tests.ps1
```

### With Detailed Analysis
```powershell
cd src
.\..\.github\skills\run-tests\run-tests.ps1 -Detailed
```

### With JSON Output for CI/CD
```powershell
cd src
.\..\.github\skills\run-tests\run-tests.ps1 -OutputJson
```

### Analyze Coverage (Auto-runs tests if needed)
```powershell
cd src
.\..\.github\skills\run-tests\analyze-coverage.ps1
```

### Force Test Re-run with HTML Report
```powershell
cd src
.\..\.github\skills\run-tests\analyze-coverage.ps1 -RunTests -ExportHtml
```

## Features

- ✅ **Clean build process** — Follows code review guidelines
- ✅ **Auto-installs tools** — Verifies and installs dotnet-coverage and reportgenerator
- ✅ **Cleans solution** — Runs dotnet clean before build
- ✅ **Builds solution** — Ensures no build errors before testing
- ✅ **Runs all unit tests** — With code coverage collection and proper logging
- 📊 **Merges coverage files** — From all test projects to standard location
- 🔍 **Assembly-level metrics** — Line %, branch %, complexity
- 📦 **Class-level breakdown** — With method counts
- 🔬 **Method-level coverage** — For classes below 100%
- 🎯 **Identifies uncovered code blocks** — With line numbers
- 📈 **Overall statistics** — And test count summaries
- ⚠️ **Highlights assemblies needing attention** — Below threshold
- 📄 **Multiple output formats** — Console, JSON, HTML

## Output Formats

### Executive Summary
- Overall coverage percentage
- Assembly pass/fail status
- Test count summaries
- Key achievements

### Assembly-Level Metrics
- Line coverage percentage
- Branch coverage percentage
- Cyclomatic complexity
- Class and method counts

### Class-Level Breakdown
- Per-class coverage percentages
- Method counts per class
- Sorted by coverage (lowest first)

### Method-Level Details
- Individual method coverage for classes < 100%
- Status indicators (✓ complete, ⚠ partial)
- Uncovered line numbers

### Uncovered Code Blocks
- Exact line numbers of uncovered code
- Grouped by assembly and class
- Helps prioritize testing efforts

## Dependencies

- .NET SDK (for `dotnet test`, `dotnet clean`, `dotnet build`)
- `dotnet-coverage` CLI tool (auto-installed if missing)
- `dotnet-reportgenerator-globaltool` CLI tool (auto-installed if missing)
- MSTest.Sdk test projects
- `codecoverage.runsettings` file in `src/` directory

## Coverage File Locations

- Test Results: `src/test-results/`
- Input: `test-results/**/*.coverage`
- Merged Output: `src/test-results/coverage.xml` (Cobertura format)
- HTML Report: `src/test-results/coverage-report.html` (when using `-ExportHtml`)
- JSON Report: `src/test-results/coverage-summary.json` (when using `-OutputJson`)

## Clean Build Process

Both scripts follow code review guidelines:
1. ✅ Delete `test-results` folder (no errors if missing)
2. ✅ Verify `dotnet-coverage` tool installed (auto-install if missing)
3. ✅ Verify `dotnet-reportgenerator-globaltool` installed (auto-install if missing)
4. ✅ Perform `dotnet clean` on solution
5. ✅ Build solution with `dotnet build`
6. ✅ Run tests with proper logging options
7. ✅ Merge coverage to standard location

## Threshold Configuration

Default thresholds in scripts:
- ✅ Pass: >= 90% line coverage
- ⚠️ Near: >= 80% line coverage
- ❌ Fail: < 80% line coverage

## Example Output

```
╔════════════════════════════════════════════════════════════════════════════╗
║          FINAL COMPREHENSIVE CODE COVERAGE SUMMARY REPORT                  ║
║                      February 13, 2026                                     ║
╚════════════════════════════════════════════════════════════════════════════╝

━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
                           EXECUTIVE SUMMARY
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

✅ 2 of 3 target assemblies achieved 90%+ coverage
🎯 Overall average: 90.03% line coverage
📊 27 classes analyzed across 4 assemblies
🧪 210+ unit tests passing (0 failures)

Assembly                             Line % Branch % Classes Status
--------                             ------ -------- ------- ------
Elements.Core                         90.00   100.00      19 ✅ PASS
Elements.Validation.Abstractions     100.00   100.00       2 ✅ PASS
Elements.Validation.FluentValidation  82.98   100.00       4 ⚠️ NEAR
```

## Integration with CI/CD

The scripts can be integrated into CI/CD pipelines:

```yaml
# Azure DevOps example
- task: PowerShell@2
  displayName: 'Run Tests with Coverage'
  inputs:
    filePath: '.github/skills/run-tests/run-tests.ps1'
    workingDirectory: 'src'
```

## Customization

### Modify Coverage Thresholds
Edit the threshold logic in `run-tests.ps1`:
```powershell
$status = if ($cov -ge 90) { "✅ PASS" } 
          elseif ($cov -ge 80) { "⚠️ NEAR" } 
          else { "❌ FAIL" }
```

### Filter Assemblies
Modify the `-AssemblyFilter` parameter (default matches all `Elements.*` assemblies):
```powershell
# Only Core and Validation assemblies
.\run-tests.ps1 -AssemblyFilter 'Elements\.(Core|Validation)'

# Only a specific assembly
.\run-tests.ps1 -AssemblyFilter 'Elements\.Core$'
```

### Change Output Format
Scripts can be modified to output JSON, CSV, or other formats for integration with reporting tools.

## Troubleshooting

### Coverage files not found
Ensure tests run successfully and `codecoverage.runsettings` is configured correctly.

### Build fails
Check for compilation errors in the solution. The script runs `dotnet build` before tests.

### Tools not installing
Required tools (`dotnet-coverage` and `dotnet-reportgenerator-globaltool`) are auto-installed.
If installation fails, check internet connectivity and NuGet configuration.

### Incorrect line numbers
Coverage is based on compiled code. The script ensures clean build before tests to maintain accuracy.

## Related Documentation

- [MSTest Documentation](https://learn.microsoft.com/en-us/dotnet/core/testing/unit-testing-with-mstest)
- [Code Coverage Configuration](https://learn.microsoft.com/en-us/dotnet/core/testing/unit-testing-code-coverage)
- [Cobertura Format](https://cobertura.github.io/cobertura/)
