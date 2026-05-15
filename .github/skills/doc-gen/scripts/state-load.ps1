#!/usr/bin/env pwsh
<#
.SYNOPSIS
    Load the doc-gen differential state file.

.DESCRIPTION
    Reads <StatePath> if present and returns its parsed content as a PSCustomObject.
    Returns an empty state object when the file does not exist or is unreadable.

    State schema:

        {
          "version": 1,
          "style":   "msdn",
          "format":  "md",
          "projects": {
            "<Project>": {
              "commit":    "<short-sha>",
              "xmlHash":   "<sha256>",
              "generated": "2026-04-23T00:00:00Z"
            }
          }
        }
#>
[CmdletBinding()]
param(
    [Parameter(Mandatory)][string]$StatePath
)

$ErrorActionPreference = 'Stop'

if (-not (Test-Path -LiteralPath $StatePath)) {
    return [pscustomobject]@{
        version  = 1
        style    = ''
        format   = ''
        projects = [pscustomobject]@{}
    }
}

try {
    $raw = Get-Content -LiteralPath $StatePath -Raw
    if ([string]::IsNullOrWhiteSpace($raw)) {
        return [pscustomobject]@{ version = 1; style = ''; format = ''; projects = [pscustomobject]@{} }
    }
    return ($raw | ConvertFrom-Json -Depth 32)
} catch {
    Write-Warning "Could not read state file '$StatePath': $($_.Exception.Message). Treating as empty."
    return [pscustomobject]@{ version = 1; style = ''; format = ''; projects = [pscustomobject]@{} }
}
