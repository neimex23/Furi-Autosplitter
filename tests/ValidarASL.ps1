param([Parameter(Mandatory=$true)][string]$LiveSplitPath)
$ErrorActionPreference = 'Stop'
$taskLiveSplitPath = (Resolve-Path -LiteralPath $LiveSplitPath).Path
[Environment]::CurrentDirectory = $taskLiveSplitPath
foreach ($taskDll in (Get-ChildItem -LiteralPath $taskLiveSplitPath -Filter '*.dll')) {
    try { [Reflection.Assembly]::LoadFrom($taskDll.FullName) | Out-Null } catch { }
}
[Reflection.Assembly]::LoadFrom((Join-Path $taskLiveSplitPath 'Components\LiveSplit.ScriptableAutoSplit.dll')) | Out-Null
$taskSource = Get-Content -LiteralPath (Join-Path $PSScriptRoot '..\ASL\Furi.asl') -Raw
try {
    [LiveSplit.ASL.ASLParser]::Parse($taskSource) | Out-Null
    Write-Output 'ASL PARSE AND COMPILE OK (installed LiveSplit component)'
} catch {
    Write-Output $_.Exception.ToString()
    exit 1
}
