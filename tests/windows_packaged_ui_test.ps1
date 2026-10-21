param([Parameter(Mandatory=$true)][string]$Installer)
$ErrorActionPreference='Stop'
$fixture=Join-Path $env:RUNNER_TEMP ('earth packaged desktop '+[guid]::NewGuid())
$root=Join-Path $fixture 'Living Earth 3D'
$evidence=Join-Path $pwd 'dist/packaged-desktop'
New-Item -ItemType Directory -Path $fixture,$evidence -Force|Out-Null
$setup=Start-Process (Resolve-Path $Installer) -ArgumentList "/S /D=$root" -Wait -PassThru
if($setup.ExitCode -ne 0){throw 'Packaged desktop fixture installation failed'}
$log=Join-Path $evidence 'windows-packaged.log'
$env:GALLIUM_DRIVER='llvmpipe';$env:LIBGL_ALWAYS_SOFTWARE='1'
$app=$null
try {
 $start=New-Object Diagnostics.ProcessStartInfo
 $start.FileName=Join-Path $root 'LivingEarth3D.exe'
 $start.WorkingDirectory=$root;$start.UseShellExecute=$false
 $start.Arguments='--resolution 1280x720 --audio-driver Dummy --log-file "'+$log.Replace('\','/')+'" -- --validate-packaged-desktop "--evidence-directory='+$evidence.Replace('\','/')+'"'
 $app=[Diagnostics.Process]::Start($start)
 if(!$app.WaitForExit(450000)){
  if(Test-Path $log){Get-Content $log|Write-Output}
  if(Test-Path (Join-Path $evidence 'windows-packaged-progress.txt')){Get-Content (Join-Path $evidence 'windows-packaged-progress.txt')|Write-Output}
  throw 'Packaged desktop test timed out'
 }
 if(Test-Path $log){Get-Content $log|ForEach-Object{Write-Output $_}}
 if($app.ExitCode -ne 0){throw ('Packaged desktop test failed: '+$app.ExitCode)}
 $text=Get-Content $log -Raw
 if($text -match '(?m)^(SCRIPT ERROR|ERROR):' -or $text -notmatch 'Packaged Windows desktop: 0 failures'){throw 'Packaged desktop output did not pass'}
 Write-Output 'PASS: installed photographs, model layer, preview isolation and five-minute local performance recording'
} finally {
 if($app -and !$app.HasExited){$app.Kill();$app.WaitForExit()}
 $uninstall=Start-Process "$root/Uninstall.exe" -ArgumentList "/S _?=$root" -Wait -PassThru
 if($uninstall.ExitCode -ne 0){throw 'Packaged desktop fixture cleanup failed'}
 Remove-Item $fixture -Recurse -Force
}
