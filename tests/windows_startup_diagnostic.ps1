param([Parameter(Mandatory=$true)][string]$Installer,[switch]$PriorSettings,[switch]$DisableCache)
$ErrorActionPreference='Stop'
Add-Type -AssemblyName System.Windows.Forms
$fixture=Join-Path $env:RUNNER_TEMP ('earth startup diagnostic '+[guid]::NewGuid())
$root=Join-Path $fixture 'Living Earth 3D'
$evidence=Join-Path $pwd 'dist/startup-diagnostic'
New-Item -ItemType Directory -Force $fixture,$evidence|Out-Null
$env:GALLIUM_DRIVER='llvmpipe';$env:LIBGL_ALWAYS_SOFTWARE='1'
if($DisableCache){$env:MESA_SHADER_CACHE_DISABLE='true'}
if($PriorSettings){./tests/windows_saver_settings_test.ps1 -Installer $Installer}
$setup=Start-Process (Resolve-Path $Installer) -ArgumentList "/S /D=$root" -Wait -PassThru
if($setup.ExitCode -ne 0){throw 'Diagnostic installation failed'}
$results=New-Object Collections.Generic.List[object]
function Case([string]$Name,[bool]$Shell,[bool]$InstallCwd,[bool]$Headless) {
 $log=Join-Path $evidence ($Name+'.log')
 $stdout=Join-Path $evidence ($Name+'-stdout.log')
 $stderr=Join-Path $evidence ($Name+'-stderr.log')
 $start=New-Object Diagnostics.ProcessStartInfo
 $start.FileName=Join-Path $root 'LivingEarth3D.exe'
 $start.WorkingDirectory=if($InstallCwd){$root}else{$pwd.Path}
 $start.UseShellExecute=$Shell
 $start.Arguments='--resolution 320x200 --audio-driver Dummy --verbose --log-file "'+$log+'" '
 if($Headless){$start.Arguments+='--headless --quit-after 5 '}
 $start.Arguments+='-- --saver-hosted --saver-preview --validate-native-preflight'
 if(!$Shell){$start.RedirectStandardOutput=$true;$start.RedirectStandardError=$true}
 $p=$null;$record=@{name=$Name;shell=$Shell;install_cwd=$InstallCwd;headless=$Headless;cache_disabled=[bool]$DisableCache;prior_settings=[bool]$PriorSettings}
 try {
  $started=[DateTime]::UtcNow
  $p=[Diagnostics.Process]::Start($start)
  $outTask=$null;$errTask=$null
  if(!$Shell){$outTask=$p.StandardOutput.ReadToEndAsync();$errTask=$p.StandardError.ReadToEndAsync()}
  $deadline=$started.AddSeconds(35);$ready=$false
  while([DateTime]::UtcNow -lt $deadline -and !$p.HasExited){
   [Windows.Forms.Application]::DoEvents();Start-Sleep -Milliseconds 100
   if(Test-Path $log){
    $reader=$null
    try {
     $stream=[IO.File]::Open($log,[IO.FileMode]::Open,[IO.FileAccess]::Read,([IO.FileShare]::ReadWrite -bor [IO.FileShare]::Delete))
     $reader=[IO.StreamReader]::new($stream)
     $ready=$reader.ReadToEnd().Contains('LIVING_EARTH_NATIVE_FRAME_READY')
    } catch {} finally {if($reader){$reader.Dispose()}}
   }
   if($ready){break}
  }
  $p.Refresh()
  $record.elapsed_seconds=([DateTime]::UtcNow-$started).TotalSeconds
  $record.ready=$ready;$record.exited=$p.HasExited
  $record.window_handle=$p.MainWindowHandle.ToInt64()
  if(!$p.HasExited){
   $record.responding=$p.Responding;$record.cpu_seconds=$p.TotalProcessorTime.TotalSeconds
   $record.threads=$p.Threads.Count;$record.private_bytes=$p.PrivateMemorySize64
   $record.close_requested=$p.CloseMainWindow()
   $record.closed=$p.WaitForExit(5000)
   if(!$p.HasExited){$p.Kill();$p.WaitForExit();$record.killed=$true}
  }
  $record.exit_code=$p.ExitCode
  if($outTask){[IO.File]::WriteAllText($stdout,$outTask.GetAwaiter().GetResult());[IO.File]::WriteAllText($stderr,$errTask.GetAwaiter().GetResult())}
  $record.log_bytes=if(Test-Path $log){(Get-Item $log).Length}else{0}
 } catch {$record.error=$_.Exception.Message}
 finally {if($p -and !$p.HasExited){$p.Kill();$p.WaitForExit()}}
 $results.Add($record)
 Write-Output ('STARTUP_DIAGNOSTIC '+($record|ConvertTo-Json -Compress))
}
try {
 Case 'direct-installed-cwd' $false $true $false
 Case 'direct-repository-cwd' $false $false $false
 Case 'shell-repository-cwd' $true $false $false
 Case 'headless-native' $false $true $true
 $results|ConvertTo-Json -Depth 5|Set-Content (Join-Path $evidence 'results.json') -Encoding UTF8
} finally {
 $uninstall=Start-Process "$root/Uninstall.exe" -ArgumentList "/S _?=$root" -Wait -PassThru
 if($uninstall.ExitCode -ne 0){throw 'Diagnostic uninstall failed'}
 Remove-Item $fixture -Recurse -Force
}
