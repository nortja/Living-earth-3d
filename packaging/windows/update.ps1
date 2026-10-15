# Runs without a terminal from the installed application. Never accepts an arbitrary feed URL.
param([string]$CurrentVersion = '0.3.0', [int]$AppProcessId = 0)
$ErrorActionPreference = 'Stop'
Add-Type -AssemblyName System.Windows.Forms
$work = $null
try {
    [Net.ServicePointManager]::SecurityProtocol = [Net.SecurityProtocolType]::Tls12
    $release = Invoke-RestMethod -Uri 'https://api.github.com/repos/nortja/Living-earth-3d/releases/latest' -Headers @{'User-Agent'='LivingEarth3D-Updater'}
    if ($release.draft -or $release.prerelease -or $release.tag_name -notmatch '^v?(\d+\.\d+\.\d+)$') { return }
    $version = $Matches[1]
    if ([version]$version -le [version]$CurrentVersion) { return }
    $name = "LivingEarth3D-Setup-$version.exe"
    $asset = @($release.assets | Where-Object name -eq $name)
    if ($asset.Count -ne 1) { throw 'This release does not contain a Windows installer.' }
    $url = [uri]$asset[0].browser_download_url
    $expected = "https://github.com/nortja/Living-earth-3d/releases/download/$($release.tag_name)/$name"
    if ($url.AbsoluteUri -cne $expected) { throw 'Unexpected installer location.' }
    $installed = Join-Path $PSScriptRoot 'LivingEarth3D.exe'
    $trusted = Get-AuthenticodeSignature -LiteralPath $installed
    if ($trusted.Status -ne 'Valid') { throw 'Automatic installation requires a signed release. Please use Official releases for this development build.' }
    $work = Join-Path ([IO.Path]::GetTempPath()) ([guid]::NewGuid().ToString())
    New-Item -ItemType Directory -Path $work | Out-Null
    $download = Join-Path $work $name
    Invoke-WebRequest -UseBasicParsing -Uri $url.AbsoluteUri -OutFile $download
    $signature = Get-AuthenticodeSignature -LiteralPath $download
    if ($signature.Status -ne 'Valid' -or $signature.SignerCertificate.Thumbprint -ne $trusted.SignerCertificate.Thumbprint) {
        throw 'Installer signature does not match the installed application. The update was not run.'
    }
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
}
