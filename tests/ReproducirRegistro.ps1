param(
    [Parameter(Mandatory=$true)]
    [string]$LiveSplitPath,
    [int]$GameProcessId = 0
)
$ErrorActionPreference='Stop'
$taskLiveSplitPath=(Resolve-Path -LiteralPath $LiveSplitPath).Path
[Environment]::CurrentDirectory=$taskLiveSplitPath
foreach($taskDll in (Get-ChildItem -LiteralPath $taskLiveSplitPath -Filter '*.dll')) {
    try { [Reflection.Assembly]::LoadFrom($taskDll.FullName) | Out-Null } catch { }
}
$taskCore=Join-Path $taskLiveSplitPath 'LiveSplit.Core.dll'
$taskComponent=Join-Path $taskLiveSplitPath 'Components\LiveSplit.ScriptableAutoSplit.dll'
[Reflection.Assembly]::LoadFrom($taskComponent) | Out-Null
Add-Type -Path (Join-Path $PSScriptRoot 'ReproducirRegistro.cs') -ReferencedAssemblies @($taskCore,$taskComponent,'Microsoft.CSharp.dll','System.Core.dll','System.dll')
if ($GameProcessId -eq 0) {
    $taskGames=@(Get-Process Furi -ErrorAction SilentlyContinue)
    if ($taskGames.Count -ne 1) { throw 'Open one Furi process, or supply -GameProcessId.' }
    $GameProcessId=$taskGames[0].Id
}
[FuriReplay]::Run((Join-Path $PSScriptRoot '..\ASL\Furi.asl'),(Join-Path $PSScriptRoot 'fixtures\chain-strap.txt'),$GameProcessId)
