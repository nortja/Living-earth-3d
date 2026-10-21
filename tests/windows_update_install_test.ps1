param([Parameter(Mandatory=$true)][string]$Installer, [Parameter(Mandatory=$true)][string]$PayloadMetadata, [ValidateSet("0.5.2","0.6.1","0.7.0","0.8.0","0.9.0")][string]$BaselineVersion = "0.5.2")
$ErrorActionPreference = 'Stop'
. "$PSScriptRoot/../packaging/windows/update-core.ps1"
if ($env:OS -ne 'Windows_NT') { throw 'This test requires Windows' }
$Installer = (Resolve-Path $Installer).Path
$files = Get-Content $PayloadMetadata -Raw | ConvertFrom-Json
$fixture = Join-Path $env:RUNNER_TEMP ('earth update test ' + [guid]::NewGuid().ToString())
$installRoot = Join-Path $fixture 'Living Earth 3D'
New-Item -ItemType Directory -Path $fixture -Force | Out-Null
$oldInstaller = Join-Path $fixture 'old.exe'
$baselineHashes = @{ '0.9.0'='b26c5f434d1e55f76311aeba441290f16b8971dc2b906b4dd0c2668c437fe668'; '0.8.0'='40077feb61b467f2bd540bc2f18d2fccde663760c39e10fa356fb137db13a4c0'; '0.7.0'='6353f718972d3255a46aa414a3e7df2b050d3bd6b259a8e472ade54495936595'; '0.5.2'='78a011d3d7aee0f195a2ecc2605858e3133206b67161a96103bc0870acdd530b'; '0.6.1'='5471db38bb3e8b32e00bae53a42b298a386e47b13fe7f98b22071c644b8b79bf' }
Invoke-WebRequest -UseBasicParsing -Uri "https://raw.githubusercontent.com/nortja/Living-earth-3d/downloads/windows-$BaselineVersion/LivingEarth3D-Setup-$BaselineVersion.exe" -OutFile $oldInstaller
if ((Get-FileHash $oldInstaller -Algorithm SHA256).Hash.ToLowerInvariant() -ne $baselineHashes[$BaselineVersion]) { throw 'Old installer checksum mismatch' }
$setup=Start-Process $oldInstaller -ArgumentList "/S /D=$installRoot" -PassThru -Wait
if ($setup.ExitCode -ne 0) { throw 'Baseline installation failed' }
$before = (Get-FileHash (Join-Path $installRoot 'LivingEarth3D.exe') -Algorithm SHA256).Hash
$beforeCore = if (Test-Path (Join-Path $installRoot 'update-core.ps1')) { (Get-FileHash (Join-Path $installRoot 'update-core.ps1') -Algorithm SHA256).Hash } else { $null }
$sentinel = Join-Path ([Environment]::GetFolderPath('ApplicationData')) 'Godot/app_userdata/Living Earth 3D/update-test-sentinel.txt'
New-Item -ItemType Directory -Path (Split-Path $sentinel) -Force | Out-Null
[IO.File]::WriteAllText($sentinel,'user preferences must survive')
$manifest = [pscustomobject]@{size=(Get-Item $Installer).Length;sha256=(Get-FileHash $Installer -Algorithm SHA256).Hash.ToLowerInvariant();files=$files}
# A bad post-install hash forces the real rollback path after the real NSIS installer runs.
$badFiles = $files | ConvertTo-Json | ConvertFrom-Json
$badFiles.'update.ps1' = '0'*64
$bad = [pscustomobject]@{size=$manifest.size;sha256=$manifest.sha256;files=$badFiles}
$rejected = $false
try { Install-EarthRelease $installRoot $Installer $bad (Join-Path $fixture 'rollback') } catch { $rejected=$true }
if (!$rejected) { throw 'Expected update rollback did not occur' }
if ((Get-FileHash (Join-Path $installRoot 'LivingEarth3D.exe') -Algorithm SHA256).Hash -ne $before) { throw 'Rollback did not restore prior app' }
if ($beforeCore) {
    if ((Get-FileHash (Join-Path $installRoot 'update-core.ps1') -Algorithm SHA256).Hash -ne $beforeCore) { throw 'Rollback did not restore previous update core' }
} elseif (Test-Path (Join-Path $installRoot 'update-core.ps1')) { throw 'Rollback did not remove a newly introduced file' }
if ((Get-ItemProperty 'HKCU:\Software\Microsoft\Windows\CurrentVersion\Uninstall\LivingEarth3D').DisplayVersion -ne $BaselineVersion) { throw 'Rollback did not restore version metadata' }
Write-Output "PASS: actual installer failure restores $BaselineVersion files and registry version"
Install-EarthRelease $installRoot $Installer $manifest (Join-Path $fixture 'successful-backup')
Confirm-EarthFiles $installRoot $manifest
if ((Get-ItemProperty 'HKCU:\Software\Microsoft\Windows\CurrentVersion\Uninstall\LivingEarth3D').DisplayVersion -ne '0.12.2') { throw 'Updated version metadata missing' }
if ((Get-Content $sentinel -Raw) -ne 'user preferences must survive') { throw 'User data changed' }
$shortcut=(New-Object -ComObject WScript.Shell).CreateShortcut((Join-Path ([Environment]::GetFolderPath('Desktop')) 'Living Earth 3D.lnk'))
if ($shortcut.IconLocation -notlike '*LivingEarth3D-0.12.2.ico*' -or !(Test-Path (Join-Path $installRoot 'LivingEarth3D-0.12.2.ico'))) { throw 'Versioned desktop icon missing' }
Write-Output 'PASS: versioned desktop shortcut icon installed'
Write-Output "PASS: real silent $BaselineVersion to 0.12.2 update at a path containing spaces preserves user data"
# Exercise running-process protection using our own headless app process, without GPU requirements.
$app=Start-Process (Join-Path $installRoot 'LivingEarth3D.exe') -ArgumentList '--headless --quit-after 180' -PassThru
Start-Sleep -Milliseconds 500
$rejected=$false
try { Install-EarthRelease $installRoot $Installer $manifest (Join-Path $fixture 'blocked-backup') } catch { $rejected=$true }
if (!$rejected) { throw 'An update was allowed while the app was running' }
if (!$app.WaitForExit(30000)) { throw 'Headless fixture did not exit naturally' }
Write-Output 'PASS: a running application defers replacement'
$uninstall=Start-Process (Join-Path $installRoot 'Uninstall.exe') -ArgumentList "/S _?=$installRoot" -Wait -PassThru
if ($uninstall.ExitCode -ne 0 -or (Test-Path (Join-Path $installRoot 'LivingEarth3D.exe'))) { throw 'Uninstall failed' }
Remove-Item $sentinel -Force
Remove-Item $fixture -Recurse -Force
Write-Output 'Windows update installation: all checks passed (no native GPU behavior claimed)'
