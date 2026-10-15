$ErrorActionPreference = 'Stop'
foreach ($file in @('packaging/windows/build.ps1','packaging/windows/update.ps1','packaging/windows/set-icon.ps1','tests/windows_display_test.ps1','packaging/windows/invoke-godot.ps1','tests/godot_process_test.ps1')) {
    $tokens = $null
    $errors = $null
    [Management.Automation.Language.Parser]::ParseFile((Join-Path $pwd $file), [ref]$tokens, [ref]$errors) | Out-Null
    if ($errors.Count) { throw ($errors | Out-String) }
    Write-Output "Parsed $file"
}
$content = Get-Content packaging/windows/set-icon.ps1 -Raw
$source = [regex]::Match($content, "(?s)Add-Type @'\r?\n(.*?)\r?\n'@").Groups[1].Value
if (!$source) { throw 'Icon resource C# not found' }
Add-Type -TypeDefinition $source
Write-Output 'Compiled native Windows icon resource helper successfully (Windows APIs not invoked on Linux)'
