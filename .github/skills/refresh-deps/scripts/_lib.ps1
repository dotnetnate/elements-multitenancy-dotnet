# _lib.ps1 — shared helpers for refresh-deps PowerShell scripts.
# Dot-source via:  . "$PSScriptRoot/_lib.ps1"

function Exit-Fail {
    param([string]$Message, [int]$Code = 1)
    Write-Error "refresh-deps: $Message"
    exit $Code
}

function Test-Cmd {
    param([string]$Name)
    $null -ne (Get-Command $Name -ErrorAction SilentlyContinue)
}

# Resolve a path to its absolute, canonical form.  Returns '' if unreachable.
function Resolve-AbsPath {
    param([string]$Path)
    if ([string]::IsNullOrWhiteSpace($Path)) { return '' }
    try {
        $rp = [System.IO.Path]::GetFullPath($Path)
        if (Test-Path $rp) { return (Resolve-Path $rp).Path }
        return $rp
    } catch { return '' }
}

# Emit a compact JSON object from a hashtable. Keys must be strings; values
# may be strings, numbers, booleans, arrays, or nested hashtables.
function ConvertTo-CompactJson {
    param($Value)
    $Value | ConvertTo-Json -Compress -Depth 20
}

# MD5 checksum of a file.  Returns '' if the file is missing.
function Get-FileChecksum {
    param([string]$Path)
    if (-not (Test-Path $Path -PathType Leaf)) { return '' }
    (Get-FileHash -Algorithm MD5 -Path $Path).Hash
}

# Path to the shared cache file (lives next to the scripts).
function Get-CacheFilePath {
    Join-Path $PSScriptRoot 'refresh-deps.cache'
}

function Read-DepCache {
    $p = Get-CacheFilePath
    if (-not (Test-Path $p -PathType Leaf)) { return @{} }
    try {
        $raw = Get-Content $p -Raw -Encoding UTF8
        $obj = $raw | ConvertFrom-Json -AsHashtable -ErrorAction Stop
        return $obj
    } catch { return @{} }
}

function Save-DepCache {
    param([hashtable]$Cache)
    $p = Get-CacheFilePath
    $Cache | ConvertTo-Json -Depth 5 | Set-Content -Path $p -Encoding UTF8 -NoNewline
}

# Run an external command in a given directory, capture stdout+stderr+exit code.
# Returns a hashtable: {stdout, stderr, exitCode}
function Invoke-External {
    param(
        [string]$WorkingDir,
        [string]$Command,
        [string[]]$Arguments = @()
    )
    # Resolve the command to its full path so ProcessStartInfo can launch it.
    # On Windows: prefer .cmd/.bat over .ps1; .ps1 cannot be launched directly
    # by ProcessStartInfo, so wrap it through pwsh. .cmd files can be launched
    # via their full path with UseShellExecute = false.
    $allMatches = @(Get-Command $Command -All -ErrorAction SilentlyContinue)
    $cmdMatch   = $allMatches | Where-Object { $_.Source -match '\.(cmd|bat|exe|com)$' } | Select-Object -First 1
    $ps1Match   = $allMatches | Where-Object { $_.Source -match '\.ps1$' } | Select-Object -First 1
    $anyMatch   = $allMatches | Select-Object -First 1

    $resolved   = if ($cmdMatch) { $cmdMatch.Source }
                  elseif ($anyMatch) { $anyMatch.Source }
                  else { $Command }

    # If the resolved path is a .ps1 script, delegate execution to pwsh.
    $extraArgs = [System.Collections.Generic.List[string]]::new()
    if ($resolved -match '\.ps1$') {
        $extraArgs.Add('-NoProfile')
        $extraArgs.Add('-File')
        $extraArgs.Add($resolved)
        $resolved = (Get-Command pwsh -ErrorAction SilentlyContinue)?.Source ?? 'pwsh'
    }

    $psi = [System.Diagnostics.ProcessStartInfo]::new()
    $psi.FileName               = $resolved
    $psi.WorkingDirectory       = $WorkingDir
    $psi.RedirectStandardOutput = $true
    $psi.RedirectStandardError  = $true
    $psi.UseShellExecute        = $false
    $psi.CreateNoWindow         = $true
    foreach ($a in $extraArgs)  { $psi.ArgumentList.Add($a) }
    foreach ($a in $Arguments)  { $psi.ArgumentList.Add($a) }

    $proc = [System.Diagnostics.Process]::new()
    $proc.StartInfo = $psi
    $null = $proc.Start()
    $stdout = $proc.StandardOutput.ReadToEnd()
    $stderr = $proc.StandardError.ReadToEnd()
    $proc.WaitForExit()

    return @{ stdout = $stdout; stderr = $stderr; exitCode = $proc.ExitCode }
}
