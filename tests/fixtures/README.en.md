# Test recording: Chain → Strap

[Español](README.md) | English

`chain-strap.txt` is a memory recording captured during a research session on **2026-10-06**, in **Extras > Speedrun**, **Furi (1)** difficulty. It was copied from the original recording when organizing the repository.

It includes new attempts, pauses/focus loss, a restart, and Chain's victory followed by Strap loading. In the winning attempt, the session pointer stays stable while the level changes from LAW to NEMESIS. During part of the transition, the previous GM retains the victory signal; gaps then appear, followed by the new GM, Loading and Normal with Chrono.

This output predates monitor V2 and does not contain `Statistics._time` in every sample. The parser in `tests/ReproducirRegistro.cs` reconstructs some time samples from paused Chrono fields or its initial value. Precise split-boundary, invalid-data and continuity checks also use separate synthetic cases. Do not treat every replay timestamp as a direct measurement of the clock during combat.

The `[Xs]` marker measures seconds since starting the monitor, not the game clock. The monitor sampled every 100 ms and wrote state changes. Events between samples may be missing; the recording does not establish subsecond accuracy.

Hexadecimal addresses identify objects from that session. The harness uses them to simulate identity changes, not to read those addresses in the current Furi process. Type tables are simulated in the parser; this recording alone does not validate the current `state` block's memory routes.

With optional reset disabled, replay expects **1 start, 0 resets and 1 split**; with reset enabled, **2 starts, 1 reset and 1 split**. Other synthetic cases are described in the code and [docs/CONTEXT.en.md](../../docs/CONTEXT.en.md).

When adding a recording, document its date, ASL revision, build/hashes, mode, difficulty, source, player intervention and expected events. Keep relevant original data and identify any anonymization or reconstruction. Exclude personal paths, saves and game files.
