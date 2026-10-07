[Español](CHANGELOG.es.md) | English

# 1.0.0 — 2026-10-07

- Release prepared from beta.8, with Neimex23's signature and project URL inside the ASL.
- Keeps Speedrun/Furi/Furier, optional Practice, boss selection, results/next-arena timing, optional phases, hits/KO counters and optional Speedrun reset. No timing or memory logic changes.
- Synchronizes release metadata and instructions, adds a LiveSplit registration/update guide and includes LICENSE in the generated ZIP.
- Complete public documentation in Spanish and English, with language links and bilingual templates. The ASL interface stays in English by the user's choice.
- Existing coverage limits remain: complete runs, live final victory timing, live Counter binding and additional boss/build combinations still need verification. Version 1.0.0 does not certify those pending cases.

# 0.1.0-beta.8 — 2026-10-07

- Added optional **Track KO in Counter (Furi KO)**, independent of hits and splits, using the game's cumulative Statistics KO total.
- Counter binding accepts Furi Hits/Hits and Furi KO/KO without case sensitivity, including trailing colons. A single default Counter can be linked when only one metric is enabled. Two metrics require named counters.
- Missing and ambiguous bindings return failure and log their status. Unrelated counters remain untouched.
- Player reported beta.7 hits did not update in the live layout; the failure's exact cause is not yet confirmed. Beta.7 required an exact label and silently ignored missing matches. Broader binding and KO still need live layout verification.

# 0.1.0-beta.7 — 2026-10-07

- Optional **Track received hits in Counter (Furi Hits)**, off by default. Syncs the game's cumulative received-hit statistic to one LiveSplit Counter with the exact label Furi Hits, independently of boss/phase split filters.
- Keeps the accepted total during invalid or stale samples; resets to zero on Start/Reset or a new accepted game session. Missing or ambiguous counters are left untouched.
- Uses Counter's SetCount API, without simulated hotkeys. Manual changes to the linked counter are replaced while enabled; other counters are untouched.
- Recorded LAW → NEMESIS in Speedrun/Furi preserved 24 hits, including a prior death. Phase splitting and no split on death were also confirmed by the player. Counter integration in a live layout and other modes/difficulties remain pending.

# 0.1.0-beta.6 — 2026-10-07

- Added optional **Phase splits (Speedrun and Practice)**, off by default, respecting the general and individual boss checkboxes.
- Intermediate phases split on a directly observed counter advance with the cumulative game clock. The last phase uses the existing boss victory split and timing, without an extra split.
- Phase regression, repeated phases, invalid samples and multi-phase jumps do not create reconstructed or duplicate splits. Practice still requires its own option and a fresh session for each timed attempt.
- Memory route and phase advancement recorded for The Chain in Furi difficulty, in Practice and Speedrun, with the same route after restarting Furi. At this revision, LiveSplit phase behavior, other bosses and Furier still needed live verification.

# 0.1.0-beta.5 — 2026-10-07

- Autosplitter options, tooltips, compatibility status and visible messages translated to English; existing setting keys preserved.
- Practice option labeled **Practice Mode (split on boss defeat)** to clarify that it splits on boss victory in the game's Practice mode; behavior unchanged.
- Added **Split on victory results (unchecked: next arena ready)**. Off by default, preserving inherited-time splits after loading the next arena.
- The Star always splits on victory results; final Bernard in Furier and Practice also keep their results split.
- Both timings respect boss selection and prevent duplicate splits. Results timing uses the accepted cumulative game clock.
- DLC reported working by the player: Bernard and The Flame. Practice, boss exclusion and clock also reported working; full route/timing coverage remains partial.

# 0.1.0-beta.4 — 2026-10-07

- Optional automatic Practice, off by default: starts in a ready arena in a new session and splits on the selected boss's victory results.
- Uses the same boss checkboxes and the session's Statistics time; Story remains excluded and auto reset remains Speedrun-only.
- Clears events on mode changes, even if the session retains the same pointer.
- Synthetic cases for both difficulties, loading, clock/pause, death/phases/invalid time, deduplication and checkboxes. At this revision, live normal/Onnamusha Practice still needed testing.
- Repeating Practice requires a manual LiveSplit reset and a new selection from the menu; same-session restarts remain pending.

# 0.1.0-beta.3 — 2026-10-07

- Individual boss checkboxes below the existing general option. All are on by default; the general option disables all boss splits.
- An unchecked boss skips its split, preserves the current total and clears its pending victory; it does not modify LiveSplit segment rows.
- Names corroborated against game localization. Correction: HORN is The Beat; BERNARD is Bernard. The beta.2 final condition is unchanged.
- Synthetic regressions for all 12 boxes, general-option priority, clock and skipped-event cleanup.
- User report: start, clock and intermediate splits with Onnamusha in Furi and Furier. Final completion still needs a live test.

# 0.1.0-beta.2 — 2026-10-07

- At the user's request, final victory splits on results: Star (MOTHERSHIP) in Furi and Bernard (BERNARD) in Furier, based on identification inspected in the game. Original documentation called BERNARD “Beat”; that label was corrected in beta.3.
- Uses valid cumulative Statistics._time; intermediate bosses keep inherited-time splits when the next arena loads.
- Preserves hashes, Story/Practice exclusion, prior observation of the active boss and duplicate prevention.
- Synthetic regressions for final victory, wrong difficulty, death/phases, invalid data, focus loss, duplicates and disabled splits. Final completion in a real Speedrun remains untested.

# 0.1.0-beta.1 — 2026-10-06

First packaged beta for sharing and community testing.

- Speedrun start and Game Time read from game memory, without Cheat Engine.
- Pending-victory split when the next arena is ready.
- Split time taken from the total inherited by the new boss's Chrono.
- Optional auto reset, off by default.
- Story and Practice excluded; pending victory cleared when leaving Speedrun.
- SHA-256 validation of the investigated build and visible compatibility status.
- Speculative `gameState == 17` condition removed: final split manual.
- Spanish/English instructions and report template without local paths or game files.

See [LEEME.md](LEEME.md) / [README.md](README.md) for completed tests and remaining coverage.
