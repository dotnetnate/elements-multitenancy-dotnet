#Requires -Version 7
# check-prereqs.ps1
# Probes for the PowerShell version and required core tools.
# Emits: {ok, pwsh, version, host, message}
# Exit 0 when ok:true, exit 2 when ok:false.

. "$PSScriptRoot/_lib.ps1"

$version = $PSVersionTable.PSVersion.ToString()
$ok      = $true
$message = 'ok'

# Must be PowerShell 7+
if ($PSVersionTable.PSVersion.Major -lt 7) {
    $ok      = $false
    $message = "refresh-deps requires PowerShell 7+. Found $version. Install from https://aka.ms/powershell"
}

# Detect host OS
$hostOs = if ($IsWindows) { 'windows' } elseif ($IsMacOS) { 'macos' } else { 'linux' }

$result = [ordered]@{
    ok      = $ok
    pwsh    = $true
    version = $version
    host    = $hostOs
    message = $message
}

Write-Output ($result | ConvertTo-Json -Compress)

if (-not $ok) { exit 2 }
exit 0
