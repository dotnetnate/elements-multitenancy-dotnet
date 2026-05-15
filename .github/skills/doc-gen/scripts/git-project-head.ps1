#!/usr/bin/env pwsh
<#
.SYNOPSIS
    Get the short commit SHA that last touched a given path inside a git repo.

.DESCRIPTION
    Prints the short commit SHA of the most recent commit that modified any file
    under <Path> (relative to <RepoRoot>). Prints an empty string when the path
    has no committed history (untracked / uncommitted-only) or git is unavailable.

    Used by the doc-gen orchestrator to decide whether a project's documentation
    needs to be regenerated since the last run (differential updates).
#>
[CmdletBinding()]
param(
    [Parameter(Mandatory)][string]$Path,
    [string]$RepoRoot
)

$ErrorActionPreference = 'Stop'

if (-not $RepoRoot) {
    # Walk upward from Path to locate .git
    $cur = (Resolve-Path -LiteralPath $Path).Path
    while ($cur) {
        if (Test-Path -LiteralPath (Join-Path $cur '.git')) { $RepoRoot = $cur; break }
        $parent = Split-Path -Parent $cur
        if ($parent -eq $cur) { break }
        $cur = $parent
    }
}

if (-not $RepoRoot -or -not (Test-Path -LiteralPath (Join-Path $RepoRoot '.git'))) {
    return ''
}

$git = Get-Command git -ErrorAction SilentlyContinue
if (-not $git) { return '' }

Push-Location $RepoRoot
try {
    $abs = (Resolve-Path -LiteralPath $Path).Path
    $rel = $abs.Substring($RepoRoot.Length).TrimStart('\','/') -replace '\\','/'
    if (-not $rel) { $rel = '.' }
    $shaOut = & git log -n 1 --format='%h' -- $rel 2>$null
    if ($LASTEXITCODE -ne 0 -or [string]::IsNullOrWhiteSpace($shaOut)) { return '' }
    return ($shaOut | Out-String).Trim()
} finally {
    Pop-Location
}
