# Release-signature verification and recoverable per-user installation. No network on import.
$script:UpdateProtocol = 1
$script:UpdatePublicKey = '<RSAKeyValue><Modulus>rSRVw4fXEyAafKSDgzaiL6/Rx3aIirAwA1MVKPynrwGALr2Ywe7JWIsLwOcRtMZlHPkuScwNdD7X9swMG7SLkEf4YzDygplwTjg6G+TqDvalhVPAgoo5rygIjUclU6gaWXZI4X9M/jEsIvVAyfffyIR7xRtaHSwWyVODkgwtLvSCfIoaHsw2nk0mgc+g/o2Y1wdGkDSTxmFrOC/SSJwZF9a0zgFTkbQgNX3tGZX8NfLRnh8C5vOTarZQfA7u5fXorb+NXGdNypoG+7A7ouY1HfG4TSWG6KRyI90pjVyQt6W0sO6CIpqQQZyj4vvhdDjy/E6aH2Vlz2KZIHA2pn1FU439pGDOLIWIo/3GTR9wtZgQ3VTy5o9By3bRw5mOUo+ynPcu573fz3/KuxRH4txsPLpr0f8j7iesDm/rt1w5Dx4Vsdaz5IFMrpwDWoNv6H+lnuisWOX0PufSXoCLai6ERjPIoSqk0NMFJ+p9GuoRg5iYr6JFQPNKE+YAaIgYYim3</Modulus><Exponent>AQAB</Exponent></RSAKeyValue>'
function Read-EarthManifest {
    param([byte[]]$Bytes, [byte[]]$Signature)
    if ($Bytes.Length -gt 65536 -or $Signature.Length -ne 384) { throw 'Invalid release signature or metadata size.' }
    $rsa = [Security.Cryptography.RSACryptoServiceProvider]::new()
    $rsa.PersistKeyInCsp = $false
    try {
        $rsa.FromXmlString($script:UpdatePublicKey)
        if (!$rsa.VerifyData($Bytes, [Security.Cryptography.CryptoConfig]::MapNameToOID('SHA256'), $Signature)) { throw 'Release signature verification failed.' }
    } finally { $rsa.Dispose() }
    $feed = [Text.Encoding]::UTF8.GetString($Bytes) | ConvertFrom-Json
    if ($feed.product -cne 'LivingEarth3D' -or $feed.channel -cne 'preview' -or $feed.protocol -ne $script:UpdateProtocol) { throw 'Unsupported update channel or protocol.' }
    if ($feed.version -cnotmatch '^(0|[1-9]\d*)\.(0|[1-9]\d*)\.(0|[1-9]\d*)$') { throw 'Invalid release version.' }
    $version = $feed.version
    $expected = "https://github.com/nortja/Living-earth-3d/raw/refs/heads/downloads/windows-$version/LivingEarth3D-Setup-$version.exe"
    if ($feed.installer_url -cne $expected -or $feed.sha256 -cnotmatch '^[0-9a-f]{64}$') { throw 'Unexpected release location or checksum.' }
    if ($feed.size -isnot [long] -and $feed.size -isnot [int]) { throw 'Missing release size.' }
    if ($feed.size -lt 1000000 -or $feed.size -gt 314572800) { throw 'Release is outside the supported size range.' }
    $names = @('LivingEarth3D.exe','LivingEarth3D.scr','update.ps1','update-core.ps1')
    if (@($feed.files.PSObject.Properties).Count -ne $names.Count) { throw 'Unexpected update file list.' }
    foreach ($name in $names) {
        if ($feed.files.$name -cnotmatch '^[0-9a-f]{64}$') { throw 'Missing installed-file checksum.' }
    }
    return $feed
}
function Receive-EarthFile {
    param([string]$Uri, [string]$Destination, [long]$MaximumBytes, [string]$CancelFile = '')
    $request = [Net.HttpWebRequest]::Create($Uri)
    $request.UserAgent = 'LivingEarth3D-Updater/1'
    $request.Timeout = 30000
    $request.ReadWriteTimeout = 30000
    $response = $null; $inputStream = $null; $outputStream = $null
    try {
        $response = $request.GetResponse()
        if ($response.ContentLength -gt $MaximumBytes) { throw 'Download exceeds the allowed size.' }
        $inputStream = $response.GetResponseStream()
        $outputStream = [IO.File]::Create($Destination)
        $buffer = New-Object byte[] 65536
        $total = 0L
        while (($count = $inputStream.Read($buffer, 0, $buffer.Length)) -gt 0) {
            if ($CancelFile -and (Test-Path -LiteralPath $CancelFile)) { throw 'Update cancelled.' }
            $total += $count
            if ($total -gt $MaximumBytes) { throw 'Download exceeds the allowed size.' }
            $outputStream.Write($buffer, 0, $count)
        }
    } finally {
        if ($outputStream) { $outputStream.Dispose() }
        if ($inputStream) { $inputStream.Dispose() }
        if ($response) { $response.Dispose() }
    }
}
function Confirm-EarthInstaller {
    param([string]$Path, $Manifest)
    if ((Get-Item -LiteralPath $Path).Length -ne $Manifest.size -or (Get-FileHash -LiteralPath $Path -Algorithm SHA256).Hash.ToLowerInvariant() -cne $Manifest.sha256) { throw 'Downloaded installer does not match the signed release.' }
}
function Confirm-EarthFiles {
    param([string]$InstallRoot, $Manifest)
    foreach ($name in @('LivingEarth3D.exe','LivingEarth3D.scr','update.ps1','update-core.ps1')) {
        $path = Join-Path $InstallRoot $name
        if (!(Test-Path -LiteralPath $path) -or (Get-FileHash -LiteralPath $path -Algorithm SHA256).Hash.ToLowerInvariant() -cne $Manifest.files.$name) { throw "Updated file verification failed: $name" }
    }
}
function Get-EarthProcesses {
    param([string]$InstallRoot)
    $paths = @((Join-Path $InstallRoot 'LivingEarth3D.exe'), (Join-Path $InstallRoot 'LivingEarth3D.scr'))
    # Include screensaver instances; never replace a running copy or terminate it.
    Get-Process -ErrorAction SilentlyContinue | Where-Object {
        try { $_.Path -and $paths -contains $_.Path } catch { $false }
    }
}
function Install-EarthRelease {
    param([string]$InstallRoot, [string]$Installer, $Manifest, [string]$Backup)
    Confirm-EarthInstaller $Installer $Manifest
    if (@(Get-EarthProcesses $InstallRoot).Count) { throw 'Living Earth is still running. Update deferred.' }
    if (Test-Path -LiteralPath $Backup) { Remove-Item -LiteralPath $Backup -Recurse -Force }
    New-Item -ItemType Directory -Path $Backup -Force | Out-Null
    $names = @('LivingEarth3D.exe','LivingEarth3D.scr','update.ps1','update-core.ps1','Uninstall.exe','Godot-LICENSE.txt','THREE-LICENSE.txt','CC-BY-4.0.txt','ATTRIBUTION.md')
    $registry = 'HKCU:\Software\Microsoft\Windows\CurrentVersion\Uninstall\LivingEarth3D'
    $oldVersion = (Get-ItemProperty -LiteralPath $registry -ErrorAction SilentlyContinue).DisplayVersion
    foreach ($name in $names) {
        $path = Join-Path $InstallRoot $name
        if (Test-Path -LiteralPath $path) { Copy-Item -LiteralPath $path -Destination (Join-Path $Backup $name) }
    }
    try {
        # NSIS requires /D last and unquoted, including paths containing spaces.
        $setup = Start-Process -FilePath $Installer -ArgumentList "/S /D=$InstallRoot" -Wait -PassThru
        if ($setup.ExitCode -ne 0) { throw "Installer failed ($($setup.ExitCode))." }
        Confirm-EarthFiles $InstallRoot $Manifest
    } catch {
        $failure = $_
        foreach ($name in $names) {
            $saved = Join-Path $Backup $name
            $target = Join-Path $InstallRoot $name
            if (Test-Path -LiteralPath $saved) { Copy-Item -LiteralPath $saved -Destination $target -Force }
            elseif (Test-Path -LiteralPath $target) { Remove-Item -LiteralPath $target -Force }
        }
        if ($oldVersion) { Set-ItemProperty -LiteralPath $registry -Name DisplayVersion -Value $oldVersion }
        throw "Update failed; previous files restored. $($failure.Exception.Message)"
    }
}
