param(
    [Parameter(Mandatory=$true)][string]$Application,
    [string]$OutputDirectory = "$PSScriptRoot/../build/windows-display-results",
    [string[]]$Resolutions = @('1920x1080', '2496x1664', '3440x1440', '3840x1080', '3840x2160', '5120x1440', '5120x2880'),
    [switch]$ResizeAfterStartup
)
# Run on Windows with an interactive desktop. Tests the actual packaged EXE,
# not an editor, browser, or headless renderer. Captures GPU identity and images.
$ErrorActionPreference = 'Stop'
if ($env:OS -ne 'Windows_NT') { throw 'Windows with an interactive desktop is required' }
if ($ResizeAfterStartup -and -not ('EarthDisplayResize' -as [type])) {
    Add-Type @'
using System;
using System.Runtime.InteropServices;
public static class EarthDisplayResize {
    [StructLayout(LayoutKind.Sequential)] public struct Rect { public int left,top,right,bottom; }
    [DllImport("user32.dll",SetLastError=true)] public static extern bool GetClientRect(IntPtr window,out Rect rect);
    [DllImport("user32.dll",SetLastError=true)] public static extern bool GetWindowRect(IntPtr window,out Rect rect);
    [DllImport("user32.dll",SetLastError=true)] public static extern bool MoveWindow(IntPtr window,int x,int y,int width,int height,bool repaint);
    [DllImport("user32.dll")] public static extern int GetSystemMetrics(int index);
    [DllImport("user32.dll")] public static extern IntPtr SetThreadDpiAwarenessContext(IntPtr context);
    public static bool Resize(IntPtr window,int width,int height) {
        IntPtr previous=SetThreadDpiAwarenessContext(new IntPtr(-4));
        try {
            Rect outer,client;
            if(!GetWindowRect(window,out outer)||!GetClientRect(window,out client))return false;
            return MoveWindow(window,0,0,width+(outer.right-outer.left)-(client.right-client.left),height+(outer.bottom-outer.top)-(client.bottom-client.top),true);
        } finally { if(previous!=IntPtr.Zero)SetThreadDpiAwarenessContext(previous); }
    }
}
'@
}
$Application = (Resolve-Path $Application).Path
New-Item -ItemType Directory -Force $OutputDirectory | Out-Null
$OutputDirectory = (Resolve-Path $OutputDirectory).Path
if ($ResizeAfterStartup) {
    @{resize_after_startup=$true;desktop_pixels=@([EarthDisplayResize]::GetSystemMetrics(0),[EarthDisplayResize]::GetSystemMetrics(1));limits='Explicit post-start native client resize may extend outside the virtual desktop. Actual framebuffer dimensions still must match. This is not a physical monitor/DPI test.'}|ConvertTo-Json -Depth 5|Set-Content (Join-Path $OutputDirectory 'matrix-context.json') -Encoding UTF8
}
foreach ($resolution in $Resolutions) {
    $output = Join-Path $OutputDirectory $resolution
    if (Test-Path "$output/result.json") { Remove-Item "$output/result.json" }
    $arguments = @('--resolution', $resolution, '--', '--validate-display', ('--validation-output="' + $output + '"'))
    $process = Start-Process $Application -ArgumentList $arguments -PassThru
    if ($ResizeAfterStartup) {
        $size=$resolution.Split('x')
        $deadline=[DateTime]::UtcNow.AddSeconds(15)
        $resized=$false
        while (!$process.HasExited -and [DateTime]::UtcNow -lt $deadline) {
            $process.Refresh()
            if($process.MainWindowHandle -ne [IntPtr]::Zero) {
                $resized=[EarthDisplayResize]::Resize($process.MainWindowHandle,[int]$size[0],[int]$size[1])
                if($resized){break}
            }
            Start-Sleep -Milliseconds 20
        }
        if(!$resized){$process.CloseMainWindow()|Out-Null;throw "Could not request post-start native resize at $resolution"}
    }
    if (!$process.WaitForExit(90000)) { $process.CloseMainWindow() | Out-Null; throw "Validation timeout at $resolution" }
    if ($process.ExitCode -ne 0) { throw "Native application failed at $resolution (exit $($process.ExitCode))" }
    if (!(Test-Path "$output/result.json")) { throw "Missing fresh result for $resolution" }
    $report = Get-Content "$output/result.json" -Raw | ConvertFrom-Json
    $expected = $resolution.Split('x')
    if (!$report.passed -or $report.platform -ne 'Windows' -or $report.display -eq 'headless' -or $report.viewport[0] -ne [int]$expected[0] -or $report.viewport[1] -ne [int]$expected[1]) { throw "Display validation failed at $resolution" }
    Write-Host "PASS: Windows native EXE at $resolution on $($report.gpu)"
}
Write-Host "Evidence: $OutputDirectory. Review screenshots and test physical monitor DPI / refresh / performance separately."
