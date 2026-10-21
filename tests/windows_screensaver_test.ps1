param([Parameter(Mandatory=$true)][string]$Installer,[switch]$SoftwareRendering,[ValidateRange(0,120)][int]$SoakMinutes=0)
$ErrorActionPreference='Stop'
if ($env:OS -ne 'Windows_NT') { throw 'Windows desktop required' }
Add-Type -AssemblyName System.Windows.Forms,System.Drawing
Add-Type @'
using System;
using System.Collections.Generic;
using System.Runtime.InteropServices;
public static class SaverWindows {
 public delegate bool EnumProc(IntPtr w, IntPtr p);
 [StructLayout(LayoutKind.Sequential)] public struct Rect {public int Left,Top,Right,Bottom;}
 [DllImport("user32.dll")] public static extern bool EnumChildWindows(IntPtr w,EnumProc p,IntPtr l);
 [DllImport("user32.dll")] public static extern bool EnumWindows(EnumProc p,IntPtr l);
 [DllImport("user32.dll")] public static extern uint GetWindowThreadProcessId(IntPtr w,out uint p);
 [DllImport("user32.dll")] public static extern IntPtr GetParent(IntPtr w);
 [DllImport("user32.dll")] public static extern bool IsWindowVisible(IntPtr w);
 [DllImport("user32.dll")] public static extern bool IsWindowEnabled(IntPtr w);
 [DllImport("user32.dll")] public static extern bool GetWindowRect(IntPtr w,out Rect r);
 [DllImport("user32.dll")] public static extern bool PostMessage(IntPtr w,uint m,IntPtr a,IntPtr b);
 [DllImport("user32.dll")] public static extern void keybd_event(byte k,byte s,uint f,UIntPtr e);
 public static IntPtr[] Windows(uint pid,IntPtr parent) {
  var result=new List<IntPtr>(); EnumProc cb=(w,p)=>{uint id;GetWindowThreadProcessId(w,out id);if(id==pid)result.Add(w);return true;};
  if(parent==IntPtr.Zero)EnumWindows(cb,IntPtr.Zero);else EnumChildWindows(parent,cb,IntPtr.Zero);
  return result.ToArray();
 }
}
'@
$fixture=Join-Path $env:RUNNER_TEMP ('earth native saver '+[guid]::NewGuid())
$root=Join-Path $fixture 'Living Earth 3D'
New-Item -ItemType Directory -Path $fixture -Force | Out-Null
$setup=Start-Process (Resolve-Path $Installer) -ArgumentList "/S /D=$root" -Wait -PassThru
if($setup.ExitCode -ne 0){throw 'Test installation failed'}
# The CI VM installs its software ICD separately; the shipped app uses its normal graphics driver.
if($SoftwareRendering){$env:GALLIUM_DRIVER='llvmpipe';$env:LIBGL_ALWAYS_SOFTWARE='1'}
$forms=New-Object Collections.Generic.List[Windows.Forms.Form]
$launchers=New-Object Collections.Generic.List[Diagnostics.Process]
function Pump([int]$Milliseconds=100) {
 $until=[DateTime]::UtcNow.AddMilliseconds($Milliseconds)
 while([DateTime]::UtcNow -lt $until){[Windows.Forms.Application]::DoEvents();Start-Sleep -Milliseconds 20}
}
function Start-Saver([string]$Arguments) {
 $start=New-Object Diagnostics.ProcessStartInfo
 $start.FileName="$root/LivingEarth3D.scr";$start.Arguments=$Arguments;$start.UseShellExecute=$false
 $p=[Diagnostics.Process]::Start($start)
 $launchers.Add($p);return $p
}
function Child-Process($Launcher) {
 $ids=@(Get-CimInstance Win32_Process -Filter "ParentProcessId=$($Launcher.Id)" | Where-Object {$_.ExecutablePath -eq "$root\LivingEarth3D.exe"})
 if($ids.Count){return Get-Process -Id $ids[0].ProcessId -ErrorAction SilentlyContinue}
 return $null
}
function Wait-Renderer($Launcher,[IntPtr]$Parent) {
 $deadline=[DateTime]::UtcNow.AddSeconds(30)
 while([DateTime]::UtcNow -lt $deadline){
  Pump
  if($Launcher.HasExited){
   Write-Host ("Native launcher exit="+$Launcher.ExitCode+"; parent visible="+[SaverWindows]::IsWindowVisible($Parent))
   $godotLog=Join-Path ([Environment]::GetFolderPath('ApplicationData')) 'Godot/app_userdata/Living Earth 3D/logs/godot.log'
   if(Test-Path $godotLog){Get-Content $godotLog -Tail 60 | ForEach-Object {Write-Host $_}}
   $diag=Join-Path $pwd 'dist/windows-saver-engine.log'
   $direct=Start-Process "$root/LivingEarth3D.exe" -ArgumentList ('--wid '+$Parent.ToInt64()+' --resolution 320x200 --audio-driver Dummy --log-file "'+$diag+'" -- --saver-hosted --saver-preview') -PassThru
   Pump 6000
   if(!$direct.HasExited){$direct.Kill();$direct.WaitForExit()}
   if(Test-Path $diag){Get-Content $diag -Tail 80 | ForEach-Object {Write-Host $_}}
   Write-Host ('Direct Godot exit='+$direct.ExitCode)
   throw 'Saver exited before renderer became visible'
  }
  $child=Child-Process $Launcher
  if($child){$windows=@([SaverWindows]::Windows([uint32]$child.Id,$Parent)|Where-Object{[SaverWindows]::IsWindowVisible($_)});if($windows.Count){return @{Process=$child;Window=$windows[0]}}}
 }
 throw 'No visible embedded Godot renderer'
}
function Assert-Exit($Launcher,$Renderer) {
 $deadline=[DateTime]::UtcNow.AddSeconds(8)
 while([DateTime]::UtcNow -lt $deadline -and (!$Launcher.HasExited -or !$Renderer.HasExited)){Pump}
 if(!$Launcher.HasExited -or !$Renderer.HasExited){throw 'Saver left a renderer running'}
}
function Preview-Form([int]$X) {
 $f=New-Object Windows.Forms.Form
 $f.Text='Living Earth native preview fixture';$f.StartPosition='Manual';$f.Location=New-Object Drawing.Point($X,80)
 $f.ClientSize=New-Object Drawing.Size(320,200);$f.Show();$forms.Add($f);Pump
 return $f
}
try {
 $preflightLog=Join-Path $pwd 'dist/windows-saver-preflight.log'
 $preflight=Start-Process "$root/LivingEarth3D.exe" -ArgumentList ('--resolution 320x200 --audio-driver Dummy --log-file "'+$preflightLog+'" -- --saver-hosted --saver-preview') -PassThru
 Pump 3000
 if($preflight.HasExited){if(Test-Path $preflightLog){Get-Content $preflightLog -Tail 50 | ForEach-Object {Write-Host $_}};throw 'Standalone software OpenGL preflight failed before preview testing'}
 $preflightWindows=@([SaverWindows]::Windows([uint32]$preflight.Id,[IntPtr]::Zero))
 foreach($w in $preflightWindows){[void][SaverWindows]::PostMessage($w,0x0010,[IntPtr]::Zero,[IntPtr]::Zero)}
 if(!$preflight.WaitForExit(5000)){$preflight.Kill();throw 'Standalone graphics preflight did not close'}
 if(Test-Path $preflightLog){Get-Content $preflightLog -Tail 15 | ForEach-Object {Write-Host $_}}
 Write-Output 'PASS: standalone packaged Godot graphics initializes before native embedding checks'
 foreach($bad in @('/p','/p:0','/p:-1','/p:18446744073709551616','/p:123')){
  $p=Start-Saver $bad
  if(!$p.WaitForExit(5000)){throw "Invalid preview request timed out: $bad (PID $($p.Id))"}
  if($p.ExitCode -ne 2){throw "Unexpected invalid-preview exit: $bad -> $($p.ExitCode)"}
 }
 Write-Output 'PASS: invalid/missing/overflow/stale preview handles exit without fullscreen fallback'
 $first=Preview-Form 40
 $p1=Start-Saver ('/p '+$first.Handle.ToInt64())
 $r1=Wait-Renderer $p1 $first.Handle
 if([SaverWindows]::GetParent($r1.Window) -ne $first.Handle){throw 'Preview is not a direct child of supplied HWND'}
 if(@([SaverWindows]::Windows([uint32]$r1.Process.Id,[IntPtr]::Zero)|Where-Object{[SaverWindows]::IsWindowVisible($_)}).Count){throw 'Preview leaked a visible top-level renderer'}
 $first.ClientSize=New-Object Drawing.Size(580,330);Pump 2000
 $rect=New-Object SaverWindows+Rect
 [void][SaverWindows]::GetWindowRect($r1.Window,[ref]$rect)
 if($rect.Right-$rect.Left -ne 580 -or $rect.Bottom-$rect.Top -ne 330){throw "Preview did not track parent client size: $($rect.Right-$rect.Left)x$($rect.Bottom-$rect.Top)"}
 if([SaverWindows]::IsWindowEnabled($r1.Window)){throw 'Preview renderer still accepts focus/input'}
 # Capture actual Godot pixels, not merely a correctly-parented blank window.
 Pump 4000
 $point=$first.PointToScreen([Drawing.Point]::Empty)
 $bitmap=New-Object Drawing.Bitmap(580,330)
 $graphics=[Drawing.Graphics]::FromImage($bitmap)
 $graphics.CopyFromScreen($point,[Drawing.Point]::Empty,$bitmap.Size)
 $colors=New-Object 'Collections.Generic.HashSet[int]'
 for($x=10;$x -lt 570;$x+=10){for($y=10;$y -lt 320;$y+=10){[void]$colors.Add($bitmap.GetPixel($x,$y).ToArgb())}}
 $evidence=Join-Path $pwd 'dist/windows-screensaver-preview.png'
 $bitmap.Save($evidence,[Drawing.Imaging.ImageFormat]::Png);$graphics.Dispose();$bitmap.Dispose()
 if($colors.Count -lt 20){throw 'Embedded preview has insufficient rendered Earth detail'}
 Write-Output 'PASS: actual Godot Earth renders inside native preview HWND, resizes and has no fullscreen window'
 if($SoakMinutes -gt 0){
  $soakStart=[DateTime]::UtcNow;$baselineMemory=0L
  $samples=New-Object 'Collections.Generic.List[object]'
  while(([DateTime]::UtcNow-$soakStart).TotalMinutes -lt $SoakMinutes){
   Pump 30000
   if($p1.HasExited -or $r1.Process.HasExited){throw 'Long preview soak exited unexpectedly'}
   $r1.Process.Refresh()
   $elapsed=([DateTime]::UtcNow-$soakStart).TotalSeconds
   $memory=$r1.Process.PrivateMemorySize64
   if($baselineMemory -eq 0 -and $elapsed -ge 120){$baselineMemory=$memory}
   if($baselineMemory -gt 0 -and $memory-$baselineMemory -gt 268435456){throw 'Long preview soak private-memory growth exceeds 256 MiB after warmup'}
   $large=([int]($elapsed/60)%2 -eq 0)
   $width=if($large){580}else{320};$height=if($large){330}else{200}
   $first.ClientSize=New-Object Drawing.Size($width,$height);Pump 200
   $bounds=New-Object SaverWindows+Rect
   [void][SaverWindows]::GetWindowRect($r1.Window,[ref]$bounds)
   if([SaverWindows]::GetParent($r1.Window) -ne $first.Handle -or $bounds.Right-$bounds.Left -ne $width -or $bounds.Bottom-$bounds.Top -ne $height){throw 'Long preview soak lost embedding or resize tracking'}
   if([SaverWindows]::IsWindowEnabled($r1.Window)){throw 'Long preview soak enabled renderer input'}
   $sample=[pscustomobject]@{seconds=[math]::Round($elapsed,1);private_bytes=$memory;working_set_bytes=$r1.Process.WorkingSet64;cpu_seconds=[math]::Round($r1.Process.TotalProcessorTime.TotalSeconds,2);width=$width;height=$height}
   $point=$first.PointToScreen([Drawing.Point]::Empty)
   $soakBitmap=New-Object Drawing.Bitmap($width,$height)
   $soakGraphics=[Drawing.Graphics]::FromImage($soakBitmap)
   try {
    $soakGraphics.CopyFromScreen($point,[Drawing.Point]::Empty,$soakBitmap.Size)
    $soakColors=New-Object 'Collections.Generic.HashSet[int]'
    for($sx=10;$sx -lt $width-10;$sx+=10){for($sy=10;$sy -lt $height-10;$sy+=10){[void]$soakColors.Add($soakBitmap.GetPixel($sx,$sy).ToArgb())}}
    if($soakColors.Count -lt 20){throw 'Long preview soak lost rendered Earth pixels'}
    $soakBitmap.Save((Join-Path $pwd 'dist/windows-screensaver-soak-latest.png'),[Drawing.Imaging.ImageFormat]::Png)
   } finally {$soakGraphics.Dispose();$soakBitmap.Dispose()}
   $samples.Add($sample)
   Write-Output ('SAVER_SOAK '+($sample|ConvertTo-Json -Compress))
  }
  $samples|Export-Csv (Join-Path $pwd 'dist/windows-screensaver-soak.csv') -NoTypeInformation
  Write-Output "PASS: $SoakMinutes-minute actual Windows preview soak retains rendering process, bounded private memory, input isolation, parenting and resize tracking"
 }

 $before=(Get-FileHash "$root/LivingEarth3D.exe" -Algorithm SHA256).Hash
 $blocked=Start-Process (Resolve-Path $Installer) -ArgumentList "/S /D=$root" -Wait -PassThru
 if($blocked.ExitCode -eq 0 -or (Get-FileHash "$root/LivingEarth3D.exe" -Algorithm SHA256).Hash -ne $before -or $p1.HasExited){throw 'Silent installer did not defer for native preview controller'}
 Write-Output 'PASS: silent manual installation defers while native preview controller is running'

 $second=Preview-Form 650
 $p2=Start-Saver ('/P:'+$second.Handle.ToInt64())
 $r2=Wait-Renderer $p2 $second.Handle
 $first.Close();Pump
 Assert-Exit $p1 $r1.Process
 if($p2.HasExited -or $r2.Process.HasExited){throw 'Closing one preview stopped another'}
 # Abrupt controller death must not leave a renderer behind.
 $p2.Kill();Assert-Exit $p2 $r2.Process
 $second.Close();Pump
 Write-Output 'PASS: independent previews, parent destruction and controller-death job cleanup'
 $full=Start-Saver '/s'
 $deadline=[DateTime]::UtcNow.AddSeconds(30)
 $hosts=@()
 while([DateTime]::UtcNow -lt $deadline){Pump;$hosts=@([SaverWindows]::Windows([uint32]$full.Id,[IntPtr]::Zero)|Where-Object{[SaverWindows]::IsWindowVisible($_)});if($hosts.Count -ge [Windows.Forms.Screen]::AllScreens.Count){break}}
 if($hosts.Count -ne [Windows.Forms.Screen]::AllScreens.Count){throw 'Fullscreen host count differs from attached monitors'}
 foreach($screen in [Windows.Forms.Screen]::AllScreens){
  $found=$false
  foreach($hostWindow in $hosts){$bounds=New-Object SaverWindows+Rect;[void][SaverWindows]::GetWindowRect($hostWindow,[ref]$bounds);if($bounds.Left -eq $screen.Bounds.Left -and $bounds.Top -eq $screen.Bounds.Top -and $bounds.Right -eq $screen.Bounds.Right -and $bounds.Bottom -eq $screen.Bounds.Bottom){$found=$true}}
  if(!$found){throw 'A monitor was not covered by a native host'}
 }
 $renderer=Child-Process $full
 if(!$renderer){throw 'Fullscreen renderer did not start'}
 $duplicate=Start-Saver '/S'
 if(!$duplicate.WaitForExit(5000)){throw 'Duplicate fullscreen saver was allowed'}
 Pump 1800
 [SaverWindows]::keybd_event(0x87,0,0,[UIntPtr]::Zero);[SaverWindows]::keybd_event(0x87,0,2,[UIntPtr]::Zero)
 Assert-Exit $full $renderer
 Write-Output "PASS: fullscreen covers $($hosts.Count) attached monitor(s), rejects duplicate session and exits on keyboard input"
 $full=Start-Saver '/s';Pump 3000
 $renderer=Child-Process $full
 $hosts=@([SaverWindows]::Windows([uint32]$full.Id,[IntPtr]::Zero)|Where-Object{[SaverWindows]::IsWindowVisible($_)})
 if(!$renderer -or !$hosts.Count){throw 'Second fullscreen session did not start'}
 [void][SaverWindows]::PostMessage($hosts[0],0x007e,[IntPtr]::Zero,[IntPtr]::Zero)
 Assert-Exit $full $renderer
 Write-Output 'PASS: simulated display-change notification closes the full saver session and renderer'
 foreach($event in @(@(0x0218,4,'suspend'),@(0x02B1,7,'session lock'))){
  $full=Start-Saver '/s';Pump 3000
  $renderer=Child-Process $full
  $hosts=@([SaverWindows]::Windows([uint32]$full.Id,[IntPtr]::Zero)|Where-Object{[SaverWindows]::IsWindowVisible($_)})
  if(!$renderer -or !$hosts.Count){throw 'Lifecycle notification fixture did not start'}
  [void][SaverWindows]::PostMessage($hosts[0],[uint32]$event[0],[IntPtr]$event[1],[IntPtr]::Zero)
  Assert-Exit $full $renderer
  Write-Output ('PASS: simulated '+$event[2]+' notification cleans up native host and renderer')
 }
 Write-Output 'Native Windows screensaver checks passed (software OpenGL; physical multi-monitor/DPI/sleep remain separate)'
} finally {
 foreach($p in $launchers){if(!$p.HasExited){$p.Kill();$p.WaitForExit()}}
 foreach($f in $forms){$f.Dispose()}
 $uninstall=Start-Process "$root/Uninstall.exe" -ArgumentList "/S _?=$root" -Wait -PassThru
 if($uninstall.ExitCode -ne 0){throw 'Test uninstall failed'}
 Remove-Item $fixture -Recurse -Force
}
