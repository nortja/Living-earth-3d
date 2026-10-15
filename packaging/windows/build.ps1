param([string]$Godot = 'godot', [string]$Makensis = 'makensis', [string]$SigningPfx = '', [string]$SigningPassword = '')
$ErrorActionPreference = 'Stop'
$root = Split-Path (Split-Path $PSScriptRoot -Parent) -Parent
Push-Location $root
try {
    $version = (Select-String -Path project.godot -Pattern 'config/version="([^"]+)"').Matches[0].Groups[1].Value
    New-Item -ItemType Directory -Force build/windows, dist | Out-Null
    & $Godot --headless --path $root --editor --import --quit
    if ($LASTEXITCODE -ne 0) { throw 'Godot import failed' }
    & $Godot --headless --path $root --export-release 'Windows Desktop' 'build/windows/LivingEarth3D.exe'
    if ($LASTEXITCODE -ne 0) { throw 'Windows export failed' }
    $app = Join-Path $root 'build/windows/LivingEarth3D.exe'
    $installer = Join-Path $root "dist/LivingEarth3D-Setup-$version.exe"
    $signtool = $null
    if ($SigningPfx) {
        $signtool = (Get-ChildItem 'C:/Program Files (x86)/Windows Kits/10/bin/*/x64/signtool.exe' | Sort-Object FullName -Descending | Select-Object -First 1).FullName
        if (-not $signtool) { throw 'Windows SDK signtool is required for signing.' }
        & $signtool sign /fd SHA256 /tr http://timestamp.digicert.com /td SHA256 /f $SigningPfx /p $SigningPassword $app
        if ($LASTEXITCODE -ne 0) { throw 'Application signing failed' }
    }
    & $Makensis "/DVERSION=$version" "/DBUILD_DIR=$root/build/windows" "/DOUTPUT=$installer" 'packaging/windows/installer.nsi'
    if ($LASTEXITCODE -ne 0) { throw 'Installer compilation failed' }
    if ($SigningPfx) {
        & $signtool sign /fd SHA256 /tr http://timestamp.digicert.com /td SHA256 /f $SigningPfx /p $SigningPassword $installer
        if ($LASTEXITCODE -ne 0) { throw 'Installer signing failed' }
        if ((Get-AuthenticodeSignature $installer).Status -ne 'Valid') { throw 'Installer signature verification failed' }
    }
    (Get-FileHash $installer -Algorithm SHA256).Hash.ToLower() + '  ' + (Split-Path $installer -Leaf) | Set-Content "$installer.sha256" -Encoding ascii
    Write-Host "Installer ready: $installer"
} finally { Pop-Location }
