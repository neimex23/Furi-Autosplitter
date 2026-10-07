# Context for agents and contributors

[Español](AGENTS.md) | English

This repository contains a LiveSplit autosplitter for Furi. Before changing behavior, read:

1. `docs/CONTEXT.en.md`: decisions, current state, evidence, limitations and next steps.
2. `docs/DEVELOPMENT.en.md`: tools and verification commands.
3. `CONTRIBUTING.en.md`: how to investigate, extend and document a contribution.

The reference implementation is `ASL/Furi.asl`. The current version is `1.0.0`. README and LEEME contain player instructions; development context is maintained in the Spanish/English versions of `docs/CONTEXT.md`.

## Agreed behavior

- Current scope: Extras > Speedrun and optional Practice, Furi and Furier difficulties.
- Game Time comes from the game's cumulative clock (`Statistics._time`).
- `hitCounter` and `koCounter` are independent, off-by-default options. They synchronize Statistics._hits/_KO with Counters labeled Furi Hits/Hits and Furi KO/KO, case insensitive. A single default Counter is accepted if only one metric is enabled. They keep maxima through gaps/stale readings and clear on Start/Reset/new session. They do not depend on split checkboxes. Unrelated counters are not modified.
- `phaseSplits` is optional, off by default, for Speedrun and enabled Practice. It respects boss checkboxes; intermediate phases use counter advancement and the last phase uses the existing victory split. The route and advancement were observed in LAW/Furi in both modes and after restarting. The player reported working phase splits and no split on death without specifying the combination; other bosses/Furier and broader live coverage remain pending.
- By default, victory stays pending on results and splits using `Chrono._initialTime` when the next arena is ready. `splitOnResults` allows splitting on results with valid cumulative Statistics.
- At the user's request, the final boss splits on victory results: MOTHERSHIP in either difficulty, BERNARD in Furier (2), using Statistics._time. Identification was checked through game inspection; a live final-Speedrun test remains pending.
- Story produces no automatic actions. Practice is off by default; when enabled, it starts in a ready arena in a new session and splits on the selected boss's victory results. Auto reset remains Speedrun-only, optional and off by default.
- Keep the general split option and individual boss checkboxes, all on by default. Skipping a boss consumes its event without changing cumulative time or skipping layout rows.
- The Star always splits on results regardless of the timing option. ASL labels, tooltips and messages stay in English by the user's choice; documentation is available in Spanish and English. Preserve existing setting keys.
- Preserve these agreements by default. When extending scope, explicitly describe the new behavior and its evidence.

## Working criteria

- Keep hash validation. A new build requires verified routes and tests; removing the guard does not prove compatibility.
- Do not turn heap addresses from a recording into permanent pointers. Do not interpret invalid readings, loading or process exit as victory.
- Distinguish live tests, recordings, synthetic cases and hypotheses. Do not claim a complete run or subsecond precision from the evidence available so far.
- The MOTHERSHIP Practice test used built-in invincibility and phase skipping. It is diagnostic; it does not validate Speedrun completion.
- If ASL logic changes, compile and run relevant checks from `docs/DEVELOPMENT.en.md`; state any checks that could not be performed. Documentation-only changes require consistency and link checks.
- Update both language versions of `docs/CONTEXT.md` with new decisions, evidence and next steps. For a distributable release, synchronize ASL version, public documents and changelogs.
- Keep `ASL/Furi.asl` as the single distribution source. Generate ZIPs with `tools/Empaquetar.ps1`.
- Keep private recordings, IL dumps, DLLs and personal layouts out of public files. `local/` and `dist/` are excluded from Git.

The local directory may contain `local/research/INVESTIGACION.md`, a chronological history with superseded hypotheses and descriptions. It may not exist in another clone. Public context must be sufficient to continue the project; do not treat an old sentence from that history as the current state.
