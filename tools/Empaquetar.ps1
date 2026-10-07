$ErrorActionPreference = 'Stop'
$taskRoot = [IO.Path]::GetFullPath((Join-Path $PSScriptRoot '..'))
$taskAslPath = Join-Path $taskRoot 'ASL\Furi.asl'
$taskHeader = Get-Content -LiteralPath $taskAslPath -TotalCount 1
if ($taskHeader -notmatch '^// Furi Autosplitter (\d+\.\d+\.\d+(?:-[A-Za-z0-9.]+)?)\s') {
    throw 'Cannot read release version from the ASL header.'
}
$taskVersion = $Matches[1]
$taskDist = Join-Path $taskRoot 'dist'
$taskStage = Join-Path $taskDist $taskVersion
$taskZip = Join-Path $taskDist ('Furi-Autosplitter-' + $taskVersion + '.zip')
New-Item -ItemType Directory -Path $taskStage -Force | Out-Null

$taskNames = @('Furi.asl','README.md','LEEME.md','CHANGELOG.md','CHANGELOG.es.md','REPORTAR-ERROR.md','LICENSE')
Copy-Item -LiteralPath $taskAslPath -Destination (Join-Path $taskStage 'Furi.asl') -Force
foreach ($taskName in $taskNames | Where-Object { $_ -ne 'Furi.asl' }) {
    $taskText = Get-Content -LiteralPath (Join-Path $taskRoot $taskName) -Raw -Encoding UTF8
    # The ZIP has a flat layout and excludes the repository-only section.
    if ($taskName -eq 'README.md') {
        $taskText = $taskText -replace '(?s)\r?\n## Repository\r?\n.*$', ''
    }
    if ($taskName -eq 'LEEME.md') {
        $taskText = $taskText -replace '(?s)\r?\n## Repositorio\r?\n.*$', ''
    }
    [IO.File]::WriteAllText((Join-Path $taskStage $taskName),$taskText,(New-Object Text.UTF8Encoding($false)))
}
$taskManifest = foreach ($taskName in $taskNames) {
    $taskHash = (Get-FileHash -LiteralPath (Join-Path $taskStage $taskName) -Algorithm SHA256).Hash
    '{0}  {1}' -f $taskHash,$taskName
}
[IO.File]::WriteAllLines((Join-Path $taskStage 'SHA256SUMS.txt'),[string[]]$taskManifest,(New-Object Text.UTF8Encoding($false)))
$taskPayload = @($taskNames + 'SHA256SUMS.txt' | ForEach-Object { Join-Path $taskStage $_ })
Compress-Archive -LiteralPath $taskPayload -DestinationPath $taskZip -Force
Write-Output ('Created: ' + $taskZip)
Get-FileHash -LiteralPath $taskZip -Algorithm SHA256 | Select-Object Algorithm,Hash,Path
