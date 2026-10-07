# Cheat Engine diagnostics

[Español](README.md) | English

Optional Lua research tools for Cheat Engine with Mono. They are not needed to use the ASL. They read game memory; some perform scans and may take time. Route offsets apply to the supported build documented in the project.

With Cheat Engine attached to `Furi.exe`, open its Lua window and load the chosen file with `dofile([[full path to file.lua]])`, using this repository's location.

To continue researching the current routes:

1. With an arena loaded, run `ValidarRutaPartida.lua` to check the domain, classes and fields.
2. Run `RegistrarRutas.lua` to log changes in mode, session, GM and Game Time. It can also start from the menu; an invalid GM during menus/loading does not prove that the route is broken.
3. Run `LeerEstadisticas.lua` for a single reading of cumulative time.

To investigate phase splits, run `RegistrarFases.lua` **with an arena loaded**. It searches for `PawnManager` references through static fields of its class/base class and a bounded Mono domain region (the first `0x40000` bytes), requiring a single object of that class. It validates the tables of `arenaAIPawn` and its `AIPawnController`, then logs `_currentPhaseNumber`, phase count, mode, difficulty, boss, GM and time. It does not write memory or control LiveSplit. It requires `local/research/Registros/` to exist and saves `fases-<date>-<time>.txt` there, including candidate details even if the search fails. It polls every 50 ms and writes changes in phases, objects or states, without recording every clock variation.

Capture a normally completed phase, death/retry, fight restart and final victory in Speedrun and Practice. Repeat resolution after restarting Furi. The recording shows singleton location and field offsets for investigating a reusable route; session object addresses are not distribution pointers. LAW/Furi already has recordings; other combinations remain to be checked. The monitor does not enable the ASL's separate phase-split option.

Revision V3 accepts controllers derived from `AIPawnController` and configurations derived from `BossFightPhases`, checking the hierarchy through Mono and recording the concrete class. V2 could resolve PawnManager and display a controller while leaving `phase=nil` because it rejected the derived class.

`RegistrarImpactos.lua` investigates the game's hit counter and its integration with LiveSplit Counter. Run with a session loaded. It resolves Statistics `_hits`, `_KO` and `_time` through Mono, validates classes and logs changes every 50 ms to `local/research/Registros/impactos-<date>-<time>.txt`, along with the inherited total at the boss's start (`startHits`) when available. Capture received hits, parries, death/Continue and the transition to the next boss. It changes neither memory nor LiveSplit. The ASL already includes optional Counter integration; live verification of the player's layout binding remains pending.

Stop any monitor before changing the attached process:

```lua
if furiMonitor then furiMonitor.destroy(); furiMonitor=nil end
```

Other files preserve earlier investigation stages. `ResolverSesion.lua` saves session candidates; `RegistrarInicio.lua`, `LeerDificultad.lua` and `BuscarReferencias.lua` depend on those candidates. Comparison/anchor tools depend on the references obtained. Some historical tests contain session-specific addresses and require adaptation: do not reuse them after restarting Furi.

Save new recordings in `local/`, which Git ignores. Do not distribute these scripts in the player package.
