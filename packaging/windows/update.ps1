# Installed per-user helper. Authenticated releases apply on normal app exit.
param([string]$CurrentVersion = '0.8.0', [int]$AppProcessId = 0, [switch]$RestartNow, [switch]$Cancel)
$ErrorActionPreference = 'Stop'
. (Join-Path $PSScriptRoot 'update-core.ps1')
$installRoot = [IO.Path]::GetFullPath($PSScriptRoot)
$stateRoot = Join-Path $installRoot '.updates'
New-Item -ItemType Directory -Path $stateRoot -Force | Out-Null
$cancelPath = Join-Path $stateRoot 'cancel'
$restartPath = Join-Path $stateRoot 'restart'
if ($Cancel) { [IO.File]::WriteAllText($cancelPath, 'cancel'); return }
if ($RestartNow) { [IO.File]::WriteAllText($restartPath, [string]$AppProcessId) }
$mutex = $null; $ownsMutex = $false; $work = $null
function Set-EarthUpdateStatus([string]$State, [string]$Message) {
    $json = @{state=$State; message=$Message; utc=[DateTime]::UtcNow.ToString('o')} | ConvertTo-Json -Compress
    $temporary = Join-Path $stateRoot 'status.tmp'
    [IO.File]::WriteAllText($temporary, $json)
    Move-Item -LiteralPath $temporary -Destination (Join-Path $stateRoot 'status.json') -Force
}
try {
    $hash = [Security.Cryptography.SHA256]::Create()
    try { $instance = [BitConverter]::ToString($hash.ComputeHash([Text.Encoding]::UTF8.GetBytes($installRoot.ToLowerInvariant()))).Replace('-','') } finally { $hash.Dispose() }
    $mutex = [Threading.Mutex]::new($false, "Local\LivingEarth3D.Updater.$instance")
    try { $ownsMutex = $mutex.WaitOne(0) } catch [Threading.AbandonedMutexException] { $ownsMutex = $true }
    if (!$ownsMutex) { return }
    if ($CurrentVersion -cnotmatch '^(0|[1-9]\d*)\.(0|[1-9]\d*)\.(0|[1-9]\d*)$') { throw 'Invalid installed version.' }
    if (Test-Path -LiteralPath $cancelPath) { Set-EarthUpdateStatus 'paused' 'Automatic updates are paused.'; return }
    [Net.ServicePointManager]::SecurityProtocol = [Net.SecurityProtocolType]::Tls12
    $work = Join-Path $stateRoot ([guid]::NewGuid().ToString())
    New-Item -ItemType Directory -Path $work | Out-Null
    Set-EarthUpdateStatus 'checking' 'Checking authenticated updates...'
    $manifestPath = Join-Path $work 'application.json'
    $signaturePath = Join-Path $work 'application.sig'
    Receive-EarthFile 'https://raw.githubusercontent.com/nortja/Living-earth-3d/main/updates/application.json' $manifestPath 65536 $cancelPath
    Receive-EarthFile 'https://raw.githubusercontent.com/nortja/Living-earth-3d/main/updates/application.sig' $signaturePath 2048 $cancelPath
    $manifest = Read-EarthManifest ([IO.File]::ReadAllBytes($manifestPath)) ([Convert]::FromBase64String([IO.File]::ReadAllText($signaturePath).Trim()))
    if ([version]$manifest.version -le [version]$CurrentVersion) { Set-EarthUpdateStatus 'current' "You're up to date - $CurrentVersion"; return }
    Set-EarthUpdateStatus 'downloading' "Downloading verified version $($manifest.version)..."
    $installer = Join-Path $work 'LivingEarth3D-Update.exe'
    Receive-EarthFile $manifest.installer_url $installer $manifest.size $cancelPath
    Confirm-EarthInstaller $installer $manifest
    Set-EarthUpdateStatus 'ready' "Version $($manifest.version) is ready. It will install when you close Living Earth."
    $restart = $false
    $deadline = [DateTime]::UtcNow.AddDays(7)
    while (@(Get-EarthProcesses $installRoot).Count) {
        if ((Test-Path -LiteralPath $cancelPath) -or [DateTime]::UtcNow -gt $deadline) { Set-EarthUpdateStatus 'paused' 'Update deferred. Your current app is unchanged.'; return }
        if (Test-Path -LiteralPath $restartPath) {
            $requestedId = 0
            [int]::TryParse([IO.File]::ReadAllText($restartPath).Trim(), [ref]$requestedId) | Out-Null
            foreach ($app in @(Get-EarthProcesses $installRoot)) {
                if ($app.Id -eq $requestedId) {
                    if (!$app.CloseMainWindow()) { throw 'Please close Living Earth to finish updating.' }
                    if (!$app.WaitForExit(30000)) { throw 'The app is still running. No files were replaced.' }
                    $restart = $true
                }
            }
            Remove-Item -LiteralPath $restartPath -Force -ErrorAction SilentlyContinue
        }
        Start-Sleep -Milliseconds 1000
    }
    if (Test-Path -LiteralPath $cancelPath) { Set-EarthUpdateStatus 'paused' 'Update cancelled. Your current app is unchanged.'; return }
    Set-EarthUpdateStatus 'installing' 'Installing verified update...'
    Install-EarthRelease $installRoot $installer $manifest (Join-Path $stateRoot 'previous')
    Set-EarthUpdateStatus 'installed' "Updated to $($manifest.version)."
    if ($restart) { Start-Process -FilePath (Join-Path $installRoot 'LivingEarth3D.exe') }
} catch {
    # Background failures are non-modal and never block offline exploration.
    if (Test-Path -LiteralPath $cancelPath) { Set-EarthUpdateStatus 'paused' 'Automatic updates are paused.' }
    else { Set-EarthUpdateStatus 'error' ('Update deferred: ' + $_.Exception.Message) }
} finally {
    if ($work -and (Test-Path -LiteralPath $work)) { Remove-Item -LiteralPath $work -Recurse -Force -ErrorAction SilentlyContinue }
    if ($ownsMutex) {
        Remove-Item -LiteralPath $restartPath -Force -ErrorAction SilentlyContinue
        $mutex.ReleaseMutex()
    }
    if ($mutex) { $mutex.Dispose() }
}
