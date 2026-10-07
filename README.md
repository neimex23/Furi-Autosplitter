# Furi Autosplitter — 0.1.0-beta.1

Community test build for **LiveSplit on Windows**, **Extras > Speedrun Mode**, **Furi / Furier** difficulty. [Instrucciones en español](LEEME.md).

**The final split is MANUAL in this beta.** After defeating the final boss, check that the in-game clock has stopped on the results screen, then press your split hotkey. Automatic detection of the final Speedrun screen is not validated yet.

## Setup

1. Extract the release ZIP or download this repository to a permanent folder. Cheat Engine, Lua and game modifications are not required.
2. Load your own LiveSplit splits, with one segment per boss in your intended route, including the final boss. The script does not create or reorder segments.
3. In **Edit Layout**, add **Control > Scriptable Auto Splitter**. In **Layout Settings**, select that component and set **Script Path** to `Furi.asl` (in `ASL/` if using the repository). If you already have the component, update its path. Only run one Furi autosplitter at a time.
4. Enable **Start** and **Split**. Leave auto reset off for the first test.
5. Select **Compare Against > Game Time** and save your layout.
6. Start Furi and wait for the script version to show `0.1.0-beta.1 - compatible`. With LiveSplit reset to zero, enter Speedrun Mode and press START.

## Behavior

- Starts when a new Speedrun attempt is detected at the first boss. Attaching during a fight or on a results screen does not start the timer; return to the menu and start a new attempt.
- Reads the game's cumulative timer, including its pause/load/results behavior. LiveSplit does not extrapolate between samples.
- Records a boss victory, then **splits when the next boss arena is ready**. It uses the cumulative time inherited by the new boss so the previous split does not include the new arena's first frames.
- No split on results, intermediate phases, death or Continue. Story and Practice do not trigger automatic actions.
- Optional auto reset: enable **Reset** and the script option `Reiniciar LiveSplit al iniciar otra Carrera (experimental)`. Tested when restarting from pause or starting a new Speedrun from the menu during an active attempt. Manually reset LiveSplit after a finished run before starting another.
- The final split must be made manually.

## Support status

Tested with **LiveSplit 1.8.37** and one Windows Steam installation of Furi. Only the exact game binaries documented in `LEEME.md` are enabled. **BUILD NO COMPATIBLE** means the installed binaries differ and the script's actions are disabled; report the game build and hashes instead of removing the guard.

Live-tested in Furi difficulty: start, game clock and pauses, Chain results, transition/split to Strap, time continuity, death/Continue on Strap and both restart paths. Furier start/restart and clock/pauses were also reported working. Compilation and recorded/synthetic replay tests cover transitions, duplicate prevention, invalid samples and Practice exclusion.

Still needed: a complete run, remaining bosses, a recorded Furier victory/transition, DLC/additional characters, other systems/builds, and automatic final-run completion. A modified Practice test of the final boss is diagnostic only. Do not treat this as a fully validated release.

## Feedback

Please use `REPORTAR-ERROR.md` (English or Spanish replies welcome). Include difficulty, boss, game/LiveSplit version, exact steps, expected/actual behavior and both timer values. Mention built-in invincibility, phase skips, trainers or mods. A short video or screenshot helps.

If it does not start, check the compatible version, Start enabled, Speedrun Mode and that the script was loaded before START. If the displayed timer advances while Furi is paused, check **Compare Against > Game Time**. Do not reload/edit the script during an attempt you want to measure, as that clears its tracking state.

The package contains no executables, game DLLs, save data, Cheat Engine tools or developer-machine paths. Share the complete ZIP so testers receive these instructions.

## Repository

To continue or extend the project, start with [project context and current evidence (Spanish)](docs/CONTEXT.md) and [the contribution guide (Spanish)](CONTRIBUTING.md). [AGENTS.md](AGENTS.md) gives coding agents the same entry point. These documents explain the agreed timing/split behavior, memory routes, tested scenarios, unresolved assumptions and next investigations.

- [ASL/Furi.asl](ASL/Furi.asl): the autosplitter; this is the source used to build release ZIPs.
- [LEEME.md](LEEME.md): Spanish setup and compatibility hashes.
- [CHANGELOG.md](CHANGELOG.md): release notes.
- [REPORTAR-ERROR.md](REPORTAR-ERROR.md): tester feedback template, also available when opening a GitHub issue.
- [docs/DEVELOPMENT.md](docs/DEVELOPMENT.md): architecture, verification and packaging commands.
- `tests/`: compile check, recorded/synthetic replay and a recorded Chain → Strap fixture.
- `tools/`: optional Cheat Engine diagnostics, inspection utilities and release packaging.

Generated ZIPs go in `dist/`. Local research and game IL dumps belong in `local/`. Both directories are excluded from Git.
