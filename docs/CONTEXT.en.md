# Project context and continuation point

[Español](CONTEXT.md) | English

Updated: **2026-10-07**, version **1.0.0**. This document summarizes the current state so work can continue without the original conversation or private notes. The executable source is [ASL/Furi.asl](../ASL/Furi.asl). Commands are in [DEVELOPMENT.en.md](DEVELOPMENT.en.md).

## Goal and agreements

The project began with memory research in Cheat Engine and became an ASL that LiveSplit can use without Cheat Engine. The initial scope is **Extras > Speedrun**, Furi and Furier, with one segment per boss in the player's chosen route.

The user chose the game's cumulative clock as **Game Time** and splitting when the next arena loads. An early revision split on results and counted real time; that behavior was replaced. By default, for intermediate bosses the current ASL saves victory on results, waits for the next arena and splits using the total inherited from the previous boss. Since beta.5, splitting on results can be selected instead.

The current version supports automatic start and optional reset of an active attempt. At the user's request, since beta.2 the final boss splits on victory results: Star in Furi, Bernard in Furier. Other bosses keep next-arena splitting by default. Coverage remains partial; a complete run has not yet been validated.

## Preparing 1.0.0

On 2026-10-07 the user requested version 1.0 with their signature and an explanation of LiveSplit registration and updates. They then updated the repository to beta.8, which is the basis for 1.0.0. `Author: Neimex23` and the project link were added to the header, and version, messages and documentation were synchronized. Routes, hashes, logic, setting keys and defaults are unchanged from beta.8.

Verification of 1.0.0: compilation with the installed LiveSplit 1.8.37 component and full replay with real `init` and compatible hashes from Furi PID 10676. Reading the process required leaving the sandbox after an access error. The Chain → Strap recording and synthetic cases passed for Speedrun, Practice, all 12 checkboxes, results/next-arena timing, Furi/Furier endings, phases, Hits/KO with real Counter in an isolated layout, and prevention of writes with an unsupported build. Neither the game nor the open timer was modified. No new run or real-layout test took place: live final completion, the player's Counter bindings and other documented combinations remain pending.

Distribution is generated with `tools/Empaquetar.ps1` and now includes LICENSE. [PUBLISHING.en.md](PUBLISHING.en.md) describes publication and updates; [livesplit-registration.xml](livesplit-registration.xml) proposes the Furi entry with a stable URL to `main/ASL/Furi.asl`. No exact Furi entry was found in the official catalog lookup. This preparation is local: no release, tag or registration PR was created. Version 1.0.0 does not turn pending cases into completed tests.

The user then requested Spanish/English documentation and explicitly chose to keep the ASL in English. Public guides have linked language versions; report/PR templates are bilingual. Identifiers, commands, filenames and original recordings remain unchanged. The original LICENSE text is preserved. Future documentation updates must keep both languages consistent. This documentation pass does not change ASL behavior or add live evidence.

Translation verification: local links and complete code fences, matching sections in each translated pair, and matching offsets, dates, process IDs and decimal values in the ES/EN context. The report matches the issue template. The ZIP was regenerated with both changelogs; contents, manifest hashes, internal links and distributed ASL identity were checked. Compilation and logic regressions were not rerun: the ASL retains the already validated revision.

## Checked behavior

The user supplied a LiveSplit.AutoSplitters CI log: 507 tests passed and one failed because the description exceeded 120 characters. The registration snippet description was shortened and the limit documented in both publishing guides. Local verification checks XML and length; the external suite was not run here and the catalog PR was not updated. The ASL is unchanged. Next step: apply the corrected snippet to the PR and rerun its CI.

| Flow | Available evidence | Limit of the check |
| --- | --- | --- |
| Speedrun START in Furi | User tested start in LiveSplit; replay from menu | START timing was not measured with subsecond precision |
| Clock, pause and focus loss | User compared HUD/LiveSplit and memory recordings | HUD rounds to seconds; visual agreement does not establish subsecond precision |
| Chain → Strap results | User confirmed a stopped clock, no split on results, one split on Strap loading and time continuity | The public revision later adjusted the exact split boundary to `Chrono._initialTime`; that adjustment passed replay but awaits live comparison |
| Death and CONTINUE on Strap | User confirmed the segment stayed active and the clocks looked correct | Does not cover every boss or death variation |
| Restarting Speedrun from pause and starting a new Speedrun from menu | User confirmed both paths with optional reset enabled | Tested during an active attempt; after finishing, reset manually |
| Furier | User confirmed start, restart, clock and pause | Recorded Furier victory/transition remains pending |
| Onnamusha in Furi and Furier | On 2026-10-07 the user reported testing both difficulties with Onnamusha and that it worked well, after beta.2 was delivered | Confirmed start, clock and intermediate splits; did not test the final split. No recording or timing comparison supplied |
| DLC: Bernard and The Flame | On 2026-10-07 the user confirmed both worked well and asked to mark DLC as working | Player-reported live evidence; mode, difficulty and specific events/times were not specified. Does not prove Speedrun completion or every combination |
| Disabled Practice exclusion and pending-victory cleanup | Synthetic case using the installed ASL component | Live Practice diagnostics were not a complete test of LiveSplit events |
| Automatic Practice enabled | Synthetic cases in difficulties 1/2; user confirmed live that Practice works, unchecking a boss prevents splitting and the clock works correctly | Boss, difficulty, character, modifications and times were not specified; other combinations and same-session restarts remain pending |
| MOTHERSHIP in Practice | Results recording with `ended=1`, substate 7 and stopped clock | Used built-in invincibility and phase skipping; does not validate normal victory or Speedrun completion |
| Compilation and regressions | Installed ASL parser and ASL method execution with an isolated timer | Do not replace UI tests, memory-route validation or a complete run |
| Automatic final split | Final-boss identification through EndLevelSpeedrun inspection; synthetic regressions for both difficulties | Live final-Speedrun victory and timing comparison remain pending |

**Important correction:** a recording intended to verify Furier began with difficulty 2 data, but the new session and recorded victory had difficulty 1. That transition counts as Furi. Always record the difficulty of the session in which victory occurred.

## Compatibility and routes

Investigated installation: **Furi on Steam for Windows**, process `Furi.exe`, 64-bit Mono runtime, LiveSplit **1.8.37**. Accepted hashes are in [README.md](../README.md), [LEEME.md](../LEEME.md) and ASL `init`. Other builds show `UNSUPPORTED BUILD` and their actions are disabled.

The domain root was obtained by inspecting `mono_get_root_domain`: the export read a global pointer using RIP-relative addressing. The destination corresponds to RVA `0x49AC78` in the investigated module. GM and Global references were checked after process restarts; a numerical difference between addresses alone was not sufficient evidence.

In the following table, `P(address)` means reading a 64-bit pointer; offsets are hexadecimal.

| Object / field | Route or offset | Type used |
| --- | --- | --- |
| Mono domain | `P(mono-2.0-bdwgc.dll + 0x49AC78)` | Pointer |
| GameManager (GM) | `P(domain + 0x1ED08)` | Pointer |
| GlobalGameManager | `P(domain + 0x1EF48)` | Pointer |
| Global mode | Global `+0xB8` | int |
| GameDataInfo / session | `P(Global + 0x40)` | Pointer |
| Level | `P(session + 0x10)`; string length `+0x10`, UTF-16 `+0x14` | int + bytes |
| Difficulty and session mode | session `+0x40` and `+0x44` | int |
| Statistics | `P(session + 0x28)` | Pointer |
| Statistics._time | Statistics `+0x20` | float, cumulative seconds |
| Chrono | `P(GM + 0x38)` | Pointer |
| GM state | GM `+0x64` | int |
| Substate before pause / focus loss | GM `+0x68` / `+0x6C` | int |
| GM substate | GM `+0x70` | int |
| endGameTriggered | GM `+0x7B` | boolean byte |
| Chrono._initialTime | Chrono `+0x54` | float, inherited total |

The ASL saves and compares type tables from the first accepted samples and filters ranges/values. It does not query class names through Mono on every sample. Validation Lua scripts do check classes and fields through the Mono collector. Offsets are not a universal game contract.

Heap objects change between processes and arenas. Original scans returned multiple candidates, some stale or inactive. Loading an arena may leave GM invalid for a while. Use routes from the module, validate types and observe behavior; do not automatically choose the first candidate.

## Useful identifiers and states

| Value | Investigated meaning |
| --- | --- |
| GameMode 0 / 1 / 2 / 3 / 4 | None / Story / NewGamePlus / Practice / Speedrun |
| Difficulty 1 / 2 | Furi / Furiosa (Furier) |
| Level LAW / NEMESIS / MOTHERSHIP / HORN / BERNARD | Chain / Strap / Star / Beat / Bernard |
| GameState 4 | Arena |
| GameSubState 0 / 1 / 2 / 3 | Normal / InGameSequence / WaitingFightEnd / GameOver |
| GameSubState 4 / 5 / 6 | Paused / Loading / RankingView |
| GameSubState 7 / 8 / 9 | EndScreen / NotFocused / Transition |

When `subState == 8`, the ASL uses `preUnfocused` as the effective substate. A recording taken after switching to Cheat Engine often shows focus loss, not the state visible while playing. A pause may be underneath that state.

These IDs help interpret recordings; checkboxes identify 12 bosses but do not describe every possible route. Deduplication uses the level name within the attempt. A mode that returns to the same arena ID would require revisiting that decision.

## Per-boss options in beta.3

The user requested a checkbox per boss while retaining the general `bossSplits` option. Its key and default are preserved to keep existing layouts. Child checkboxes default to on: Chain/LAW, Strap/NEMESIS, Line/WISE, Scale/SCALE, Hand/FATHER, Song/WING, Burst/MAZE, Edge/CHALLENGER, Beat/HORN, Star/MOTHERSHIP, Flame/AVENGER and Bernard/BERNARD. Keys are `boss_<ID>`.

Names were checked against `<ID>_TITLE` localization entries in the compatible installation and identifiers from `GlobalGameManager.GetBossNameFromLevel`. Documentation correction: beta.2 called BERNARD Beat; localization distinguishes HORN (“The Beat”) and BERNARD (“Bernard”). That label was corrected without changing the final-victory condition inspected in beta.2. Adding Flame/Bernard checkboxes does not validate their live routes or expand accepted modes. Extracted data remains private in `local/`.

The general option overrides its children. The completed boss is filtered, not the new arena. A skipped event is consumed and its pending state cleared without splitting or returning inherited time as though a split occurred. The clock continues with the current cumulative total. IDs without a checkbox retain the general option's behavior. Players configure checkboxes before an attempt and adjust segments to their selected bosses; the script does not remove or skip LiveSplit rows. Skipping the final boss also skips automatic completion.

Beta.3 verification: compilation with the installed LiveSplit 1.8.37 parser and normal replay with Furi open, real `init` and compatible hashes. Process reading required running outside the sandbox after an access error; neither the game nor the open timer was modified. The Chain → Strap recording and prior regressions passed, along with all 12 checkboxes (defaults, skipping, clock continuity, pending-event consumption and the next enabled session), general-option priority and synthetic final victories. Events run with an isolated timer and recorded/synthetic samples; this is not equivalent to checking the boxes in the UI or completing a live run.

## Optional Practice in beta.4

The user requested extending boss checkboxes to Practice and chose automatic start and split. `practiceMode` was added, off by default. When enabled, matching global/session mode 3 and difficulties 1/2 are accepted, with the same validated hashes, tables and routes. Story remains excluded.

Inspection evidence: `GlobalGameManager.StartPractice` creates a new GameDataInfo and sets mode 3, level, difficulty and Onnamusha. `GameManager` opens EndScreenPractice when finishing in mode 3; `EndScreenPractice.OnEnable` sets substate 7. The MOTHERSHIP/Practice diagnostic recording already contains `ended=1`, EndScreen and a stopped clock; it used invincibility and phase skipping, so it does not validate normal victory or LiveSplit events. Dumps remain in `local/`.

START requires a new session observed after establishing a baseline, followed by Arena/Normal, `ended=0`, Chrono and valid Statistics. Attaching during a fight or results does not start automatically. Victory requires the same boss/GM previously observed active and EndScreen/`ended=1`; any checked boss splits immediately using that session's cumulative total without waiting for another arena. Individual and general checkboxes are shared with Speedrun. Changing modes clears intents and victories even if the session pointer matches; each mode establishes its own cumulative total.

Existing auto reset remains Speedrun-only. To repeat Practice, reset LiveSplit manually and select a new Practice session from the menu. Internal restarts reusing GameDataInfo are not automatically recognized and need investigation. A lower clock reading does not reconstruct a new attempt. Use one segment per fight and configure options before the attempt.

Beta.4 verification: compilation with the installed LiveSplit 1.8.37 component and normal replay with real `init` against an open compatible Furi process (reading outside the sandbox). The Chain → Strap recording, prior cases and synthetic Practice in both difficulties passed: one START after loading, clock/pause/gaps, exclusion of death/phases/NaN, focus loss, a single victory, disabled checkbox, attaching without START, mode change with the same pointer without inheriting victory, and no Speedrun auto reset in Practice. No live Practice victory was performed with this revision.

After beta.4 was delivered, on 2026-10-07 the user reported that Practice worked, unchecking the boss prevented its split, and the clock worked correctly. This is recorded as player-reported live evidence for Practice, boss filtering and the clock. No boss, difficulty, character, modifications, recording or time values were supplied; it does not establish every combination or subsecond accuracy. Final Speedrun completion and internal Practice restarts remain pending.

## Language and split timing in beta.5

The user requested translating the autosplitter to English and choosing between results and the next arena while keeping The Star on results. Labels, tooltips, compatibility status (`UNSUPPORTED BUILD`) and visible messages were translated; keys were retained to preserve saved layouts. Spanish instructions stayed in LEEME and development context was in Spanish at that stage. Version 1.0.0 adds English versions of the public guides while keeping the ASL in English.

At a later user request, the `practiceMode` label was renamed to **Practice Mode (split on boss defeat)**. Its label and tooltip clarify that it splits on boss victory results in the game's Practice mode. Only visible text changed; key, automatic start, behavior and off-by-default setting remain the same.

`splitOnResults` was added, off by default: checked, it splits each Speedrun victory on EndScreen with valid Statistics and the accepted total; unchecked, it keeps splitting when the next arena is ready using Chrono._initialTime. Clock tracking is unchanged. The Star/MOTHERSHIP always uses results in either difficulty; final Bernard in Furier keeps results timing, and Practice always splits on victory. Individual and general checkboxes filter both timings. Skipped events and victories already split do not produce another split on loading. Configure before the attempt.

The user confirmed Bernard and The Flame and considers the DLC working. This is recorded as reported functionality alongside the earlier Onnamusha report; mode/difficulty details and timing comparison are missing. This evidence does not become a validated complete run.

Beta.5 verification: compilation with LiveSplit 1.8.37 and normal replay with Furi open, real init and compatible hashes. Prior Speedrun, Practice and all 12 checkbox cases passed; new results cases in difficulties 1/2 verify one immediate split at 217.30, continuation to 217.90 after loading without duplication, exclusion of death/phases/NaN and disabled checkboxes. Tests also verify that The Star splits on results with the option unchecked in both difficulties. The new timing choice still needs a live test; these are synthetic/recorded cases with an isolated timer.

## How events are generated

1. **Initialize:** check hashes and clear tracking, table caches, time and pending events.
2. **Establish an initial baseline:** observe a clean menu (`mode=0`, no session) or save the first session seen. Attaching to an already loaded session does not generate START.
3. **Recognize a new attempt:** the GameDataInfo pointer or accepted mode changes. Previous tracking is cleared. In Speedrun, LAW prepares START; during a run, reset can be prepared if both the experimental option and LiveSplit Reset are enabled. In enabled Practice, START is prepared for any boss and waits for the arena to be ready.
4. **Read Game Time:** accept Statistics with a consistent table and finite, nonnegative time. Keep the maximum within the session against stale readings. Gaps retain the last value; a new session clears the total.
5. **Prepare victory:** observe GM/level with `ended=0` in Normal or InGameSequence, then the same GM/level with `ended=1` and effective EndScreen. A phase change, death or final screen from an object not previously observed active is insufficient.
6. **Choose the boundary:** in enabled Practice, with `splitOnResults` checked, or for MOTHERSHIP or BERNARD/difficulty 2 in Speedrun, prepare a split on that victory with valid Statistics in the sample and the accepted total. For other Speedrun bosses with the option unchecked, wait for level and GM different from the pending victory, Arena/Normal, `ended=0`, available Chrono, valid Statistics and finite `Chrono._initialTime` between zero and the accepted cumulative time.
7. **Split once:** `gameTime` returns the inherited total or cumulative victory time on the split frame; `split` records the level in `completed` and clears the pending victory. Subsequent readings return to the current total. Requires Split and boss splitting enabled; LiveSplit finishes when this is its last configured segment.

Changing modes or entering an excluded mode clears the pending victory. `onStart` and `onReset` clear segment tracking; Speedrun auto reset preserves START intent. The script does not create or reorder LiveSplit segments.

### Why the clock works this way

Local inspection showed `ScoreManager.Update` copying `GameManager.GameTime` to `Statistics._time`. Reading that field avoids reconstructing the native Unity clock. A paused time of **217.30 s** was compared against the Chrono formula.

`isLoading` always returns `true` to stop LiveSplit's internal extrapolation while the ASL supplies explicit times. It does not mean the game is permanently loading or describe a generic load-removal algorithm.

Statistics may lag by one frame or include the new arena's first frames. Next-arena mode uses `Chrono._initialTime` as the segment boundary. In a V2 recording, Chain's final time and Strap's initial time were **211.236328125 s**, while Statistics in Strap's first ready sample was **211.23889160156 s**. Tests also cover an inherited total of 217.30 against Statistics at 217.90.

### A transition that must not break

`level=NEMESIS` was observed while Chain's GM was still present with `ended=1`. This was followed by gaps, a new GM in Loading, and finally Normal with Chrono. Changing level alone can therefore split too early, and combining a new level with the old signal can assign victory to the wrong boss.

## Final victory: beta.2 decision and limitations

On 2026-10-07 the user requested splitting when winning against the final boss, without waiting for the next menu. They shared a screenshot of “CONGRATS! SPEEDRUN COMPLETED!” with Star as the tenth boss: visual evidence of the summary, without a memory recording or ASL event validation.

Local inspection of `EndLevelSpeedrun.Open` explicitly identifies MOTHERSHIP with difficulty 1 and BERNARD with difficulty 2 for `UI_SPEEDRUN_FINAL`. This supports difficulty-based selection for the compatible build; Star is not treated as the universal final boss. Dumps remain private in `local/`.

The new logic uses the existing victory signal: the same GM/level previously observed active, Arena, `ended=1` and effective EndScreen (including beneath focus loss). It requires valid Statistics in the sample and returns the accepted cumulative total, without using the final boss's Chrono._initialTime, which only represents that segment's start. It does not trigger on death, phase, loading, ranking, menus or invalid readings; beta.2 keeps Story/Practice exclusion and deduplication. It does not detect the final summary screen. Possible Statistics lag on reaching results still needs live comparison; subsecond accuracy is not claimed.

Beta.2 verification: `ValidarASL.ps1` passed with the installed LiveSplit 1.8.37 component. Normal replay could not be completed: Furi did not stay open after attempts to launch it directly and through Steam. The same harness was run with a private temporary ASL copy replacing only module discovery/hash checking in `init`; installed binary hashes were checked separately. Remaining initialization and logic blocks were those of beta.2. The Chain → Strap recording, prior cases and synthetic endings in both difficulties passed (217.30 time, deduplication, NaN, death/phases, focus loss, excluded modes, wrong difficulty, attaching on results and disabled splits). This checks isolated logic; it does not exercise real `init` or routes in a live process. Auxiliary files are in `local/` and are not distributed.

Local Speedrun inspection showed a path with no next level that loads **EndSpeedrunMenu** through `GoToSpeedrunFinalScreen`. The initial hypothesis of using `GameState == 17` (EndGameRanking) was not demonstrated for this path and was withdrawn.

MOTHERSHIP in Practice produced EndScreen/`ended=1`; this confirms a results signal for that test, not Speedrun completion. The clock kept advancing through part of WaitingFightEnd, unlike another Chain sample. The difference was not attributed to the cheat: it may depend on mode, boss or sequence.

To validate this change, capture a final victory in **Speedrun**, including mode, difficulty, level, time, GM and global states before/during/after results and the final summary. Check that the split occurs once and matches the game's total. Also verify Furier and DLC/characters. The modified Practice test does not validate this behavior.

## Phase splits: beta.6

The user requested splits on completing each phase in **Speedrun and Practice**, preserving existing per-boss options. Beta.6 adds `phaseSplits`, off by default, labeled **Phase splits (Speedrun and Practice)**. It respects `bossSplits` and the boss checkbox. Practice also requires `practiceMode`. Use one segment per phase. The last phase is counted through the existing victory split with its configured timing; it does not create two splits for the same ending.

The user recorded LAW/Furi in Practice, PID 25040: counter 0 → 1 and count=4, plus a regression 1 → 0 whose cause was not confirmed. After restarting, PID 10676, they recorded LAW/Furi in Speedrun through the same route, counter 0 → 1 in substate 1, ended=0, Statistics=36.383136749268. Checked metadata: PawnManager at `P(domain+0x1EAE8)`, arenaAIPawn +0x48, controller +0x1D8, phase +0x1B8, configuration +0xF0, list +0x18 and list size +0x18. The concrete controller was NPCLawPawnController. Heap addresses from the recording are not used in the ASL.

The implementation requires two valid samples of the same GM/level/controller/configuration with an advance of exactly one phase, a counter within the list size and valid Statistics when splitting. It caches PawnManager/AIPawn tables and fixes controller/configuration tables per fight, allowing different controllers per boss. The first value only establishes a baseline. Invalid readings, loading, pause, death or excluded states break continuity; events are not reconstructed on recovery. It keeps the maximum observed phase to avoid recounting repeated phases after a regression; a new session, mode or fight clears the baseline. Multi-phase jumps are consumed without manufacturing splits. The logic does not automate internal Practice restarts.

The recording validates the route and advancement in LAW/Furi in both modes, not the LiveSplit event or a complete fight. At this stage, the ASL in LiveSplit, other phases/bosses/Furier, the final boss and the reason for the Practice recording's regression still needed checking.

Beta.6 verification: parsing/compilation with LiveSplit 1.8.37 and replay with real init and compatible hashes from Furi PID 10676. All prior regressions and four synthetic Speedrun/Practice × difficulties 1/2 combinations passed: a single advance with Statistics, deduplication, regression, general/per-boss filters, continuous clock, final victory without duplication at the same timing, gaps/NaN without reconstruction, invalid pointers/counters and multi-phase jumps. These cases do not replace a real-fight LiveSplit split test.

Later user feedback confirmed phase splitting and no split on death. This confirms live beta.6 behavior in that test; mode/difficulty/boss and time comparison were not specified. Other combinations and a complete fight/run remain pending.

## Hit counter: beta.7

### Beta.8 revision: flexible binding and KO

The user reported that beta.7 did not add hits to their Counter and requested KO setup. A Windows-control capture confirmed compatible beta.7 and `hitCounter` enabled in Layout Settings; the helper's inputs could not open the Counter tab, so the counter's current text and exact cause remain unconfirmed. Its options were not changed. Beta.7 required exact `Furi Hits` and returned success even without a match, hiding a missing binding.

Beta.8 uses a shared resolver: it accepts `Furi Hits`/`Hits` and `Furi KO`/`KO`, ignoring case and trailing colons. If there is one Counter with default `Counter` or empty text and only one enabled metric, it binds to that metric. If both are enabled, it requires separate names. Multiple matching names are ambiguous and are not written; the first counter is not chosen arbitrarily. It returns false and logs not found/ambiguous; a valid binding logs linked when its state changes.

`koCounter` is off by default, labeled **Track KO in Counter (Furi KO)**. It reads Statistics `_KO +0x24`, corroborated by metadata and the death and LAW → NEMESIS recordings (KO=1 preserved). Its maximum, Start/Reset and new-session tracking are independent of hits; it shares mode exclusion and Statistics validation. Disabled counters are neither written nor cleared. Both bindings in the real layout and KO in other combinations remain to be checked.

Beta.8 verification: compilation with LiveSplit 1.8.37 and full regressions with real init/compatible hashes from Furi PID 10676 passed. Real Counter in an isolated layout verified separate Hits=4/KO=1, KO increases and preservation through gaps/regressions, disabled hits untouched, selective KO reset, alias `ko:`, one default Counter bound to one metric, and no writes when both are ambiguous. The Start/Reset guard with supported=false also passed. This is synthetic/API evidence; it does not demonstrate that the player's layout issue is resolved. To test, apply Layout Settings and Layout Editor with OK and start a new session.

The user requested connecting hits to LiveSplit's Counter component. The local installation contains `LiveSplit.Counter.dll`; reflection identifies `CounterComponent.Counter`, `ICounter.SetCount(Int32)` and `Settings.CounterText`. Beta.7 adds `hitCounter`, off by default, labeled **Track received hits in Counter (Furi Hits)**. It binds one Counter with exact text `Furi Hits` without changing others. If missing or duplicated, no writes occur. Reflection keeps Counter optional, without distributing an external DLL or simulating hotkeys.

It reads `_hits +0x28` through the same Statistics route/class as the clock. It keeps the session's valid nonnegative maximum, independently of boss/phase filters. It synchronizes during LiveSplit Running/Paused in Speedrun or enabled Practice; excluded modes and invalid samples do not write. Start/Reset zero the linked counter with a compatible build; the next reading may restore the game attempt's total, so another Practice requires a new session. A new session clears the maximum. Manual edits to the linked counter are replaced on synchronization. The option does not turn Counter into an arbitrary event counter; users can keep other Counters for manual use.

Beta.7 verification: ASL compilation with LiveSplit 1.8.37 and full regressions with real init/compatible hashes from PID 10676 passed, including clock, phases and bosses. The new case uses real Counter/CounterComponent from the installed DLL in an isolated layout: SetCount=24, unrelated counter unchanged, ambiguity without writes, disabled option, gaps/negative values/regressions, excluded mode, new Speedrun, Practice and reset=0. An additional focused test of final source confirms manual Start/Reset does not write Counter when supported=false. These are synthetic logic/API tests; the open layout with real hits remains untested.

IL inspection identifies `Statistics._hits`: `OnHit` requires a PlayerPawn target and increments the counter when the hit was not parried; this is not the same as counting only positive effective damage. Use and describe the game's hit criterion instead of inventing a damage counter. `Reset` zeroes hits and KO. At that stage, the offset and accumulation/reset between arenas still needed live validation; the later LAW → NEMESIS recording is described below.

`tools/cheat-engine/RegistrarImpactos.lua` was prepared to resolve fields through metadata, validate classes along existing routes and record hits, KO, startHits, boss, session, mode and states without writing memory or controlling LiveSplit. It automatically saves private recordings. The user supplied the hits, death/resume and next-arena cases described below; parry exclusion came from IL without explicit player confirmation at that time. Give steps in chat and wait for the reply when another test is needed.

The user ran the diagnostic in Speedrun LAW/Furi, PID 10676. Metadata: GameData +0x28 → Statistics, `_hits +0x28`, `_KO +0x24`, `_time +0x20`. A new attempt changed GameData/Statistics and began at hits=0/KO=0. Hit increments up to 15 were recorded; on death (confirmed by the user), KO changed 0 → 1 without changing GameData/Statistics or losing hits=15. Later hits reached 16 with KO=1. The next recording reached LAW EndScreen/ended=1 with hits=24, KO=1, time 277.56164550781; NEMESIS kept the same GameData/Statistics and hits=24 through gaps/loading to arena Normal. This supports sending the cumulative total without adding it again per boss. The Statistics route had already been checked after restarting; the new offset was corroborated by metadata. Pending: real-layout binding and counters in Practice/Furier/other bosses.

IL inspection of the compatible Assembly-CSharp identifies `AIPawnController._currentPhaseNumber`: `MoveToNextPhase` increments the index while phases remain; after the last phase it calls boss death without incrementing the counter. `ResetPhase` sets -1, and `ACheckBossFightPhase.HandleOnGameReset` reinitializes and advances to the first phase. This supports a candidate signal but does not validate its routes or live behavior. The candidate relationship `PawnManager.arenaAIPawn -> AIPawn.aiPawnController -> AIPawnController._currentPhaseNumber` was found.

`tools/cheat-engine/RegistrarFases.lua` was added as a diagnostic resolving singleton references, validating classes and saving phase/state changes to `local/research/Registros/`. Syntax was checked with Lua 5.3 from the local Cheat Engine installation. Windows control did not expose a targetable Cheat Engine window, so the user ran the diagnostics and supplied the recordings described here. The user requested steps in chat and waiting for their reply when another test is needed, without leaving work running while they perform it.

## Next contributions, in a useful order

The following two paragraphs preserve earlier diagnostic stages; later phase evidence is described in the beta.6 section.

The user ran V2 in Practice LAW, difficulty 1, PID 25040. It resolved a PawnManager reference at `domain + 0x1EAE8`; metadata: `arenaAIPawn +0x48`, `aiPawnController +0x1D8`, `_currentPhaseNumber +0x1B8`, `_bfp +0xF0`, `phases +0x18`. The controller was read as a pointer, but `phase/count` remained nil throughout the recording; the user reported winning a phase. Substates 0/1/4/8 with ended=0 were observed; they are not used as phase victory. This session does not validate the counter or the route after restarting. Type inspection confirms derived controllers, including `NPCLawPawnController`. V3 accepts controllers/configurations whose Mono hierarchy contains the expected class, validates their vtable through metadata and records the concrete name; it retains exact validation for singleton search. Lua 5.3 syntax was checked; V3 capture was pending at that stage.

The first live attempt with `RegistrarFases.lua` failed while resolving the singleton: the user's screenshot showed an error on line 63 with no phase readings. It did not distinguish zero candidates from multiple candidates. V2 logs static fields before resolving and also searches for references with the PawnManager table in the domain's first `0x40000` bytes; multiple references to the same object are accepted, multiple distinct objects are rejected. Diagnostics are saved even if resolution fails. Lua 5.3 syntax was checked; the later V2 result is described above. This adjustment does not change the ASL.

1. Compare the public revision live: a Chain → Strap split equal to the inherited total, without early splitting or first frames from the new boss.
2. Record victory and transition in Furier, verifying `difficulty=2` for that attempt.
3. Complete Speedrun in Furi and Furier, observing every transition and the automatic final-victory split.
4. Compare final split time against results/summary and record possible stale Statistics readings.
5. Record DLC/characters and routes that skip or repeat arenas; check level-based deduplication. Onnamusha already has a positive start/clock/intermediate-split report in Furi and Furier; final completion and a documented full run remain pending.
6. Add other builds/platforms or modes through documented routes and behavior, without expanding compatibility based solely on commercial names.
7. Test normal and Onnamusha Practice live; investigate internal restarts before automating them.

## Where to continue

- [CONTRIBUTING.en.md](../CONTRIBUTING.en.md): procedure for changes and new capabilities.
- [DEVELOPMENT.en.md](DEVELOPMENT.en.md): compiling, replaying and packaging.
- [tests/fixtures/README.en.md](../tests/fixtures/README.en.md): provenance and limitations of the public recording.
- [tools/cheat-engine/README.en.md](../tools/cheat-engine/README.en.md): current monitor and earlier diagnostics.
- [REPORTAR-ERROR.md](../REPORTAR-ERROR.md): information for new community tests.

Original history and IL dumps were kept in `local/research/`, excluded from Git. They contain superseded stages, including an old sentence calling the ASL “inactive.” That sentence does not describe the current version. No local file is required to understand or run the public release.

When continuing, update both language versions with the observed case, build/difficulty/mode, tested revision, result and what still cannot be concluded. This lets the next contributor continue from concrete evidence.
