#!/usr/bin/env pwsh
<#
.SYNOPSIS
    Persist the doc-gen differential state file.

.DESCRIPTION
    Writes the passed state object to <StatePath> as pretty-printed JSON.
    Creates the target directory if it does not exist.

    State schema: see state-load.ps1.
#>
[CmdletBinding()]
param(
    [Parameter(Mandatory)][string]$StatePath,
    [Parameter(Mandatory, ValueFromPipeline)][object]$State
)

$ErrorActionPreference = 'Stop'

$dir = Split-Path -Parent $StatePath
if ($dir -and -not (Test-Path -LiteralPath $dir)) {
    New-Item -ItemType Directory -Path $dir -Force | Out-Null
}

$json = $State | ConvertTo-Json -Depth 32
Set-Content -LiteralPath $StatePath -Value $json -Encoding UTF8
