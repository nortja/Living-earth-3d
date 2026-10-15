# Runs without a terminal. Feed and installer locations are restricted to this project.
param([string]$CurrentVersion = '0.4.0', [int]$AppProcessId = 0)
$ErrorActionPreference = 'Stop'
Add-Type -AssemblyName System.Windows.Forms
$work = $null
$mutex = $null
$ownsMutex = $false
try {
    $mutex = [Threading.Mutex]::new($false, 'Local\LivingEarth3D.Updater')
    $ownsMutex = $mutex.WaitOne(0)
    if (!$ownsMutex) { return }
    [Net.ServicePointManager]::SecurityProtocol = [Net.SecurityProtocolType]::Tls12
    $feed = Invoke-RestMethod -Uri 'https://raw.githubusercontent.com/nortja/Living-earth-3d/main/updates/preview.json' -Headers @{'User-Agent'='LivingEarth3D-Updater'}
    if ($feed.channel -cne 'preview' -or $feed.version -notmatch '^(0|[1-9]\d*)\.(0|[1-9]\d*)\.(0|[1-9]\d*)$') { throw 'Invalid update metadata.' }
    $version = $feed.version
    if ([version]$version -le [version]$CurrentVersion) { return }
    if ($feed.installer_signed -isnot [bool] -or !$feed.installer_signed) { throw 'This preview is unsigned. Use Download latest in the app to install manually.' }
    if ($feed.sha256 -cnotmatch '^[0-9a-f]{64}$') { throw 'Missing installer checksum.' }
    $name = "LivingEarth3D-Setup-$version.exe"
    $expected = "https://github.com/nortja/Living-earth-3d/raw/refs/heads/downloads/windows-$version/$name"
    if ($feed.installer_url -cne $expected) { throw 'Unexpected installer location.' }
    $installed = Join-Path $PSScriptRoot 'LivingEarth3D.exe'
    $trusted = Get-AuthenticodeSignature -LiteralPath $installed
    if ($trusted.Status -ne 'Valid') { throw 'Automatic installation requires a signed release. Use Download latest for this development build.' }
    $work = Join-Path ([IO.Path]::GetTempPath()) ([guid]::NewGuid().ToString())
    New-Item -ItemType Directory -Path $work | Out-Null
    $download = Join-Path $work $name
    Invoke-WebRequest -UseBasicParsing -Uri $expected -OutFile $download
    if ((Get-FileHash -LiteralPath $download -Algorithm SHA256).Hash.ToLower() -cne $feed.sha256) { throw 'Installer checksum mismatch. The update was not run.' }
    $signature = Get-AuthenticodeSignature -LiteralPath $download
    if ($signature.Status -ne 'Valid' -or $signature.SignerCertificate.Thumbprint -ne $trusted.SignerCertificate.Thumbprint) { throw 'Installer signature does not match the installed application. The update was not run.' }
    $answer = [Windows.Forms.MessageBox]::Show("Version $version is ready. Close Living Earth 3D and install the update now?", 'Living Earth 3D update', 'YesNo', 'Information')
    if ($answer -ne 'Yes') { return }
    if ($AppProcessId -gt 0) {
        $app = Get-Process -Id $AppProcessId -ErrorAction SilentlyContinue
        if ($app) {
            if ($app.Path -ne $installed) { throw 'The running application path does not match this installation.' }
            if (-not $app.CloseMainWindow()) { throw 'Please close Living Earth 3D before updating.' }
            if (-not $app.WaitForExit(30000)) { throw 'The app is still running. The update was cancelled.' }
        }
    }
    $setup = Start-Process -FilePath $download -ArgumentList @('/S', "/D=$PSScriptRoot") -Wait -PassThru
    if ($setup.ExitCode -ne 0) { throw "Installer failed with code $($setup.ExitCode)." }
} catch {
    [Windows.Forms.MessageBox]::Show($_.Exception.Message, 'Living Earth 3D update', 'OK', 'Information') | Out-Null
} finally {
    if ($work -and (Test-Path -LiteralPath $work)) { Remove-Item -LiteralPath $work -Recurse -Force }
    if ($ownsMutex) { $mutex.ReleaseMutex() }
    if ($mutex) { $mutex.Dispose() }
}
