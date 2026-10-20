param([string]$ExpectedVersion = '')
# Runs only on an isolated Windows CI desktop. Exercises the production signed feed/helper.
$ErrorActionPreference = 'Stop'
[Net.ServicePointManager]::SecurityProtocol = [Net.SecurityProtocolType]::Tls12
. "$PSScriptRoot/../packaging/windows/update-core.ps1"
$fixture=Join-Path $env:RUNNER_TEMP ('earth signed update ' + [guid]::NewGuid().ToString())
$root=Join-Path $fixture 'Living Earth 3D'
New-Item -ItemType Directory -Path $fixture -Force | Out-Null
$old=Join-Path $fixture 'baseline.exe'
Invoke-WebRequest -UseBasicParsing 'https://raw.githubusercontent.com/nortja/Living-earth-3d/downloads/windows-0.5.2/LivingEarth3D-Setup-0.5.2.exe' -OutFile $old
if ((Get-FileHash $old -Algorithm SHA256).Hash.ToLowerInvariant() -ne '78a011d3d7aee0f195a2ecc2605858e3133206b67161a96103bc0870acdd530b') { throw 'Baseline checksum mismatch' }
$p=Start-Process $old -ArgumentList "/S /D=$root" -PassThru -Wait
if ($p.ExitCode -ne 0) { throw 'Baseline install failed' }
# Bootstrap only the new helper/trust key into the old fixture to exercise an actual newer release.
Copy-Item "$PSScriptRoot/../packaging/windows/update.ps1" $root
Copy-Item "$PSScriptRoot/../packaging/windows/update-core.ps1" $root
$before=(Get-FileHash "$root/LivingEarth3D.exe" -Algorithm SHA256).Hash
$app=Start-Process "$root/LivingEarth3D.exe" -ArgumentList '--headless --quit-after 6000' -PassThru
function Start-Worker([switch]$Cancel) {
    $arguments=@('-NoProfile','-NonInteractive','-ExecutionPolicy','Bypass','-File',('"'+$root+'/update.ps1"'),'-CurrentVersion','0.5.2','-AppProcessId',[string]$app.Id)
    if ($Cancel) { $arguments += '-Cancel' }
    return Start-Process powershell.exe -ArgumentList $arguments -PassThru
}
function Read-Status {
    try { return Get-Content "$root/.updates/status.json" -Raw | ConvertFrom-Json } catch { return $null }
}
$worker=Start-Worker
$deadline=[DateTime]::UtcNow.AddSeconds(80)
$ready=$false
while ([DateTime]::UtcNow -lt $deadline) {
    $status=Read-Status
    if ($status.state -eq 'error') { throw $status.message }
    if ($status.state -eq 'ready') { $ready=$true;break }
    Start-Sleep -Milliseconds 500
}
if (!$ready -or $app.HasExited) { throw 'Update did not stage while the app remained open' }
if ((Get-FileHash "$root/LivingEarth3D.exe" -Algorithm SHA256).Hash -ne $before) { throw 'App was replaced while open' }
$cancel=Start-Worker -Cancel
if (!$cancel.WaitForExit(30000) -or !$worker.WaitForExit(30000)) { throw 'Cancellation did not complete' }
if ((Read-Status).state -ne 'paused' -or (Get-FileHash "$root/LivingEarth3D.exe" -Algorithm SHA256).Hash -ne $before) { throw 'Cancellation changed the installed app' }
Write-Output 'PASS: production signed release downloads and waits; cancellation leaves app unchanged'
Remove-Item "$root/.updates/cancel" -Force
$worker=Start-Worker
if (!$worker.WaitForExit(150000)) { throw 'Normal-exit update timed out' }
if ((Read-Status).state -ne 'installed') { throw ('Automatic update failed: ' + (Read-Status).message) }
if (!$app.HasExited) { throw 'Update finished before app exited' }
$manifestPath=Join-Path $fixture 'manifest.json';$signaturePath=Join-Path $fixture 'manifest.sig'
Receive-EarthFile 'https://raw.githubusercontent.com/nortja/Living-earth-3d/main/updates/application.json' $manifestPath 65536
Receive-EarthFile 'https://raw.githubusercontent.com/nortja/Living-earth-3d/main/updates/application.sig' $signaturePath 2048
$manifest=Read-EarthManifest ([IO.File]::ReadAllBytes($manifestPath)) ([Convert]::FromBase64String([IO.File]::ReadAllText($signaturePath).Trim()))
if ($ExpectedVersion -and $manifest.version -ne $ExpectedVersion) { throw ('Production version differs from expected release: ' + $manifest.version) }
Confirm-EarthFiles $root $manifest
if (@(Get-EarthProcesses $root).Count) { throw 'Normal exit unexpectedly restarted the app' }
Write-Output 'PASS: production helper verifies live signature/download, installs after normal exit, verifies files and does not reopen an intentionally closed app'
$uninstall=Start-Process "$root/Uninstall.exe" -ArgumentList "/S _?=$root" -PassThru -Wait
if ($uninstall.ExitCode -ne 0) { throw 'Cleanup uninstall failed' }
Remove-Item $fixture -Recurse -Force
