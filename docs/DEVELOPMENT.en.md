# Development and verification

[Español](DEVELOPMENT.md) | English

Before extending the project, read [CONTEXT.en.md](CONTEXT.en.md) for the current state and evidence, and [CONTRIBUTING.en.md](../CONTRIBUTING.en.md) for investigation and delivery procedures.

The reference file is `ASL/Furi.asl`. LiveSplit can load it directly from the repository. No executable compilation or Cheat Engine installation is needed to use it.

## Readings and events

Beta.8 adds `koCounter` (Statistics +0x24) and a resolver shared with hits. It recognizes Furi Hits/Hits and Furi KO/KO without case sensitivity and with optional trailing colons. A single default Counter can receive the only enabled metric; both metrics require separate names. Missing/ambiguous matches are not written and are logged when binding status changes. The options are independent and off by default. Tests with the installed Counter DLL cover KO, aliases, both counters separately, selective reset and default fallback without crossing metrics.

Beta.7 introduced `hitCounter`, off by default. It reads Statistics._hits at +0x28 through the same validated route as the clock and originally synchronized one Counter labeled exactly Furi Hits via the SetCount API (reflection keeps Counter optional). It does not simulate hotkeys or modify unrelated counters. It keeps session maxima, ignores invalid/negative readings and clears on Start/Reset or a new session. Accepted modes are Speedrun and enabled Practice; it does not depend on split checkboxes. The Speedrun/Furi recording confirmed death/resume and Chain → Strap with 24 hits preserved. The real layout connection and other combinations remain unverified.

The hits harness requires the installed Counter DLL (not distributed): it uses the real implementation in an isolated layout/timer to check names, totals, unrelated counters, ambiguity, disabled options, invalid samples, modes and reset. It also checks manual Start/Reset with supported=false. It does not modify Counter in the open LiveSplit instance.

Beta.6 adds `phaseSplits`, off by default. In Speedrun and enabled Practice, it splits on an observed one-phase advance in the same fight, with valid Statistics and boss checkboxes enabled. The last phase keeps the existing victory split and timing. It does not count regressions/repetitions or reconstruct multi-phase jumps or gaps. Phase route: domain +0x1EAE8 → PawnManager +0x48 → AIPawn +0x1D8 → controller; index +0x1B8 and configuration +0xF0 → list +0x18 → size +0x18. Checked in LAW/Furi recordings in Practice and Speedrun and in a new process. The player also reported working phase splits and no split on death, without specifying mode, difficulty or boss; other combinations remain pending. See [CONTEXT.en.md](CONTEXT.en.md).

The harness covers phases in modes 3/4 and difficulties 1/2: a single advance, filters, regression, gaps/NaN, invalid data, multi-phase jumps, Game Time and coordination with final victory. These are synthetic samples; `init` checks modules/hashes in the real process.

Since beta.5, ASL options are in English. For 1.0.0 the user chose to keep the ASL in English and provide documentation in Spanish and English. `splitOnResults` chooses victory results (valid cumulative Statistics) or the next ready arena (Chrono._initialTime); it is off by default, keeping the latter behavior. The Star always splits on results, as do Practice and final Bernard in Furier. Boss checkboxes apply to both timings. Tests cover results in difficulties 1/2, invalid data, death/phases, duplicates after loading and disabled bosses, alongside next-arena regressions.

Version 1.0.0 preserves beta.8 behavior and enables only the build whose hashes are in [LEEME.md](../LEEME.md) and [README.md](../README.md). The root is read from `mono-2.0-bdwgc.dll + 0x49AC78`; GameManager is resolved from the Mono domain at `+0x1ED08` and GlobalGameManager at `+0x1EF48`. The routes were checked after restarting the process. They are specific to that build.

Game Time comes from `GameDataInfo._currentStatistics -> Statistics._time`. The ASL keeps the last valid time through reading gaps and prevents LiveSplit extrapolation. When the next arena is ready, the split uses `Chrono._initialTime`, the total inherited from the previous boss.

By default, an intermediate victory stays pending until another arena loads, producing one split. Story produces no actions. Practice requires its separate option. Start requires a new Speedrun session at LAW; attaching during a fight or results does not start the timer. Resetting an active attempt is optional. The final boss splits on victory results: MOTHERSHIP in Furi and BERNARD in Furier, using valid cumulative Statistics. Completion in a real Speedrun remains to be checked.

Since beta.3, `bossSplits` keeps the general option and its `boss_<ID>` children select individual bosses. All default to on. An unchecked event is consumed without splitting or replacing Game Time with the inherited boundary. Synthetic tests check all 12 boxes, the general option's priority, the clock after skipping, pending-event cleanup and the next session with the boss enabled.

## Checking the ASL

Since beta.4, `practiceMode` enables mode 3, starting in a ready arena in a new session and splitting on victory results, using the same boss checkboxes and Statistics. It is off by default. Auto reset remains Speedrun-only. Synthetic cases cover both difficulties, loading, pauses/gaps, death/phases/NaN, focus loss, a single victory, disabled boxes, attaching and mode changes. Practice restarts within the same session are not automatically recognized: reset manually and select a new session from the menu.

Run from the repository root using **Windows PowerShell 5.1** (`powershell.exe`), with LiveSplit and its Scriptable Auto Splitter component installed. Replace the example path with your installation. Their DLLs are not included in the repository.

```powershell
powershell.exe -NoProfile -File .\tests\ValidarASL.ps1 -LiveSplitPath 'C:\LiveSplit'
```

The installed component's parser compiles all ASL blocks. To replay the recording and synthetic cases, open the compatible build of Furi and run:

```powershell
powershell.exe -NoProfile -File .\tests\ReproducirRegistro.ps1 -LiveSplitPath 'C:\LiveSplit'
```

With multiple processes, also supply `-GameProcessId`. The test uses an isolated timer; it does not change the open LiveSplit timer. `init` inspects process modules and checks their hashes; subsequent samples come from recordings or synthetic cases. Replay requires permission to read the process.

`tests/fixtures/chain-strap.txt` contains session observations, without game files. Its addresses identify objects only within that recording; they are not used as pointers into the current process. Tests cover start, optional reset, victory/transition, duplicates, pauses/loading, invalid data, inherited time, disabled Practice and synthetic final victories for both difficulties. These cases do not replace a full live run.

## Building the distribution package

```powershell
powershell.exe -NoProfile -File .\tools\Empaquetar.ps1
```

The version comes from the header of `ASL/Furi.asl`. The script copies the ASL, English/Spanish player instructions and changelogs, the bilingual report template and LICENSE, generates `SHA256SUMS.txt`, and creates `dist/Furi-Autosplitter-<version>.zip`. Regenerate it after updating those files. It does not package tools, research, tests or external binaries. See [PUBLISHING.en.md](PUBLISHING.en.md) for releases, LiveSplit registration and updates.

## Research

- `tools/cheat-engine/`: Lua diagnostics; read its English or Spanish README first.
- `tools/inspection/`: utilities for inspecting the ASL component and classes in your own game installation.
- `local/`: private notes, raw recordings and IL dumps, excluded from Git.
- `dist/`: generated packages, excluded from Git; ZIPs can be attached to releases.

Do not add game DLLs, saves or layouts with personal paths to the repository. Game IL dumps belong in `local/`.

Still pending: complete runs, remaining bosses, a recorded Furier victory/transition, detailed DLC/character coverage, other builds and live verification of the final victory split. The final-boss Practice test used invincibility and phase skipping and is diagnostic. The inherited-total adjustment passed replay; live comparison with this revision remains pending.
