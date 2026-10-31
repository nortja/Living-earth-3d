param([string]$Output = "$PSScriptRoot/../dist/packaged-desktop/monitor-query-cost.json")
# Diagnostic only: no frame-rate threshold, data request or application modification.
$ErrorActionPreference='Stop'
if($env:OS -ne 'Windows_NT'){throw 'Windows monitor-query probe requires Windows'}
if(-not ('EarthMonitorProbe' -as [type])){
 Add-Type @'
using System;
using System.Diagnostics;
using System.Runtime.InteropServices;
public static class EarthMonitorProbe {
    private delegate bool MonitorCallback(IntPtr monitor,IntPtr dc,IntPtr rect,IntPtr data);
    [DllImport("user32.dll")] private static extern IntPtr GetDesktopWindow();
    [DllImport("user32.dll")] private static extern IntPtr MonitorFromWindow(IntPtr window,uint flags);
    [DllImport("user32.dll")] private static extern bool EnumDisplayMonitors(IntPtr dc,IntPtr clip,MonitorCallback callback,IntPtr data);
    private static IntPtr target;
    private static int found;
    private static bool Visit(IntPtr monitor,IntPtr dc,IntPtr rect,IntPtr data){if(monitor==target)found++;return true;}
    private static readonly MonitorCallback callback=Visit;
    public static double Measure(int calls){
        IntPtr window=GetDesktopWindow();
        found=0;
        Stopwatch watch=Stopwatch.StartNew();
        for(int i=0;i<calls;i++){
            target=MonitorFromWindow(window,2);
            if(!EnumDisplayMonitors(IntPtr.Zero,IntPtr.Zero,callback,IntPtr.Zero))throw new InvalidOperationException("Monitor enumeration failed");
        }
        watch.Stop();
        if(found!=calls)throw new InvalidOperationException("Monitor identity did not resolve");
        return watch.Elapsed.TotalMilliseconds/calls;
    }
}
'@
}
$values=@()
for($batch=0;$batch -lt 5;$batch++){$values += [EarthMonitorProbe]::Measure(200)}
$report=@{kind='Windows-monitor-query-probe';calls_per_batch=200;milliseconds_per_call=$values;limits='MonitorFromWindow plus EnumDisplayMonitors on this disposable CI desktop. API cost is not a Godot frame-time measurement or physical hardware result.'}
New-Item -ItemType Directory -Force (Split-Path -Parent $Output)|Out-Null
$report|ConvertTo-Json -Depth 5|Set-Content -Encoding UTF8 $Output
$report|ConvertTo-Json -Depth 5|Write-Output
