# Contributing

[Español](CONTRIBUTING.md) | English

Start with [docs/CONTEXT.en.md](docs/CONTEXT.en.md) to understand the project. It separates current decisions, live tests, recordings, replays and hypotheses. [docs/DEVELOPMENT.en.md](docs/DEVELOPMENT.en.md) explains how to run the tools.

## Reporting or checking behavior

No programming or Cheat Engine is needed to test the autosplitter. Use [REPORTAR-ERROR.md](REPORTAR-ERROR.md) or the repository issue template. Record the ASL and LiveSplit versions, game build, mode, difficulty, character/DLC, enabled options, steps and the game clock compared with Game Time.

For a transition with default options, observe results and the next arena: time should stop according to the game clock, intermediate bosses should not split on results, the script should split once when the arena is ready, and cumulative time should continue. With results or phase splits enabled, check the corresponding events. State whether built-in invincibility, phase skipping or modifications were used.

Compare **Game Time** in LiveSplit. Real Time can continue while the game's clock is stopped. After a finished run, reset manually before the next attempt. Avoid reloading the ASL during a run you want to measure.

## Investigating an event or build

1. Define the specific case and expected result, such as Furier Speedrun completion after its final boss.
2. Record hashes, mode, difficulty and ASL revision. A build with different hashes needs its own validated memory routes.
3. Use `tools/cheat-engine/ValidarRutaPartida.lua` with an arena loaded and `RegistrarRutas.lua` for the sequence. These Lua files are optional research tools; read their README first.
4. Capture before, during and after the event. Also record a similar case that must not trigger it: loading, death, exiting to the menu, restarting or Practice.
5. Check classes and fields, and repeat the routes in a new process. Keep raw recordings in `local/`; add relevant public evidence without personal paths or dumps of game code.

The monitor polls every 100 ms and writes when the described state changes. It does not record every frame or every clock variation. `[Xs]` marks time since the monitor started, not Game Time. For event precision, supplement recordings with game observations or video capture.

Never treat an address found in a recording as a reusable pointer. An invalid object may be loading or stale. An export or address difference is a clue: its destination and behavior need to be checked.

## Changing the ASL

Edit `ASL/Furi.asl`, the only distribution source. Preserve the checked flows: Speedrun start, game clock, deferred splits, death/Continue, deduplication and optional reset. Describe changes to modes or semantics in the proposal.

For new capabilities:

| Extension | Required work |
| --- | --- |
| Final victory | Check results splits in Speedrun for MOTHERSHIP/Furi and BERNARD/Furier, correct time, a single split and exclusion of menus/loading/restarting; enabled Practice has its own victory split |
| Another build | Hashes, offsets/routes and types checked after restarting, regressions and a live test; keep the compatibility guard |
| DLC/character/route | IDs and actual order, skipped or repeated arenas, clock continuity and suitable deduplication |
| Story or expanded Practice | Optional Practice already starts in a new ready arena and splits on victory; new restarts/routes or Story require START, reset, split boundaries and Game Time definitions without interfering with Speedrun |
| Another platform | Identify runtime, architecture and memory access; do not assume Windows routes apply |

Add regression cases reproducing the issue and relevant false positives. The current harness is `tests/ReproducirRegistro.cs`; it uses the real LiveSplit component with recorded/synthetic samples and an isolated timer. Its `init` needs a compatible Furi process open. Replay validates logic; new memory routes need live tests.

Run compilation and replay as described in [DEVELOPMENT.en.md](docs/DEVELOPMENT.en.md). Note which checks passed, the installation used and any checks you could not run. Documentation-only changes can be checked for consistency and links.

## Delivering a contribution

Describe the problem, resulting behavior, evidence, checks and remaining coverage. The pull request template helps capture that context. For behavior changes, update both language versions of `docs/CONTEXT.md`; for a release, update the version, public documents and both changelogs, then generate the ZIP with `tools/Empaquetar.ps1`.

Preserve the distinction between “reported by the player,” “observed in a recording,” “synthetic case” and “hypothesis.” Document new data without turning it into guarantees broader than the test.

Publish only source, documentation and relevant original recordings. DLLs, game IL dumps, saves, personal layouts and private research stay in `local/`. Generated packages go in `dist/` and can be attached separately to a release.
