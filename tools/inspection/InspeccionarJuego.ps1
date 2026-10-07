param(
    [Parameter(Mandatory=$true)][string]$GameAssemblyPath,
    [string]$GameType='Chrono'
)
$ErrorActionPreference='Stop'
Add-Type -Path (Join-Path $PSScriptRoot 'InspeccionarJuego.cs')
[FuriIL]::Dump((Resolve-Path -LiteralPath $GameAssemblyPath).Path,$GameType)
