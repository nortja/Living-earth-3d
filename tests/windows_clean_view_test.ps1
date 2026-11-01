param([Parameter(Mandatory=$true)][string]$Application,[Parameter(Mandatory=$true)][string]$OutputDirectory)
$ErrorActionPreference='Stop'
if($env:OS -ne 'Windows_NT'){throw 'Native Windows cursor test requires Windows'}
if(!('EarthCleanCursor' -as [type])) {
Add-Type @'
using System;
using System.Runtime.InteropServices;
public static class EarthCleanCursor {
 [StructLayout(LayoutKind.Sequential)] public struct Rect { public int left,top,right,bottom; }
 [StructLayout(LayoutKind.Sequential)] public struct Point { public int x,y; }
 [DllImport("user32.dll")] public static extern bool GetClientRect(IntPtr window,out Rect rect);
 [DllImport("user32.dll")] public static extern bool ClientToScreen(IntPtr window,ref Point point);
 [DllImport("user32.dll")] public static extern bool SetCursorPos(int x,int y);
 [DllImport("user32.dll")] public static extern bool SetForegroundWindow(IntPtr window);
}
'@
}
New-Item -ItemType Directory -Force $OutputDirectory|Out-Null
$OutputDirectory=(Resolve-Path $OutputDirectory).Path
foreach($name in @('ready','inside','outside','returned','done')){Remove-Item (Join-Path $OutputDirectory ($name+'.json')) -ErrorAction SilentlyContinue}
$log=Join-Path $OutputDirectory 'native-clean-view.log'
$start=New-Object Diagnostics.ProcessStartInfo
$start.FileName=(Resolve-Path $Application).Path;$start.UseShellExecute=$false
$start.Arguments='--audio-driver Dummy --log-file "'+$log.Replace('\','/')+'" -- --validate-clean-view "--evidence-directory='+$OutputDirectory.Replace('\','/')+'"'
$app=[Diagnostics.Process]::Start($start)
function Wait-EarthStage([string]$Name){
 $path=Join-Path $OutputDirectory ($Name+'.json')
 $deadline=[DateTime]::UtcNow.AddSeconds(35)
 while(!(Test-Path $path)){
  if($app.HasExited -or [DateTime]::UtcNow -gt $deadline){throw ('Native clean-view stage timed out: '+$Name)}
  Start-Sleep -Milliseconds 100
 }
 $result=Get-Content $path -Raw|ConvertFrom-Json
 if($result.failures.Count){throw ($result.failures -join '; ')}
 return $result
}
try {
 $null=Wait-EarthStage 'ready'
 $app.Refresh();$window=$app.MainWindowHandle
 if($window -eq [IntPtr]::Zero){throw 'Installed clean-view window handle missing'}
 $rect=New-Object EarthCleanCursor+Rect
 $point=New-Object EarthCleanCursor+Point
 if(![EarthCleanCursor]::GetClientRect($window,[ref]$rect) -or ![EarthCleanCursor]::ClientToScreen($window,[ref]$point)){throw 'Cannot resolve native client bounds'}
 $null=[EarthCleanCursor]::SetForegroundWindow($window)
 # Enter over a real header control, not just the 3D area.
 $null=[EarthCleanCursor]::SetCursorPos($point.x+$rect.right-60,$point.y+40)
 $null=Wait-EarthStage 'inside'
 # Move outside the complete native window on this isolated centered desktop.
 $null=[EarthCleanCursor]::SetCursorPos(0,0)
 $null=Wait-EarthStage 'outside'
 $null=[EarthCleanCursor]::SetCursorPos($point.x+$rect.right-60,$point.y+40)
 $null=Wait-EarthStage 'returned'
 $result=Wait-EarthStage 'done'
 if(!$app.WaitForExit(15000) -or $app.ExitCode -ne 0 -or !$result.passed){throw 'Installed native clean-view validation failed'}
 Write-Output ('PASS: real native pointer exit/return, preserved page, optional Moon and clean PNG '+($result.postcard_pixels -join 'x'))
} finally {
 if(!$app.HasExited){$app.Kill();$app.WaitForExit()}
 if(Test-Path $log){Get-Content $log|Write-Output}
}
