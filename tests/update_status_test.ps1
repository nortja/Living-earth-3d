$ErrorActionPreference = 'Stop'
. "$PSScriptRoot/../packaging/windows/update-core.ps1"
$checks = 0
function Assert-Status($Value, $Message) { $script:checks++; if (!$Value) { throw $Message } }
$directory = Join-Path ([IO.Path]::GetTempPath()) ('earth-status-' + [guid]::NewGuid().ToString('N'))
New-Item -ItemType Directory -Path $directory | Out-Null
$path = Join-Path $directory 'status.json'
try {
    $unicodeMessage = 'Checking' + [char]0x2026 + ' ' + [char]0x5730 + [char]0x7403
    Assert-Status (Write-EarthUpdateStatus $directory 'checking' $unicodeMessage) 'Initial status write failed'
    $status = Get-Content -LiteralPath $path -Raw -Encoding UTF8 | ConvertFrom-Json
    Assert-Status ($status.state -eq 'checking' -and $status.message -eq $unicodeMessage) 'Status did not roundtrip Unicode'
    Assert-Status (([DateTime]$status.utc).ToUniversalTime() -gt [DateTime]::UtcNow.AddMinutes(-1)) 'Status timestamp missing/stale'
    # Many replacements exercise the existing-file path that Move-Item -Force used.
    foreach ($index in 1..100) {
        Assert-Status (Write-EarthUpdateStatus $directory 'downloading' "Progress $index") 'Repeated replacement failed'
        $status = Get-Content -LiteralPath $path -Raw | ConvertFrom-Json
        Assert-Status ($status.message -eq "Progress $index") 'Reader saw stale or partial JSON'
    }
    if ([Environment]::OSVersion.Platform -eq [PlatformID]::Win32NT) {
        # Reproduce a UI reader denying delete sharing. Atomic replacement must
        # retry, preserve the last complete status, and clean temporary files.
        $before = [IO.File]::ReadAllText($path)
        $reader = [IO.File]::Open($path, [IO.FileMode]::Open, [IO.FileAccess]::Read, [IO.FileShare]::Read)
        try {
            $timer = [Diagnostics.Stopwatch]::StartNew()
            Assert-Status (!(Write-EarthUpdateStatus $directory 'ready' 'Blocked' -WarningAction SilentlyContinue)) 'Locked status unexpectedly replaced'
            Assert-Status ($timer.Elapsed.TotalSeconds -lt 5) 'Status retry was not bounded'
            Assert-Status ([IO.File]::ReadAllText($path) -ceq $before) 'Failed replacement damaged last status'
            Assert-Status (@(Get-ChildItem -LiteralPath $directory -Filter '*.tmp').Count -eq 0) 'Failed replacement leaked temporary files'
        } finally { $reader.Dispose() }
        Assert-Status (Write-EarthUpdateStatus $directory 'ready' 'Recovered') 'Replacement did not recover after reader closed'
        # Release another lock during the retry window using a CLR timer thread.
        Add-Type @'
using System;
using System.IO;
using System.Threading;
public static class EarthStatusLock {
    public static Timer ReleaseLater(FileStream stream) {
        return new Timer(_ => stream.Dispose(), null, 200, Timeout.Infinite);
    }
}
'@
        $reader = [IO.File]::Open($path, [IO.FileMode]::Open, [IO.FileAccess]::Read, [IO.FileShare]::Read)
        $release = [EarthStatusLock]::ReleaseLater($reader)
        try {
            Assert-Status (Write-EarthUpdateStatus $directory 'installing' 'Recovered during retry') 'Transient lock did not recover within retry window'
        } finally { $release.Dispose(); $reader.Dispose() }
    } else { Write-Output 'Windows delete-sharing contention checks skipped on this platform.' }
    # Permanent failure must be advisory even under ErrorActionPreference Stop.
    $missing = Join-Path $directory 'missing'
    Assert-Status (!(Write-EarthUpdateStatus $missing 'error' 'Unavailable directory' -WarningAction SilentlyContinue)) 'Unavailable directory reported success'
    Assert-Status (@(Get-ChildItem -LiteralPath $directory -Filter '*.tmp').Count -eq 0) 'Status writes leaked temporary files'
    Write-Output "Update status: $checks checks passed"
} finally { Remove-Item -LiteralPath $directory -Recurse -Force }
