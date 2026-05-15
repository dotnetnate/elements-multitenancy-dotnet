#Requires -Version 7
# audit-project.ps1 --path <dir> --type <type> --manifest <file> [--skip-cache] [--ignore <pkg,...>]
#
# Runs a read-only dependency audit on a single project.
# Emits: {type, tool, path, manifest, cached, exitCode, format, findings, raw, stderr}
#
# Caching:  Computes MD5 of the manifest file.  If the hash matches the value
# stored in refresh-deps.cache the audit is skipped and cached:true is returned.
# On a cache miss the audit runs and the cache entry is updated.
#
# Pass --skip-cache to bypass the cache check unconditionally (forces a fresh run).
# Pass --ignore with a comma-separated list of package names to exclude from the
# outdated results (vulnerabilities are always reported regardless of this list).

. "$PSScriptRoot/_lib.ps1"
$sw = [System.Diagnostics.Stopwatch]::StartNew()

# ── Argument parsing ──────────────────────────────────────────────────────────
$path      = ''
$type      = ''
$manifest  = ''
$skipCache = $false
$ignoreRaw = @()

$i = 0
while ($i -lt $args.Count) {
    switch ($args[$i]) {
        '--path'       { $i++; $path     = $args[$i] }
        '--type'       { $i++; $type     = $args[$i] }
        '--manifest'   { $i++; $manifest = $args[$i] }
        '--skip-cache' { $skipCache = $true }
        '--ignore'     { $i++; $ignoreRaw += $args[$i] }
        default        { Write-Error "Unknown argument: $($args[$i])"; exit 1 }
    }
    $i++
}

if (-not $path)     { Exit-Fail "--path is required" }
if (-not $type)     { Exit-Fail "--type is required" }
if (-not $manifest) { Exit-Fail "--manifest is required" }

# Normalize ignore list: split comma-separated values, trim whitespace, lowercase for matching
$ignoreList = @($ignoreRaw |
    ForEach-Object { $_ -split ',' } |
    ForEach-Object { $_.Trim() } |
    Where-Object   { $_ } |
    ForEach-Object { $_.ToLower() })

$absPath = Resolve-AbsPath $path
if ([string]::IsNullOrEmpty($absPath)) { Exit-Fail "Path not found: $path" }
$absManifest = Join-Path $absPath $manifest

# ── Cache check ───────────────────────────────────────────────────────────────
$currentHash = Get-FileChecksum $absManifest
$cache       = Read-DepCache
$cacheKey    = $absPath.Replace('\','/')

$cachedEntry = if ($cache.ContainsKey($cacheKey)) { $cache[$cacheKey] } else { $null }

if (-not $skipCache -and
    $cachedEntry -ne $null -and
    $cachedEntry.hash -ne $null -and
    $cachedEntry.hash -eq $currentHash) {

    # Restore stored packages from cache; fall back to empty only if missing (old cache entry)
    $cachedPackages = if ($cachedEntry.packages) {
        $cachedEntry.packages
    } else {
        [ordered]@{ vulns = [ordered]@{ critical=0; high=0; moderate=0; low=0 }; outdated = @() }
    }
    $cachedExitCode = if ($null -ne $cachedEntry.exitCode) { [int]$cachedEntry.exitCode } else { 0 }

    # Apply ignore list to cached outdated packages (cache stores full results; filter on read)
    if ($ignoreList.Count -gt 0 -and $cachedPackages.outdated -and @($cachedPackages.outdated).Count -gt 0) {
        $ignoredPkgs = @($cachedPackages.outdated | Where-Object { $ignoreList -contains $_.name.ToString().ToLower() })
        $cachedPackages.outdated = @($cachedPackages.outdated | Where-Object { $ignoreList -notcontains $_.name.ToString().ToLower() })
        if ($ignoredPkgs.Count -gt 0) {
            $cachedPackages.ignored = @($ignoredPkgs | ForEach-Object { $_.name })
        }
    }

    $result = [ordered]@{
        type       = $type
        tool       = $type -replace '^python-','' -replace '^npm$','npm' `
                            -replace '^pnpm$','pnpm' -replace '^yarn$','yarn' `
                            -replace '^maven$','mvn' -replace '^gradle$','gradle' `
                            -replace '^dotnet$','dotnet'
        path       = $absPath
        manifest   = $manifest
        cached     = $true
        message    = "No manifest changes since last audit ($($cachedEntry.checkedAt))"
        exitCode   = $cachedExitCode
        findings   = @()
        packages   = $cachedPackages
        durationMs = [long]$sw.ElapsedMilliseconds
        raw        = ''
        stderr     = ''
    }
    Write-Output ($result | ConvertTo-Json -Compress -Depth 10)
    exit 0
}

# ── Tool availability ─────────────────────────────────────────────────────────
$toolMap = @{
    'npm'           = 'npm'
    'pnpm'          = 'pnpm'
    'yarn'          = 'yarn'
    'dotnet'        = 'dotnet'
    'maven'         = 'mvn'
    'gradle'        = 'gradle'
    'python-pip'    = 'pip'
    'python-poetry' = 'poetry'
    'python-uv'     = 'uv'
}
$tool = $toolMap[$type]
if (-not $tool) { Exit-Fail "Unknown project type: $type" }
if (-not (Test-Cmd $tool)) {
    $r = [ordered]@{
        type     = $type; tool = $tool; path = $absPath; manifest = $manifest
        cached   = $false; exitCode = -1; format = 'error'
        findings = @(); raw = ''; stderr = "tool-missing: $tool not on PATH"
    }
    Write-Output ($r | ConvertTo-Json -Compress -Depth 10)
    exit 0
}

# ── Run audit ─────────────────────────────────────────────────────────────────
$format    = 'text'
$raw       = ''
$stderrOut = ''
$exitCode  = 0
$findings  = @()
$packages  = [ordered]@{
    vulns    = [ordered]@{ critical = 0; high = 0; moderate = 0; low = 0 }
    outdated = @()
}

switch ($type) {

    'npm' {
        $format = 'json'
        # outdated
        $out = Invoke-External -WorkingDir $absPath -Command $tool `
                               -Arguments @('outdated','--json')
        # npm outdated exits 1 when any package is outdated; that is expected
        $outdatedRaw = $out.stdout
        $stderrOut  += $out.stderr

        # security audit
        $out2 = Invoke-External -WorkingDir $absPath -Command $tool `
                                -Arguments @('audit','--json')
        $auditRaw   = $out2.stdout
        $stderrOut += $out2.stderr
        $exitCode   = $out2.exitCode

        $raw = "{`"outdated`":$outdatedRaw,`"audit`":$auditRaw}"
        try {
            $parsed = $raw | ConvertFrom-Json -ErrorAction Stop
            if ($parsed.audit.metadata.vulnerabilities) {
                $v = $parsed.audit.metadata.vulnerabilities
                $packages.vulns = [ordered]@{
                    critical = [int]$v.critical
                    high     = [int]$v.high
                    moderate = [int]$v.moderate
                    low      = [int]$v.low
                }
                $findings += "critical=$($v.critical) high=$($v.high) moderate=$($v.moderate) low=$($v.low)"
            }
            if ($parsed.outdated) {
                $outdatedList = foreach ($prop in $parsed.outdated.PSObject.Properties) {
                    [ordered]@{
                        name    = $prop.Name
                        current = if ($prop.Value.PSObject.Properties['current'] -and $prop.Value.current) { "$($prop.Value.current)" } else { '—' }
                        wanted  = "$($prop.Value.wanted)"
                        latest  = "$($prop.Value.latest)"
                    }
                }
                $packages.outdated = @($outdatedList)
                if ($packages.outdated.Count -gt 0) {
                    $findings += "$($packages.outdated.Count) package(s) outdated"
                }
            }
        } catch {}
    }

    'pnpm' {
        $format = 'json'
        $out = Invoke-External -WorkingDir $absPath -Command $tool `
                               -Arguments @('audit','--json')
        $raw = $out.stdout; $stderrOut = $out.stderr; $exitCode = $out.exitCode
        try {
            $parsed = $raw | ConvertFrom-Json -ErrorAction Stop
            if ($parsed.metadata.vulnerabilities) {
                $v = $parsed.metadata.vulnerabilities
                $findings += "critical=$($v.critical) high=$($v.high) moderate=$($v.moderate) low=$($v.low)"
            }
        } catch {}
    }

    'yarn' {
        $format = 'text'
        $out = Invoke-External -WorkingDir $absPath -Command $tool `
                               -Arguments @('audit','--level','info')
        $raw = $out.stdout; $stderrOut = $out.stderr; $exitCode = $out.exitCode
    }

    'dotnet' {
        $format     = 'json'
        $hasCpm     = Test-Path (Join-Path $absPath 'Directory.Packages.props') -PathType Leaf
        $outdatedArgs = if ($hasCpm) {
            @('list','package','--outdated','--format','json','--include-transitive')
        } else {
            @('list','package','--outdated','--format','json')
        }
        $outOutdated = Invoke-External -WorkingDir $absPath -Command $tool -Arguments $outdatedArgs
        $outVuln     = Invoke-External -WorkingDir $absPath -Command $tool `
                           -Arguments @('list','package','--vulnerable','--include-transitive','--format','json')
        $stderrOut   = $outOutdated.stderr + $outVuln.stderr
        $exitCode    = if ($outOutdated.exitCode -ne 0) { $outOutdated.exitCode } else { $outVuln.exitCode }
        $raw         = "{`"outdated`":$($outOutdated.stdout),`"vulnerable`":$($outVuln.stdout)}"

        # Parse outdated packages
        try {
            $parsedOutdated = $outOutdated.stdout | ConvertFrom-Json -ErrorAction Stop
            $outdatedList = foreach ($proj in $parsedOutdated.projects) {
                $projName = [System.IO.Path]::GetFileNameWithoutExtension($proj.path)
                foreach ($fw in $proj.frameworks) {
                    foreach ($pkg in $fw.topLevelPackages) {
                        if ($pkg.latestVersion -and $pkg.resolvedVersion -ne $pkg.latestVersion) {
                            [ordered]@{
                                name    = $pkg.id
                                current = $pkg.resolvedVersion
                                latest  = $pkg.latestVersion
                                project = $projName
                            }
                        }
                    }
                }
            }
            $packages.outdated = @($outdatedList | Where-Object { $_ })
            if ($packages.outdated.Count -gt 0) {
                $findings += "$($packages.outdated.Count) package(s) outdated"
            }
        } catch {}

        # Parse vulnerable packages (dotnet list package --vulnerable, SDK 9+)
        try {
            $parsedVuln = $outVuln.stdout | ConvertFrom-Json -ErrorAction Stop
            $vulnList = foreach ($proj in $parsedVuln.projects) {
                foreach ($fw in $proj.frameworks) {
                    foreach ($pkg in (@($fw.topLevelPackages) + @($fw.transitivePackages) | Where-Object { $_ })) {
                        foreach ($sev in $pkg.severities) {
                            [ordered]@{
                                name     = $pkg.id
                                version  = $pkg.resolvedVersion
                                severity = $sev.severity
                                advisory = $sev.advisoryUrl
                            }
                        }
                    }
                }
            }
            $vulnList = @($vulnList | Where-Object { $_ })
            if ($vulnList.Count -gt 0) {
                $packages.vulns = [ordered]@{
                    critical = ($vulnList | Where-Object { $_.severity -imatch '^critical$' } | Measure-Object).Count
                    high     = ($vulnList | Where-Object { $_.severity -imatch '^high$'     } | Measure-Object).Count
                    moderate = ($vulnList | Where-Object { $_.severity -imatch '^moderate$' } | Measure-Object).Count
                    low      = ($vulnList | Where-Object { $_.severity -imatch '^low$'      } | Measure-Object).Count
                }
                $packages.vulnPackages = $vulnList
                $v = $packages.vulns
                $findings += "critical=$($v.critical) high=$($v.high) moderate=$($v.moderate) low=$($v.low)"
            }
        } catch {}
    }

    'maven' {
        $format = 'text'
        # Use versions plugin if available, else versions:display-dependency-updates
        $out = Invoke-External -WorkingDir $absPath -Command $tool `
            -Arguments @('versions:display-dependency-updates','-DprocessAllModules=true','-DgenerateBackupPoms=false')
        $raw = $out.stdout; $stderrOut = $out.stderr; $exitCode = $out.exitCode
        $upgradeLines = $raw -split "`n" | Where-Object { $_ -match '->' }
        if ($upgradeLines) { $findings += "$($upgradeLines.Count) upgrade(s) available" }
    }

    'gradle' {
        $format = 'text'
        # Require ben-manes dependency-updates plugin; otherwise report not-supported
        $hasDeps = (Get-Content (Join-Path $absPath $manifest) -Raw -ErrorAction SilentlyContinue) `
                   -match 'com.github.ben-manes.versions'
        if (-not $hasDeps) {
            $r = [ordered]@{
                type = $type; tool = $tool; path = $absPath; manifest = $manifest
                cached = $false; exitCode = 0; format = 'text'
                findings = @('ben-manes versions plugin not detected — add it for full auditing')
                raw = ''; stderr = ''
            }
            Write-Output ($r | ConvertTo-Json -Compress -Depth 10)
            exit 0
        }
        $gradlew = Join-Path $absPath 'gradlew'
        $gradleCmd = if (Test-Path $gradlew -PathType Leaf) { $gradlew } else { $tool }
        $out = Invoke-External -WorkingDir $absPath -Command $gradleCmd `
                               -Arguments @('dependencyUpdates','-Drevision=release')
        $raw = $out.stdout; $stderrOut = $out.stderr; $exitCode = $out.exitCode
    }

    { $_ -in 'python-pip','python-poetry','python-uv' } {
        $format = 'json'
        switch ($type) {
            'python-pip' {
                $out = Invoke-External -WorkingDir $absPath -Command 'pip' `
                                       -Arguments @('list','--outdated','--format','json')
                $raw = $out.stdout
            }
            'python-poetry' {
                $out = Invoke-External -WorkingDir $absPath -Command 'poetry' `
                                       -Arguments @('show','--outdated')
                $raw = $out.stdout; $format = 'text'
            }
            'python-uv' {
                $out = Invoke-External -WorkingDir $absPath -Command 'uv' `
                                       -Arguments @('pip','list','--outdated')
                $raw = $out.stdout; $format = 'text'
            }
        }
        $stderrOut = $out.stderr; $exitCode = $out.exitCode
        $lines = $raw -split "`n" | Where-Object { $_.Trim() -ne '' }
        if ($lines.Count -gt 0) { $findings += "$($lines.Count) package(s) outdated" }
    }
}

# ── Update cache (store full unfiltered results so cache is ignore-list-agnostic) ────
if (-not [string]::IsNullOrEmpty($currentHash)) {
    $cache = Read-DepCache
    $cache[$cacheKey] = @{
        manifest  = $manifest
        hash      = $currentHash
        checkedAt = (Get-Date -Format 'o')
        exitCode  = $exitCode
        packages  = $packages
    }
    Save-DepCache -Cache $cache
}

# ── Apply ignore list (after cache write — cache always stores full results) ────────────
if ($ignoreList.Count -gt 0 -and $packages.outdated.Count -gt 0) {
    $ignoredPkgs       = @($packages.outdated | Where-Object { $ignoreList -contains $_.name.ToLower() })
    $packages.outdated = @($packages.outdated | Where-Object { $ignoreList -notcontains $_.name.ToLower() })
    if ($ignoredPkgs.Count -gt 0) {
        $packages.ignored = @($ignoredPkgs | ForEach-Object { $_.name })
    }
}

$result = [ordered]@{
    type       = $type
    tool       = $tool
    path       = $absPath
    manifest   = $manifest
    cached     = $false
    exitCode   = $exitCode
    format     = $format
    findings   = $findings
    packages   = $packages
    durationMs = [long]$sw.ElapsedMilliseconds
    raw        = $raw
    stderr     = $stderrOut
}

Write-Output ($result | ConvertTo-Json -Compress -Depth 10)
exit 0
