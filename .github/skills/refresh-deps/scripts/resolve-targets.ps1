#Requires -Version 7
# resolve-targets.ps1 [--workspace <path>]... <target> [<target> ...]
# Resolves user-supplied names or paths to absolute directories.
# Emits a JSON array of {input, resolved, source, error} objects.
# Always exits 0 so all failures can be surfaced at once.

. "$PSScriptRoot/_lib.ps1"

$workspaces = [System.Collections.Generic.List[string]]::new()
$targets    = [System.Collections.Generic.List[string]]::new()

$i = 0
$args_list = $args
while ($i -lt $args_list.Count) {
    switch ($args_list[$i]) {
        '--workspace' {
            $i++
            if ($i -ge $args_list.Count) { Exit-Fail "--workspace requires a value" }
            $workspaces.Add($args_list[$i])
            $i++
        }
        default {
            $targets.Add($args_list[$i])
            $i++
        }
    }
}

if ($targets.Count -eq 0) {
    Exit-Fail "usage: resolve-targets.ps1 [--workspace <path>]... <target> [<target> ...]"
}

# Build deduplicated, existing workspace roots.
$wsRoots = [System.Collections.Generic.List[string]]::new()
foreach ($w in $workspaces) {
    $abs = Resolve-AbsPath $w
    if ([string]::IsNullOrEmpty($abs)) { continue }
    if (-not (Test-Path $abs -PathType Container)) { continue }
    if (-not ($wsRoots -contains $abs)) { $wsRoots.Add($abs) }
}

function Resolve-Target {
    param([string]$Input)

    # 1. Absolute path that exists.
    $abs = Resolve-AbsPath $Input
    if (-not [string]::IsNullOrEmpty($abs) -and (Test-Path $abs -PathType Container)) {
        return @{ input = $Input; resolved = $abs; source = 'absolute'; error = '' }
    }

    # 2. Relative to CWD.
    $rel = Join-Path (Get-Location).Path $Input
    $rel = Resolve-AbsPath $rel
    if (-not [string]::IsNullOrEmpty($rel) -and (Test-Path $rel -PathType Container)) {
        return @{ input = $Input; resolved = $rel; source = 'cwd-relative'; error = '' }
    }

    # 3. Basename match against a workspace root.
    $name = [System.IO.Path]::GetFileName($Input.TrimEnd([IO.Path]::DirectorySeparatorChar, '/'))
    foreach ($ws in $wsRoots) {
        if ([System.IO.Path]::GetFileName($ws) -eq $name) {
            return @{ input = $Input; resolved = $ws; source = 'workspace-basename'; error = '' }
        }
    }

    # 4. Child directory inside any workspace root.
    foreach ($ws in $wsRoots) {
        $candidate = Join-Path $ws $name
        if (Test-Path $candidate -PathType Container) {
            return @{ input = $Input; resolved = $candidate; source = 'workspace-child'; error = '' }
        }
    }

    # 5. Sibling of any workspace root (peer checkout).
    foreach ($ws in $wsRoots) {
        $candidate = Join-Path (Split-Path $ws -Parent) $name
        if (Test-Path $candidate -PathType Container) {
            return @{ input = $Input; resolved = $candidate; source = 'workspace-sibling'; error = '' }
        }
    }

    return @{ input = $Input; resolved = ''; source = ''; error = "could not resolve target: $Input" }
}

$results = @()
foreach ($t in $targets) {
    $results += Resolve-Target -Input $t
}

Write-Output ($results | ConvertTo-Json -Compress -Depth 5)
exit 0
