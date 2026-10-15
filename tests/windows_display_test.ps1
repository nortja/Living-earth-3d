param(
    [Parameter(Mandatory=$true)][string]$Application,
    [string]$OutputDirectory = "$PSScriptRoot/../build/windows-display-results"
)
# Run on Windows with an interactive desktop. Tests the actual packaged EXE,
# not an editor, browser, or headless renderer. Captures GPU identity and images.
$ErrorActionPreference = 'Stop'
if (!$IsWindows) { throw 'Windows with an interactive desktop is required' }
$Application = (Resolve-Path $Application).Path
New-Item -ItemType Directory -Force $OutputDirectory | Out-Null
$OutputDirectory = (Resolve-Path $OutputDirectory).Path
foreach ($resolution in @('1920x1080', '3440x1440', '3840x2160', '5120x1440', '5120x2880')) {
    $output = Join-Path $OutputDirectory $resolution
    if (Test-Path "$output/result.json") { Remove-Item "$output/result.json" }
    $arguments = @('--resolution', $resolution, '--', '--validate-display', ('--validation-output="' + $output + '"'))
    $process = Start-Process $Application -ArgumentList $arguments -PassThru
    if (!$process.WaitForExit(90000)) { $process.CloseMainWindow() | Out-Null; throw "Validation timeout at $resolution" }
    if ($process.ExitCode -ne 0) { throw "Native application failed at $resolution (exit $($process.ExitCode))" }
    if (!(Test-Path "$output/result.json")) { throw "Missing fresh result for $resolution" }
    $report = Get-Content "$output/result.json" -Raw | ConvertFrom-Json
    $expected = $resolution.Split('x')
    if (!$report.passed -or $report.platform -ne 'Windows' -or $report.display -eq 'headless' -or $report.viewport[0] -ne [int]$expected[0] -or $report.viewport[1] -ne [int]$expected[1]) { throw "Display validation failed at $resolution" }
    Write-Host "PASS: Windows native EXE at $resolution on $($report.gpu)"
}
Write-Host "Evidence: $OutputDirectory. Review screenshots and test physical monitor DPI / refresh / performance separately."
