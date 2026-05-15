#Requires -Version 7
# update-project.ps1 --path <dir> --type <type> --manifest <file> [--major] [--ignore <pkg,...>]
#
# Runs a dependency update for a single project.
# Emits: {type, tool, path, manifest, strategy, exitCode, stdout, stderr}
#
# Default strategy: in-range (respects semver ranges in manifests).
# Pass --major to allow major-version upgrades (requires explicit user consent).
# Pass --ignore with a comma-separated list of package names to skip during the update.

. "$PSScriptRoot/_lib.ps1"

# ── Argument parsing ──────────────────────────────────────────────────────────
$path      = ''
$type      = ''
$manifest  = ''
$major     = $false
$ignoreRaw = @()

$i = 0
while ($i -lt $args.Count) {
    switch ($args[$i]) {
        '--path'     { $i++; $path     = $args[$i] }
        '--type'     { $i++; $type     = $args[$i] }
        '--manifest' { $i++; $manifest = $args[$i] }
        '--major'    { $major = $true }
        '--ignore'   { $i++; $ignoreRaw += $args[$i] }
        default      { Write-Error "Unknown argument: $($args[$i])"; exit 1 }
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

$strategy = if ($major) { 'major' } else { 'in-range' }

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
        type = $type; tool = $tool; path = $absPath; manifest = $manifest
        strategy = $strategy; exitCode = -1
        stdout = ''; stderr = "tool-missing: $tool not on PATH"
    }
    Write-Output ($r | ConvertTo-Json -Compress -Depth 10)
    exit 0
}

$stdout    = ''
$stderrOut = ''
$exitCode  = 0

switch ($type) {

    'npm' {
        if ($major) {
            # npx npm-check-updates --upgrade (writes package.json in-place) then install
            if (Test-Cmd 'npx') {
                $out = Invoke-External -WorkingDir $absPath -Command 'npx' `
                    -Arguments @('-y','npm-check-updates','--upgrade')
                $stdout    += $out.stdout
                $stderrOut += $out.stderr
            }
        }
        $out = Invoke-External -WorkingDir $absPath -Command $tool -Arguments @('update')
        $stdout    += $out.stdout; $stderrOut += $out.stderr; $exitCode = $out.exitCode
    }

    'pnpm' {
        $updateArgs = if ($major) { @('update','--latest') } else { @('update') }
        $out = Invoke-External -WorkingDir $absPath -Command $tool -Arguments $updateArgs
        $stdout = $out.stdout; $stderrOut = $out.stderr; $exitCode = $out.exitCode
    }

    'yarn' {
        $out = Invoke-External -WorkingDir $absPath -Command $tool -Arguments @('upgrade')
        $stdout = $out.stdout; $stderrOut = $out.stderr; $exitCode = $out.exitCode
    }

    'dotnet' {
        # ── SDK group definitions ─────────────────────────────────────────────
        # Packages managed by a project SDK (via Sdk="Name/x.y.z" attribute).
        # 'versionedWith': share the SDK version — updated by bumping the Sdk attr.
        # 'overridable':   have their own version number — updated via PackageReference Update XML edit.
        $sdkGroups = [ordered]@{
            'MSTest.Sdk' = [ordered]@{
                attr          = 'MSTest\.Sdk'
                versionedWith = [string[]]@('MSTest.TestAdapter', 'MSTest.TestFramework', 'MSTest.Analyzers')
                overridable   = [string[]]@('Microsoft.NET.Test.Sdk')
            }
        }
        # Build reverse lookup: lowercase package id → {sdk, kind}
        $sdkManagedBy = @{}
        foreach ($sdkName in $sdkGroups.Keys) {
            foreach ($pkg in $sdkGroups[$sdkName].versionedWith) {
                $sdkManagedBy[$pkg.ToLower()] = @{ sdk = $sdkName; kind = 'versioned' }
            }
            foreach ($pkg in $sdkGroups[$sdkName].overridable) {
                $sdkManagedBy[$pkg.ToLower()] = @{ sdk = $sdkName; kind = 'overridable' }
            }
        }

        # Ensure dotnet-outdated is available; install globally if missing.
        if (-not (Test-Cmd 'dotnet-outdated')) {
            $installOut = Invoke-External -WorkingDir $absPath -Command $tool `
                          -Arguments @('tool','install','-g','dotnet-outdated-tool')
            $stdout    += $installOut.stdout
            $stderrOut += $installOut.stderr
            if ($installOut.exitCode -ne 0) {
                # Installation failed — fall through to the XML-edit fallback below.
                $stderrOut += "`nWARN: dotnet-outdated-tool installation failed; using built-in fallback."
            }
        }

        # dotnet has no built-in "update all"; prefer dotnet-outdated when available.
        if (Test-Cmd 'dotnet-outdated') {
            $upgradeArgs = if ($major) { @('-u','Major') } else { @('-u','Minor') }
            foreach ($pkg in $ignoreList) { $upgradeArgs += @('--exclude', $pkg) }
            $out = Invoke-External -WorkingDir $absPath -Command 'dotnet-outdated' `
                                   -Arguments $upgradeArgs
            $stdout += $out.stdout; $stderrOut += $out.stderr; $exitCode = $out.exitCode
        } else {
            # Fallback: enumerate outdated packages from dotnet list and upgrade individually.
            $listOut = Invoke-External -WorkingDir $absPath -Command $tool `
                       -Arguments @('list','package','--outdated','--format','json')
            $stderrOut = $listOut.stderr
            try {
                $parsed = $listOut.stdout | ConvertFrom-Json -ErrorAction Stop
                # sdkVersionQueue:  { projPath -> { sdkName -> targetVersion } }  (Sdk attr bump)
                # pkgOverrideQueue: { projPath -> { pkgId  -> targetVersion } }   (PackageReference Update XML edit)
                $sdkVersionQueue  = [ordered]@{}
                $pkgOverrideQueue = [ordered]@{}

                foreach ($proj in $parsed.projects) {
                    foreach ($fw in $proj.frameworks) {
                        foreach ($pkg in $fw.topLevelPackages) {
                            if ($pkg.resolvedVersion -eq $pkg.latestVersion) { continue }

                            # Apply ignore list (case-insensitive)
                            if ($ignoreList -contains $pkg.id.ToLower()) {
                                $stdout += "info : Skipped (ignored): $($pkg.id)`n"
                                continue
                            }

                            # Compute target version; for in-range, only upgrade within same major
                            $target = if ($major) {
                                $pkg.latestVersion
                            } else {
                                try {
                                    $latVer = [System.Version]::Parse($pkg.latestVersion)
                                    $curVer = [System.Version]::Parse($pkg.resolvedVersion)
                                    if ($latVer.Major -eq $curVer.Major) { $pkg.latestVersion } else { $pkg.resolvedVersion }
                                } catch { $pkg.latestVersion }
                            }
                            if ($target -eq $pkg.resolvedVersion) { continue }

                            # Route SDK-managed packages to the appropriate upgrade queue
                            $sdkEntry = $sdkManagedBy[$pkg.id.ToLower()]
                            if ($sdkEntry) {
                                if ($sdkEntry.kind -eq 'versioned') {
                                    # Bump the Sdk attribute; keep the highest target seen for this SDK
                                    if (-not $sdkVersionQueue.Contains($proj.path)) { $sdkVersionQueue[$proj.path] = [ordered]@{} }
                                    $q  = $sdkVersionQueue[$proj.path]
                                    $sn = $sdkEntry.sdk
                                    if (-not $q.Contains($sn) -or
                                        ([System.Version]::Parse($target) -gt [System.Version]::Parse($q[$sn]))) {
                                        $q[$sn] = $target
                                    }
                                } else {
                                    # Separately versioned: update via PackageReference Update XML edit
                                    if (-not $pkgOverrideQueue.Contains($proj.path)) { $pkgOverrideQueue[$proj.path] = [ordered]@{} }
                                    $pkgOverrideQueue[$proj.path][$pkg.id] = $target
                                }
                                continue
                            }

                            # Standard package: use dotnet add
                            $addArgs = @('add', $proj.path, 'package', $pkg.id, '--version', $target, '--no-restore')
                            $addOut  = Invoke-External -WorkingDir $absPath -Command $tool -Arguments $addArgs
                            $stdout    += $addOut.stdout
                            $stderrOut += $addOut.stderr
                            if ($addOut.exitCode -ne 0) { $exitCode = $addOut.exitCode }
                        }
                    }
                }

                # ── Apply Sdk="Name/x.y.z" attribute upgrades ─────────────────
                foreach ($projPath in $sdkVersionQueue.Keys) {
                    if (-not (Test-Path $projPath -PathType Leaf)) { continue }
                    foreach ($sdkName in $sdkVersionQueue[$projPath].Keys) {
                        $sdkTarget    = $sdkVersionQueue[$projPath][$sdkName]
                        $sdkAttrRegex = $sdkGroups[$sdkName].attr
                        $content      = Get-Content $projPath -Raw -Encoding UTF8
                        $updated      = [regex]::Replace(
                            $content,
                            "(?i)(Sdk\s*=\s*`"$sdkAttrRegex/)\d+[\d.]*(`")",
                            "`${1}$sdkTarget`${2}"
                        )
                        if ($updated -ne $content) {
                            Set-Content -Path $projPath -Value $updated -Encoding UTF8 -NoNewline
                            $stdout += "info : Updated $sdkName to $sdkTarget in $([System.IO.Path]::GetFileName($projPath))`n"
                        } else {
                            # Not found as Sdk attribute — fall back to dotnet add (PackageReference pattern)
                            $addArgs = @('add', $projPath, 'package', $sdkName, '--version', $sdkTarget, '--no-restore')
                            $addOut  = Invoke-External -WorkingDir $absPath -Command $tool -Arguments $addArgs
                            $stdout    += $addOut.stdout
                            $stderrOut += $addOut.stderr
                            if ($addOut.exitCode -ne 0) { $exitCode = $addOut.exitCode }
                        }
                        # Also update PackageReference Update overrides for same-versioned managed packages
                        foreach ($managedPkg in $sdkGroups[$sdkName].versionedWith) {
                            $fresh    = Get-Content $projPath -Raw -Encoding UTF8
                            $pkgEsc   = [regex]::Escape($managedPkg)
                            $pkgPat   = "(?i)(<PackageReference[^>]*(?:Update|Include)\s*=\s*`"$pkgEsc`"[^>]*Version\s*=\s*`")\d+[\d.]*(`")"
                            $patched  = [regex]::Replace($fresh, $pkgPat, "`${1}$sdkTarget`${2}")
                            if ($patched -ne $fresh) {
                                Set-Content -Path $projPath -Value $patched -Encoding UTF8 -NoNewline
                                $stdout += "info : Updated $managedPkg override to $sdkTarget in $([System.IO.Path]::GetFileName($projPath))`n"
                            }
                        }
                    }
                }

                # ── Apply PackageReference Update overrides for separately-versioned SDK packages ──
                foreach ($projPath in $pkgOverrideQueue.Keys) {
                    if (-not (Test-Path $projPath -PathType Leaf)) { continue }
                    foreach ($pkgId in $pkgOverrideQueue[$projPath].Keys) {
                        $pkgTarget = $pkgOverrideQueue[$projPath][$pkgId]
                        $content   = Get-Content $projPath -Raw -Encoding UTF8
                        $pkgEsc    = [regex]::Escape($pkgId)
                        $pattern   = "(?i)(<PackageReference[^>]*(?:Update|Include)\s*=\s*`"$pkgEsc`"[^>]*Version\s*=\s*`")\d+[\d.]*(`")"
                        $updated   = [regex]::Replace($content, $pattern, "`${1}$pkgTarget`${2}")
                        if ($updated -ne $content) {
                            Set-Content -Path $projPath -Value $updated -Encoding UTF8 -NoNewline
                            $stdout += "info : Updated $pkgId override to $pkgTarget in $([System.IO.Path]::GetFileName($projPath))`n"
                        }
                    }
                }

            } catch {
                $stderrOut += "`nERROR: Failed to parse outdated package list."
                $exitCode = 1
            }
        }
    }

    'maven' {
        $updateArgs = if ($major) {
            @('versions:use-latest-releases','-DgenerateBackupPoms=false')
        } else {
            @('versions:update-properties','-DgenerateBackupPoms=false')
        }
        $out = Invoke-External -WorkingDir $absPath -Command $tool -Arguments $updateArgs
        $stdout = $out.stdout; $stderrOut = $out.stderr; $exitCode = $out.exitCode
    }

    'gradle' {
        $gradlew = Join-Path $absPath 'gradlew'
        $gradleCmd = if (Test-Path $gradlew -PathType Leaf) { $gradlew } else { $tool }
        # Gradle updates require the ben-manes plugin; just run dependencyUpdates as a guide.
        $out = Invoke-External -WorkingDir $absPath -Command $gradleCmd `
                               -Arguments @('dependencyUpdates','-Drevision=release')
        $stdout = $out.stdout; $stderrOut = $out.stderr; $exitCode = $out.exitCode
        $stderrOut += "`nNote: Gradle does not auto-apply updates. Review the report and update build files manually."
    }

    'python-pip' {
        # Collect outdated packages then pip install --upgrade each.
        $listOut = Invoke-External -WorkingDir $absPath -Command $tool `
                                   -Arguments @('list','--outdated','--format','json')
        $stderrOut = $listOut.stderr
        try {
            $outdated = $listOut.stdout | ConvertFrom-Json -ErrorAction Stop
            foreach ($pkg in $outdated) {
                $out = Invoke-External -WorkingDir $absPath -Command $tool `
                       -Arguments @('install','--upgrade',$pkg.name)
                $stdout    += $out.stdout
                $stderrOut += $out.stderr
                if ($out.exitCode -ne 0) { $exitCode = $out.exitCode }
            }
        } catch { $exitCode = 1 }
    }

    'python-poetry' {
        $updateArgs = if ($major) { @('update') } else { @('update') }
        $out = Invoke-External -WorkingDir $absPath -Command $tool -Arguments $updateArgs
        $stdout = $out.stdout; $stderrOut = $out.stderr; $exitCode = $out.exitCode
    }

    'python-uv' {
        $out = Invoke-External -WorkingDir $absPath -Command $tool `
                               -Arguments @('pip','install','--upgrade','-r','requirements.txt')
        $stdout = $out.stdout; $stderrOut = $out.stderr; $exitCode = $out.exitCode
    }
}

# Invalidate cache entry so the next audit reflects the updated state.
$cacheKey = $absPath.Replace('\','/')
$cache    = Read-DepCache
if ($cache.ContainsKey($cacheKey)) {
    $cache.Remove($cacheKey)
    Save-DepCache -Cache $cache
}

$result = [ordered]@{
    type     = $type
    tool     = $tool
    path     = $absPath
    manifest = $manifest
    strategy = $strategy
    exitCode = $exitCode
    stdout   = $stdout
    stderr   = $stderrOut
}

Write-Output ($result | ConvertTo-Json -Compress -Depth 10)
exit 0
