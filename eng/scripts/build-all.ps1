$solution = Join-Path $PSScriptRoot "../../src/full-solution.slnx"

dotnet clean $solution
if ($LASTEXITCODE -ne 0) {
    Write-Host "BUILD FAILED"
    exit 1
}

dotnet build $solution --configuration Release
if ($LASTEXITCODE -ne 0) {
    Write-Host "BUILD FAILED"
    exit 1
}
