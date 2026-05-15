#!/usr/bin/env pwsh
# check-prereqs.ps1 — verify that doc-gen can run in the current environment.
[CmdletBinding()]
param()

$ErrorActionPreference = 'Stop'
Set-StrictMode -Version Latest

$checks = @()
$ok = $true

# PowerShell 7+
$psVersion = $PSVersionTable.PSVersion
$psOk = $psVersion.Major -ge 7
if (-not $psOk) { $ok = $false }
$checks += [pscustomobject]@{
    name    = 'powershell'
    ok      = $psOk
    version = "$psVersion"
    message = if ($psOk) { '' } else { 'PowerShell 7+ required. Install from https://aka.ms/powershell' }
}

# dotnet (optional — only needed for dotnet projects)
$dotnet = Get-Command dotnet -ErrorAction SilentlyContinue
$checks += [pscustomobject]@{
    name    = 'dotnet'
    ok      = [bool]$dotnet
    version = if ($dotnet) { (& dotnet --version) } else { '' }
    message = if ($dotnet) { '' } else { 'dotnet CLI not found. Required only for .NET projects.' }
}

[pscustomobject]@{ ok = $ok; checks = $checks } | ConvertTo-Json -Depth 5 -Compress
