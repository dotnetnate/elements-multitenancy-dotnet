<#
.SYNOPSIS
    Configures the local Git repository to use the shared hooks in .githooks/.

.DESCRIPTION
    Points the Git hooks path to the .githooks directory at the repository root.
    This enables the pre-push hook that runs the full test suite before allowing pushes.
    Run this once after cloning the repository.

.EXAMPLE
    .\eng\setup-hooks.ps1
#>

$ErrorActionPreference = 'Stop'

$repoRoot = git rev-parse --show-toplevel 2>$null
if (-not $repoRoot) {
    Write-Error "Not inside a git repository."
    exit 1
}

git config core.hooksPath .githooks

Write-Host ""
Write-Host "Git hooks configured successfully." -ForegroundColor Green
Write-Host "  hooks path: .githooks/" -ForegroundColor Gray
Write-Host "  active hooks: pre-push (runs full test suite)" -ForegroundColor Gray
Write-Host ""
