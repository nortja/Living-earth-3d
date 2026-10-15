param([string]$Godot = 'godot')
$ErrorActionPreference = 'Stop'
. "$PSScriptRoot/../packaging/windows/invoke-godot.ps1"
$fixture = Join-Path $PSScriptRoot '../build/process helper fixture'
New-Item -ItemType Directory -Force $fixture | Out-Null
New-Item -ItemType File -Force "$fixture/.gdignore" | Out-Null
$fixture = (Resolve-Path $fixture).Path
Set-Content "$fixture/project.godot" "config_version=5`n[application]`nconfig/name=`"Process test`""
Set-Content "$fixture/pass.gd" "extends SceneTree`nfunc _initialize():`n    print(`"fixture completed`" )`n    quit(0)"
Set-Content "$fixture/fail.gd" "extends SceneTree`nfunc _initialize():`n    push_error(`"intentional fixture error`" )`n    quit(0)"
Set-Content "$fixture/exit.gd" "extends SceneTree`nfunc _initialize():`n    quit(7)"
Set-Content "$fixture/wait.gd" "extends SceneTree`nfunc _initialize():`n    pass"
$log = "$fixture/log with spaces.txt"
Set-Content $log 'stale log must be replaced'
Invoke-EarthGodot -Executable $Godot -ProjectPath $fixture -Arguments @('--script','pass.gd') -LogPath $log
if ((Get-Content $log -Raw) -notmatch 'fixture completed' -or (Get-Content $log -Raw) -match 'stale log') { throw 'Fresh runtime evidence missing' }
foreach ($case in @(@('fail.gd','runtime errors'), @('exit.gd','code 7'), @('wait.gd','timed out'))) {
    $caught = $false
    $timeout = if ($case[0] -eq 'wait.gd') { 2 } else { 15 }
    try { Invoke-EarthGodot -Executable $Godot -ProjectPath $fixture -Arguments @('--script',$case[0]) -LogPath $log -TimeoutSeconds $timeout }
    catch { if ($_.Exception.Message.Contains($case[1])) { $caught = $true } else { throw } }
    if (!$caught) { throw "Runner failed to reject $($case[0])" }
}
Write-Host 'PASS: actual Godot execution, paths with spaces, fresh log replacement, runtime-error rejection, nonzero exit and timeout handling'
