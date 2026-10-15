# Shared build runner. ArgumentList preserves spaces without shell interpolation.
function Invoke-EarthGodot {
    param(
        [Parameter(Mandatory)][string]$Executable,
        [Parameter(Mandatory)][string]$ProjectPath,
        [Parameter(Mandatory)][string[]]$Arguments,
        [Parameter(Mandatory)][string]$LogPath,
        [int]$TimeoutSeconds = 240
    )
    $ErrorActionPreference = 'Stop'
    $command = (Get-Command $Executable -ErrorAction Stop).Source
    $LogPath = [IO.Path]::GetFullPath($LogPath)
    New-Item -ItemType Directory -Force (Split-Path $LogPath) | Out-Null
    if (Test-Path -LiteralPath $LogPath) { Remove-Item -LiteralPath $LogPath }
    $start = [Diagnostics.ProcessStartInfo]::new()
    $start.FileName = $command
    $start.WorkingDirectory = [IO.Path]::GetFullPath($ProjectPath)
    $start.UseShellExecute = $false
    $start.CreateNoWindow = $true
    $start.RedirectStandardOutput = $true
    $start.RedirectStandardError = $true
    foreach ($argument in (@('--headless', '--path', $start.WorkingDirectory, '--log-file', $LogPath) + $Arguments)) {
        $start.ArgumentList.Add($argument)
    }
    $process = [Diagnostics.Process]::new()
    $process.StartInfo = $start
    try {
        if (!$process.Start()) { throw 'Godot did not start' }
        $stdout = $process.StandardOutput.ReadToEndAsync()
        $stderr = $process.StandardError.ReadToEndAsync()
        if (!$process.WaitForExit($TimeoutSeconds * 1000)) {
            $process.Kill($true)
            $process.WaitForExit()
            throw "Godot timed out after $TimeoutSeconds seconds"
        }
        $captured = $stdout.GetAwaiter().GetResult() + $stderr.GetAwaiter().GetResult()
        if ($captured) { Write-Host $captured }
        if ($process.ExitCode -ne 0) { throw "Godot exited with code $($process.ExitCode)" }
        if (!(Test-Path -LiteralPath $LogPath)) { throw 'Godot produced no fresh runtime log' }
        $runtime = Get-Content -LiteralPath $LogPath -Raw
        if (($runtime + "`n" + $captured) -match '(?m)^\s*(SCRIPT ERROR:|ERROR:)') {
            throw "Godot reported runtime errors; see $LogPath"
        }
    } finally { $process.Dispose() }
}
