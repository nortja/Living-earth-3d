param([Parameter(Mandatory=$true)][string]$Installer)
$ErrorActionPreference='Stop'
if ($env:OS -ne 'Windows_NT') { throw 'Windows desktop required' }
Add-Type -AssemblyName System.Drawing
Add-Type @'
using System;
using System.Text;
using System.Collections.Generic;
using System.Runtime.InteropServices;
public static class EarthSaverSettings {
 public delegate bool EnumProc(IntPtr w, IntPtr p);
 [DllImport("user32.dll")] static extern bool EnumWindows(EnumProc p,IntPtr l);
 [DllImport("user32.dll")] static extern bool EnumChildWindows(IntPtr w,EnumProc p,IntPtr l);
 [DllImport("user32.dll",CharSet=CharSet.Unicode)] static extern int GetClassName(IntPtr w,StringBuilder b,int n);
 [DllImport("user32.dll",CharSet=CharSet.Unicode)] static extern int GetWindowText(IntPtr w,StringBuilder b,int n);
 [DllImport("user32.dll",CharSet=CharSet.Unicode)] static extern IntPtr SendMessage(IntPtr w,uint m,IntPtr a,StringBuilder b);
 [DllImport("user32.dll")] public static extern bool PostMessage(IntPtr w,uint m,IntPtr a,IntPtr b);
 [DllImport("user32.dll")] public static extern bool SystemParametersInfo(uint a,uint b,IntPtr c,uint d);
 [DllImport("user32.dll")] public static extern bool GetWindowRect(IntPtr w,out Rect r);
 [StructLayout(LayoutKind.Sequential)] public struct Rect {public int Left,Top,Right,Bottom;}
 public static IntPtr[] Dialogs() {
  var result=new List<IntPtr>(); EnumWindows((w,p)=>{var c=new StringBuilder(256);var t=new StringBuilder(256);GetClassName(w,c,256);GetWindowText(w,t,256);
   if(c.ToString()=="#32770" && t.ToString().Contains("Screen Saver"))result.Add(w);return true;},IntPtr.Zero);return result.ToArray();
 }
 public static string Selection(IntPtr dialog) {
  string result=null; EnumChildWindows(dialog,(w,p)=>{var c=new StringBuilder(256);GetClassName(w,c,256);
   if(c.ToString()=="ComboBox") {int index=SendMessage(w,0x147,IntPtr.Zero,null).ToInt32();if(index>=0){var text=new StringBuilder(2048);SendMessage(w,0x148,(IntPtr)index,text);result=text.ToString();}}return true;},IntPtr.Zero);return result;
 }
}
'@
$desktop='HKCU:\Control Panel\Desktop'
$snapshot=@{}
foreach($name in @('SCRNSAVE.EXE','ScreenSaveActive')) {
 $value=Get-ItemPropertyValue -LiteralPath $desktop -Name $name -ErrorAction SilentlyContinue
 $snapshot[$name]=$value
}
$fixture=Join-Path $env:RUNNER_TEMP ('earth settings with spaces '+[guid]::NewGuid())
$root=Join-Path $fixture 'Living Earth 3D'
New-Item -ItemType Directory -Path $fixture | Out-Null
$existing=@([EarthSaverSettings]::Dialogs())
function Close-TestDialogs {
 foreach($window in [EarthSaverSettings]::Dialogs()) {
  if($existing -notcontains $window){[EarthSaverSettings]::PostMessage($window,0x10,[IntPtr]::Zero,[IntPtr]::Zero)|Out-Null}
 }
 Start-Sleep -Milliseconds 500
 $deadline=[DateTime]::UtcNow.AddSeconds(10)
 do {
  $running=@(Get-Process -ErrorAction SilentlyContinue | Where-Object {
   try {$_.Path -in @("$root\LivingEarth3D.scr","$root\LivingEarth3D.exe")}catch{$false}
  })
  if(!$running.Count){break}
  Start-Sleep -Milliseconds 100
 } while([DateTime]::UtcNow -lt $deadline)
 if($running.Count){throw 'Settings preview did not exit after its dialog closed'}
}
function Run-Helper([string]$Flag) {
 $p=Start-Process "$root/LivingEarth3D.scr" -ArgumentList $Flag -PassThru
 if(!$p.WaitForExit(10000)){throw "Helper did not return: $Flag"}
 if($p.ExitCode -ne 0){throw "Helper failed: $Flag exit=$($p.ExitCode)"}
}
function Wait-Settings {
 $deadline=[DateTime]::UtcNow.AddSeconds(15)
 while([DateTime]::UtcNow -lt $deadline) {
  foreach($window in [EarthSaverSettings]::Dialogs()) {
   if($existing -notcontains $window -and $null -ne [EarthSaverSettings]::Selection($window)){return $window}
  }
  Start-Sleep -Milliseconds 100
 }
 throw 'Screen Saver Settings dialog did not open'
}
try {
 $setup=Start-Process (Resolve-Path $Installer) -ArgumentList "/S /D=$root" -Wait -PassThru
 if($setup.ExitCode -ne 0){throw 'Fixture installation failed'}
 Run-Helper '/settings'
 $window=Wait-Settings
 if((Get-ItemPropertyValue $desktop -Name 'SCRNSAVE.EXE' -ErrorAction SilentlyContinue) -cne $snapshot['SCRNSAVE.EXE']){throw 'Read-only settings action changed selection'}
 Close-TestDialogs
 Run-Helper '/select'
 $window=Wait-Settings
 if((Get-ItemPropertyValue $desktop -Name 'SCRNSAVE.EXE') -ine "$root\LivingEarth3D.scr"){throw 'Per-user selection not registered'}
 $selected=[EarthSaverSettings]::Selection($window)
 if($selected -ne 'Living Earth 3D'){throw "Living Earth 3D missing from selected dropdown item: $selected"}
 if((Get-ItemPropertyValue $desktop -Name 'ScreenSaveActive') -ne '1'){throw 'Selected screensaver is not active'}
 $rect=New-Object EarthSaverSettings+Rect
 [EarthSaverSettings]::GetWindowRect($window,[ref]$rect)|Out-Null
 $image=New-Object Drawing.Bitmap ($rect.Right-$rect.Left),($rect.Bottom-$rect.Top)
 $graphics=[Drawing.Graphics]::FromImage($image)
 try {
  $graphics.CopyFromScreen($rect.Left,$rect.Top,0,0,$image.Size)
  New-Item -ItemType Directory -Force dist | Out-Null
  $image.Save((Join-Path $pwd 'dist/windows-saver-settings.png'))
 } finally {$graphics.Dispose();$image.Dispose()}
 Close-TestDialogs
 # Removing this installation must never clear another chosen screensaver.
 Set-ItemProperty $desktop -Name 'SCRNSAVE.EXE' -Value 'C:\Windows\System32\scrnsave.scr'
 Run-Helper '/unregister'
 if((Get-ItemPropertyValue $desktop -Name 'SCRNSAVE.EXE') -ne 'C:\Windows\System32\scrnsave.scr'){throw 'Unregister changed another screensaver'}
 Run-Helper '/select'
 $null=Wait-Settings
 Close-TestDialogs
 $uninstall=Start-Process "$root/Uninstall.exe" -ArgumentList "/S _?=$root" -Wait -PassThru
 if($uninstall.ExitCode -ne 0){throw 'Uninstall failed'}
 if(Get-ItemPropertyValue $desktop -Name 'SCRNSAVE.EXE' -ErrorAction SilentlyContinue){throw 'Uninstall left selected saver pointing at removed files'}
 Write-Output 'Windows settings: dialog opened, Living Earth 3D dropdown selection confirmed, active setting and uninstall ownership checks passed.'
} finally {
 Close-TestDialogs
 foreach($name in $snapshot.Keys) {
  if($null -eq $snapshot[$name]){Remove-ItemProperty $desktop -Name $name -ErrorAction SilentlyContinue}
  else {Set-ItemProperty $desktop -Name $name -Value $snapshot[$name]}
 }
 [EarthSaverSettings]::SystemParametersInfo(0x11,[uint32]($snapshot['ScreenSaveActive'] -eq '1'),[IntPtr]::Zero,3)|Out-Null
 if(Test-Path "$root/Uninstall.exe"){Start-Process "$root/Uninstall.exe" -ArgumentList "/S _?=$root" -Wait|Out-Null}
 Remove-Item -LiteralPath $fixture -Recurse -Force -ErrorAction SilentlyContinue
}
