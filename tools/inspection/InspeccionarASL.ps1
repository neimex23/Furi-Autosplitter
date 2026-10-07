param([Parameter(Mandatory=$true)][string]$LiveSplitPath)
$ErrorActionPreference = 'Stop'
$taskLiveSplitPath = (Resolve-Path -LiteralPath $LiveSplitPath).Path
[Environment]::CurrentDirectory = $taskLiveSplitPath
foreach ($taskDll in (Get-ChildItem -LiteralPath $taskLiveSplitPath -Filter '*.dll')) {
    try { [Reflection.Assembly]::LoadFrom($taskDll.FullName) | Out-Null } catch { }
}
$taskAslAssembly = [Reflection.Assembly]::LoadFrom((Join-Path $taskLiveSplitPath 'Components\LiveSplit.ScriptableAutoSplit.dll'))
try { $taskAslTypes = $taskAslAssembly.GetTypes() }
catch [Reflection.ReflectionTypeLoadException] {
    $_.Exception.LoaderExceptions | ForEach-Object { Write-Output $_.Message }
    $taskAslTypes = $_.Exception.Types | Where-Object { $null -ne $_ }
}
foreach ($taskAslType in ($taskAslTypes | Where-Object { $_.Name -match 'ASLScript|ASLParser|ASLMethod|SettingsReader|SettingsBuilder' })) {
    Write-Output $taskAslType.FullName
    $taskAslType.GetConstructors() | ForEach-Object { Write-Output $_.ToString() }
    $taskAslType.GetMethods() | Where-Object { $_.DeclaringType -eq $taskAslType } | ForEach-Object { Write-Output $_.ToString() }
}
