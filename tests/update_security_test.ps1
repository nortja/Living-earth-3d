$ErrorActionPreference = 'Stop'
. "$PSScriptRoot/../packaging/windows/update-core.ps1"
$productionKey = $script:UpdatePublicKey
$key = [Security.Cryptography.RSACryptoServiceProvider]::new(3072)
$key.PersistKeyInCsp = $false
$script:UpdatePublicKey = $key.ToXmlString($false)
$checks = 0
function Assert-True($Value, $Message) { $script:checks++; if (!$Value) { throw $Message } }
function Sign-Bytes([byte[]]$Bytes) { return ,$key.SignData($Bytes, [Security.Cryptography.CryptoConfig]::MapNameToOID('SHA256')) }
function Bytes-For($Object) { return ,[Text.Encoding]::UTF8.GetBytes(($Object | ConvertTo-Json -Depth 8 -Compress)) }
function Must-Reject($Object, $Message) {
    $bytes = Bytes-For $Object
    $rejected = $false
    try { Read-EarthManifest $bytes (Sign-Bytes $bytes) | Out-Null } catch { $rejected = $true }
    Assert-True $rejected $Message
}
try {
    $feed = @{product='LivingEarth3D';channel='preview';protocol=1;version='0.5.3';installer_url='https://github.com/nortja/Living-earth-3d/raw/refs/heads/downloads/windows-0.5.3/LivingEarth3D-Setup-0.5.3.exe';sha256=('a'*64);size=40000000;files=@{'LivingEarth3D.exe'=('b'*64);'LivingEarth3D.scr'=('b'*64);'update.ps1'=('c'*64);'update-core.ps1'=('d'*64)}}
    $bytes = Bytes-For $feed
    $signature = Sign-Bytes $bytes
    Assert-True ((Read-EarthManifest $bytes $signature).version -eq '0.5.3') 'Valid release signature rejected'
    $tampered = [byte[]]$bytes.Clone(); $tampered[2] = $tampered[2] -bxor 1
    $rejected=$false; try { Read-EarthManifest $tampered $signature | Out-Null } catch { $rejected=$true }
    Assert-True $rejected 'Tampered release metadata was accepted'
    $badSignature = [byte[]]$signature.Clone();$badSignature[0]=$badSignature[0] -bxor 1
    $rejected=$false;try { Read-EarthManifest $bytes $badSignature | Out-Null } catch { $rejected=$true }
    Assert-True $rejected 'Invalid release signature was accepted'
    foreach ($case in @(@('installer_url','https://example.com/evil.exe'),@('channel','stable'),@('product','AnotherApp'),@('protocol',2),@('version','0.5.3/../../evil'),@('sha256','broken'),@('size',314572801),@('size','40000000'))) {
        $changed=$feed.Clone();$changed[$case[0]]=$case[1];Must-Reject $changed "Accepted invalid $($case[0])"
    }
    $changed=$feed.Clone();$changed.files=$feed.files.Clone();$changed.files['evil.ps1']='a'*64;Must-Reject $changed 'Extra file was accepted'
    $changed=$feed.Clone();$changed.files=$feed.files.Clone();$changed.files.Remove('update.ps1');Must-Reject $changed 'Missing helper checksum was accepted'
    $temporary=Join-Path ([IO.Path]::GetTempPath()) ([guid]::NewGuid().ToString());New-Item -ItemType Directory $temporary | Out-Null
    try {
        foreach ($name in $feed.files.Keys) { [IO.File]::WriteAllText((Join-Path $temporary $name),'test fixture') }
        $files=@{};foreach ($name in $feed.files.Keys) { $files[$name]=(Get-FileHash (Join-Path $temporary $name) -Algorithm SHA256).Hash.ToLowerInvariant() }
        $changed=$feed.Clone();$changed.files=$files
        Confirm-EarthFiles $temporary $changed
        Assert-True $true 'Matching installed files rejected'
        [IO.File]::WriteAllText((Join-Path $temporary 'update.ps1'),'tampered fixture')
        $rejected=$false;try { Confirm-EarthFiles $temporary $changed } catch { $rejected=$true }
        Assert-True $rejected 'Modified installed helper was accepted'
    } finally { Remove-Item $temporary -Recurse -Force }
    # A production key cannot verify fixture releases signed by an unrelated key.
    $script:UpdatePublicKey=$productionKey
    $rejected=$false;try { Read-EarthManifest $bytes $signature | Out-Null } catch { $rejected=$true }
    Assert-True $rejected 'Foreign signing key was accepted'
    Write-Output "Update security: $checks checks passed"
} finally { $script:UpdatePublicKey=$productionKey;$key.Dispose() }
