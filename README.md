# Furi Autosplitter — 1.0.0

[Español](LEEME.md) | English

By **Neimex23**. Version 1.0.0 for **LiveSplit on Windows**, **Extras > Speedrun Mode**, **Furi / Furier** difficulty, with optional Practice support. Cheat Engine, Lua and game modifications are not required.

This release packages the beta.8 functionality. The version number does not extend the tested coverage; see Support status below.

**The final boss splits automatically on victory results:** Star in Furi, Bernard in Furier. It uses the game's cumulative time without waiting for another arena or the final summary screen. This new behavior still needs a live Speedrun test.

## Setup

1. Extract the release ZIP or download this repository to a permanent folder. Cheat Engine, Lua and game modifications are not required.
2. Load your own LiveSplit splits, with one segment per boss in your intended route, including the final boss. The script does not create or reorder segments.
3. In **Edit Layout**, add **Control > Scriptable Auto Splitter**. In **Layout Settings**, select that component and set **Script Path** to `Furi.asl` (in `ASL/` if using the repository). If you already have the component, update its path. Only run one Furi autosplitter at a time.
4. Enable **Start** and **Split**. Leave auto reset off for the first test.
5. Select **Compare Against > Game Time** and save your layout.
6. Start Furi and wait for the script version to show `1.0.0 - compatible`. With LiveSplit reset to zero, enter Speedrun Mode and press START.

The autosplitter's interface, options and tooltips are in English. Documentation is available in Spanish and English.

## Behavior

- Starts when a new Speedrun attempt is detected at the first boss. Attaching during a fight or on a results screen does not start the timer; return to the menu and start a new attempt.
- Reads the game's cumulative timer, including its pause/load/results behavior. LiveSplit does not extrapolate between samples.
- Choose **Split on victory results (unchecked: next arena ready)**: checked splits on victory results using the cumulative game clock; unchecked waits for the next arena to be ready and uses its inherited total. Unchecked is the default. Configure the timing before starting an attempt.
- **The Star can only split on victory results**, regardless of the timing option, because there is no next arena. The final Bernard in Furier and all Practice victories also keep their results split.
- Intermediate phase splits are optional and off by default. Death or Continue does not split. Story does not trigger automatic actions. Practice is excluded unless its separate option is enabled.
- Optional auto reset: enable **Reset** and the script option `Reset LiveSplit when starting another Speedrun (experimental)`. Tested when restarting from pause or starting a new Speedrun from the menu during an active attempt. Manually reset LiveSplit after a finished run before starting another.
- The final boss splits once on victory results (Star in Furi, Bernard in Furier). LiveSplit finishes when this is your last segment.
- In the autosplitter options, keep **Boss splits** enabled and select each boss underneath. All boxes default to on; the general option disables all boss splits. Unchecking a boss skips its automatic split while Game Time keeps accumulating. Match your LiveSplit segments to the selected bosses; the script does not skip or remove segment rows. Configure these options before starting an attempt.

## Received-hit and KO counters (optional)

1. Add **Counter** to your LiveSplit layout. For hits, set its counter text to **Furi Hits** or **Hits**. For KO, add another Counter with text **Furi KO** or **KO**. Names are case insensitive and may end with a colon.
2. Enable **Track received hits in Counter (Furi Hits)** and/or **Track KO in Counter (Furi KO)**. Both are off by default. For Practice, also enable its separate mode option.
3. If tracking only one metric, a single default Counter (text **Counter** or empty) also works. With both metrics enabled, use two named counters so each receives its own value.

The counters mirror the game's cumulative received-hit and KO totals. They keep the last accepted totals through invalid readings and reset to zero on LiveSplit Start/Reset or a new accepted game session. Hits persist across death/Continue and boss transitions. This uses the game's hit definition, rather than counting damage amounts; parried hits are excluded by the game. Tracking works independently of boss/phase split selection. Manual edits to linked counters are overwritten while enabled; other counters stay untouched. Missing or duplicate matching counters are not written. Binding status is logged as linked, not found or ambiguous.

The memory recording covers The Chain → The Strap in Speedrun/Furi: 24 hits preserved through results and loading, including a previous death. Counter integration and other modes/difficulties still need live testing.

## Phase splits (optional)

Enable **Phase splits (Speedrun and Practice)** to split when the boss advances to the next phase. Keep **Boss splits** and the chosen boss enabled; for Practice, also enable **Practice Mode (split on boss defeat)**. Add one LiveSplit segment per phase instead of one per boss. The last phase uses the existing boss victory split, including your results/next-arena timing choice; it does not produce an extra split. Practice and The Star finish on victory results.

The option is off by default. Death, phase regression and replaying an already counted phase do not produce another split. Invalid readings and jumps over several phases are not reconstructed. For a new Practice attempt, reset LiveSplit and select a fresh session from the game menu. Configure options before starting.

Memory recordings confirm The Chain's phase counter in Furi difficulty, in Practice and Speedrun, with the same route after restarting Furi. The player also reported working phase splits and no split on death, without specifying mode, difficulty or boss. Other combinations and a complete fight/run remain to be verified.

## Practice (optional, experimental)

Enable **Practice Mode (split on boss defeat)** in the autosplitter options, with **Start**, **Split**, the general boss option and your chosen boss enabled. This option splits when you defeat the boss in the game's Practice mode, on victory results. Use one LiveSplit segment for the fight, or one per phase if phase splits are enabled. Reset LiveSplit before selecting a new Practice session from the game menu.

A new Practice session starts the timer when its arena is ready and its game clock is valid. Victory results split immediately for any selected boss, using the game's time for that session. Attaching during an existing fight/results does not start automatically. Story stays excluded. The Speedrun auto reset option does not reset Practice. In-arena restarts that reuse the same session are not automatically recognized; start a fresh Practice from the menu for another timed attempt.

Practice support passed synthetic logic checks. On 2026-10-07, the user also reported that Practice works, unchecking the boss prevents its split and the game clock works correctly. The boss, difficulty and character were not specified. The existing modified Star Practice recording only supports the memory/EndScreen diagnosis; other combinations and in-session restarts remain unverified.

## Support status

Tested with **LiveSplit 1.8.37** and one Windows Steam installation of Furi. Linux/Proton, consoles and other editions/builds have not been tested. Only these exact game binaries are enabled:

| File within Furi | Compatible SHA-256 |
| --- | --- |
| `MonoBleedingEdge/EmbedRuntime/mono-2.0-bdwgc.dll` | `47B2F85724C9473182DF93BB5EC11ADCEB07633E00899CFF7138F40349542DFF` |
| `Furi_Data/Managed/Assembly-CSharp.dll` | `303FAA314E027A44746B8D4400506118F419115F345F163AFAA74DED3FEA8465` |

**UNSUPPORTED BUILD** means the installed binaries differ and the script's actions are disabled; report the game build and hashes instead of removing the guard. This message appears in the script version while attached to the game.

Live-tested in Furi difficulty: start, game clock and pauses, Chain results, transition/split to Strap, time continuity, death/Continue on Strap and both restart paths. Furier start/restart and clock/pauses were also reported working. Compilation and recorded/synthetic replay tests cover transitions, duplicate prevention, invalid samples and Practice exclusion.

Still needed: a complete run, remaining bosses, a recorded Furier victory/transition, detailed coverage of DLC/character combinations, other systems/builds, and live verification of the new final victory split. A modified Practice test of the final boss is diagnostic only. Do not treat this as a fully validated release.

**DLC: reported working.** On 2026-10-07, the user confirmed that Bernard and The Flame work correctly. This is player-reported live evidence; the mode, difficulty and exact timing checks were not specified. Onnamusha start, clock and intermediate splits were previously reported working in Furi and Furier.

User feedback on 2026-10-07: Onnamusha worked well in both Furi and Furier after beta.2 was delivered. The user confirmed start, game clock and intermediate splits; the final split was not tested.

## Feedback

First test START, a few seconds of combat and pause. With default options, check intermediate results without splitting, one split when entering the next boss and Game Time continuity. If results or phase splitting is enabled, check the corresponding events. Then follow the route and note any skipped or duplicate segments. Cheat Engine is not needed for testing.

Please use `REPORTAR-ERROR.md` (English or Spanish replies welcome). Include difficulty, boss, game/LiveSplit version, exact steps, expected/actual behavior and both timer values. Mention built-in invincibility, phase skips, trainers or mods. A short video or screenshot helps.

If it does not start, check the compatible version, Start enabled, Speedrun Mode and that the script was loaded before START. If the displayed timer advances while Furi is paused, check **Compare Against > Game Time**. Do not reload/edit the script during an attempt you want to measure, as that clears its tracking state.

The package contains no executables, game DLLs, save data, Cheat Engine tools or developer-machine paths. Share the complete ZIP so testers receive these instructions.

## Repository

To continue or extend the project, start with [project context and current evidence](docs/CONTEXT.en.md) and [the contribution guide](CONTRIBUTING.en.md). [AGENTS.en.md](AGENTS.en.md) gives coding agents the same entry point. These documents explain the agreed timing/split behavior, memory routes, tested scenarios, unresolved assumptions and next investigations. Each guide links to its Spanish version.

- [ASL/Furi.asl](ASL/Furi.asl): the autosplitter; this is the source used to build release ZIPs.
- [LEEME.md](LEEME.md): Spanish setup and compatibility hashes.
- [CHANGELOG.md](CHANGELOG.md): release notes.
- [REPORTAR-ERROR.md](REPORTAR-ERROR.md): tester feedback template, also available when opening a GitHub issue.
- [docs/DEVELOPMENT.en.md](docs/DEVELOPMENT.en.md): architecture, verification and packaging commands.
- [docs/PUBLISHING.en.md](docs/PUBLISHING.en.md): publishing a release, registering with LiveSplit and delivering updates.
- `tests/`: compile check, recorded/synthetic replay and a recorded Chain → Strap fixture.
- `tools/`: optional Cheat Engine diagnostics, inspection utilities and release packaging.

Generated ZIPs go in `dist/`. Local research and game IL dumps belong in `local/`. Both directories are excluded from Git.
