param([string]$Godot = 'godot', [string]$Makensis = 'makensis', [string]$SigningPfx = '', [string]$SigningPassword = '')
$ErrorActionPreference = 'Stop'
$root = Split-Path (Split-Path $PSScriptRoot -Parent) -Parent
Push-Location $root
try {
    $version = (Select-String -Path project.godot -Pattern 'config/version="([^"]+)"').Matches[0].Groups[1].Value
    New-Item -ItemType Directory -Force build/windows, dist | Out-Null
    function Invoke-Godot([string[]]$Arguments, [string]$LogName) {
        $log = Join-Path $root "build/$LogName.log"
        $command = (Get-Command $Godot -ErrorAction Stop).Source
        $allArgs = @('--headless', '--path', ('"' + $root + '"'), '--log-file', ('"' + $log + '"')) + $Arguments
        $process = Start-Process -FilePath $command -ArgumentList $allArgs -NoNewWindow -Wait -PassThru
        if (Test-Path $log) { Get-Content $log | Write-Host }
        if ($process.ExitCode -ne 0) { throw "Godot $LogName failed with exit code $($process.ExitCode)" }
        if (!(Test-Path $log) -or (Select-String -Path $log -Pattern 'SCRIPT ERROR:|ERROR:')) { throw "Godot $LogName reported errors or no runtime log" }
    }
    $template = Join-Path $env:APPDATA 'Godot/export_templates/4.6.3.stable/windows_release_x86_64.exe'
    $brandedTemplate = Join-Path $root 'build/windows/earth_template.exe'
    Copy-Item -LiteralPath $template -Destination $brandedTemplate -Force
    & "$PSScriptRoot/set-icon.ps1" -Executable $brandedTemplate -Icon "$root/assets/icon.ico"
    Invoke-Godot -Arguments @('--editor', '--import', '--quit') -LogName 'import'
    Invoke-Godot -Arguments @('--export-release', '"Windows Desktop"', 'build/windows/LivingEarth3D.exe') -LogName 'export'
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
