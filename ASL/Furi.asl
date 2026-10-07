// Furi Autosplitter 1.0.0 - Windows / LiveSplit / Speedrun and optional Practice.
// Author: Neimex23
// Project: https://github.com/neimex23/Furi-Autosplitter
// Only binaries matching the hashes in init. Cheat Engine is not required.
// The Star always splits on results; final Bernard in Furier also uses results.
// Game Time reads Statistics._time, updated by the game from GameManager.GameTime.
state("Furi")
{
    ulong domain : "mono-2.0-bdwgc.dll", 0x49AC78;
    ulong global : "mono-2.0-bdwgc.dll", 0x49AC78, 0x1EF48;
    ulong globalTable : "mono-2.0-bdwgc.dll", 0x49AC78, 0x1EF48, 0x0;
    int mode : "mono-2.0-bdwgc.dll", 0x49AC78, 0x1EF48, 0xB8;
    ulong data : "mono-2.0-bdwgc.dll", 0x49AC78, 0x1EF48, 0x40;
    ulong dataTable : "mono-2.0-bdwgc.dll", 0x49AC78, 0x1EF48, 0x40, 0x0;
    int dataMode : "mono-2.0-bdwgc.dll", 0x49AC78, 0x1EF48, 0x40, 0x44;
    int difficulty : "mono-2.0-bdwgc.dll", 0x49AC78, 0x1EF48, 0x40, 0x40;
    int levelLength : "mono-2.0-bdwgc.dll", 0x49AC78, 0x1EF48, 0x40, 0x10, 0x10;
    byte64 levelBytes : "mono-2.0-bdwgc.dll", 0x49AC78, 0x1EF48, 0x40, 0x10, 0x14;
    ulong statistics : "mono-2.0-bdwgc.dll", 0x49AC78, 0x1EF48, 0x40, 0x28;
    ulong statisticsTable : "mono-2.0-bdwgc.dll", 0x49AC78, 0x1EF48, 0x40, 0x28, 0x0;
    float inGameSeconds : "mono-2.0-bdwgc.dll", 0x49AC78, 0x1EF48, 0x40, 0x28, 0x20;
    int receivedHits : "mono-2.0-bdwgc.dll", 0x49AC78, 0x1EF48, 0x40, 0x28, 0x28;
    int receivedKO : "mono-2.0-bdwgc.dll", 0x49AC78, 0x1EF48, 0x40, 0x28, 0x24;
    ulong manager : "mono-2.0-bdwgc.dll", 0x49AC78, 0x1ED08;
    ulong managerTable : "mono-2.0-bdwgc.dll", 0x49AC78, 0x1ED08, 0x0;
    int gameState : "mono-2.0-bdwgc.dll", 0x49AC78, 0x1ED08, 0x64;
    int subState : "mono-2.0-bdwgc.dll", 0x49AC78, 0x1ED08, 0x70;
    int preUnfocused : "mono-2.0-bdwgc.dll", 0x49AC78, 0x1ED08, 0x6C;
    byte ended : "mono-2.0-bdwgc.dll", 0x49AC78, 0x1ED08, 0x7B;
    ulong chrono : "mono-2.0-bdwgc.dll", 0x49AC78, 0x1ED08, 0x38;
    float chronoInitial : "mono-2.0-bdwgc.dll", 0x49AC78, 0x1ED08, 0x38, 0x54;
    ulong pawnManager : "mono-2.0-bdwgc.dll", 0x49AC78, 0x1EAE8;
    ulong pawnManagerTable : "mono-2.0-bdwgc.dll", 0x49AC78, 0x1EAE8, 0x0;
    ulong bossPawn : "mono-2.0-bdwgc.dll", 0x49AC78, 0x1EAE8, 0x48;
    ulong bossPawnTable : "mono-2.0-bdwgc.dll", 0x49AC78, 0x1EAE8, 0x48, 0x0;
    ulong bossController : "mono-2.0-bdwgc.dll", 0x49AC78, 0x1EAE8, 0x48, 0x1D8;
    ulong bossControllerTable : "mono-2.0-bdwgc.dll", 0x49AC78, 0x1EAE8, 0x48, 0x1D8, 0x0;
    int bossPhase : "mono-2.0-bdwgc.dll", 0x49AC78, 0x1EAE8, 0x48, 0x1D8, 0x1B8;
    ulong bossPhases : "mono-2.0-bdwgc.dll", 0x49AC78, 0x1EAE8, 0x48, 0x1D8, 0xF0;
    ulong bossPhasesTable : "mono-2.0-bdwgc.dll", 0x49AC78, 0x1EAE8, 0x48, 0x1D8, 0xF0, 0x0;
    ulong bossPhaseList : "mono-2.0-bdwgc.dll", 0x49AC78, 0x1EAE8, 0x48, 0x1D8, 0xF0, 0x18;
    int bossPhaseCount : "mono-2.0-bdwgc.dll", 0x49AC78, 0x1EAE8, 0x48, 0x1D8, 0xF0, 0x18, 0x18;
}

startup
{
    refreshRate = 60;
    settings.Add("bossSplits", true, "Boss splits");
    settings.Add("boss_LAW", true, "The Chain", "bossSplits");
    settings.Add("boss_NEMESIS", true, "The Strap", "bossSplits");
    settings.Add("boss_WISE", true, "The Line", "bossSplits");
    settings.Add("boss_SCALE", true, "The Scale", "bossSplits");
    settings.Add("boss_FATHER", true, "The Hand", "bossSplits");
    settings.Add("boss_WING", true, "The Song", "bossSplits");
    settings.Add("boss_MAZE", true, "The Burst", "bossSplits");
    settings.Add("boss_CHALLENGER", true, "The Edge", "bossSplits");
    settings.Add("boss_HORN", true, "The Beat", "bossSplits");
    settings.Add("boss_MOTHERSHIP", true, "The Star (results only)", "bossSplits");
    settings.Add("boss_AVENGER", true, "The Flame", "bossSplits");
    settings.Add("boss_BERNARD", true, "Bernard", "bossSplits");
    settings.Add("splitOnResults", false, "Split on victory results (unchecked: next arena ready)");
    settings.Add("phaseSplits", false, "Phase splits (Speedrun and Practice)");
    settings.Add("hitCounter", false, "Track received hits in Counter (Furi Hits)");
    settings.Add("koCounter", false, "Track KO in Counter (Furi KO)");
    settings.SetToolTip("hitCounter", "Counter text: Furi Hits or Hits (case insensitive). A single default Counter also works when KO tracking is off. Syncs the game's cumulative received hits in Speedrun or enabled Practice; resets on LiveSplit Start/Reset. Off by default.");
    settings.SetToolTip("koCounter", "Counter text: Furi KO or KO (case insensitive). A single default Counter also works when hit tracking is off. For both metrics, use two named counters. Syncs Statistics KO in Speedrun or enabled Practice; resets on Start/Reset. Off by default.");
    settings.SetToolTip("phaseSplits", "Split on each observed intermediate phase completion. Uses Boss splits and the selected bosses above. The last phase uses the existing boss victory split and timing. Enable before starting; add one segment per phase. Off by default.");
    settings.Add("practiceMode", false, "Practice Mode (split on boss defeat)");
    settings.Add("autoReset", false, "Reset LiveSplit when starting another Speedrun (experimental)");
    settings.SetToolTip("bossSplits", "Enable or disable all boss splits. Uncheck individual bosses below to skip them. The Star always splits on victory results.");
    settings.SetToolTip("boss_MOTHERSHIP", "The Star can only split on victory results, regardless of the timing option. There is no next arena.");
    settings.SetToolTip("splitOnResults", "Speedrun: checked splits on victory results using the game clock; unchecked waits until the next arena is ready and uses its inherited total. The Star, the final Bernard in Furier, and Practice always split on results. Choose before starting an attempt.");
    settings.SetToolTip("autoReset", "Requires Reset enabled. Resets an active attempt when restarting Speedrun or starting a new one from the menu. Off by default.");
    settings.SetToolTip("practiceMode", "In the game's Practice mode, starts when a new practice arena is ready and splits when you defeat the selected boss, on victory results. Uses the boss checkboxes above. Use one segment and reset LiveSplit before the next attempt.");
}

init
{
    vars.supported = false;
    var mono = modules.FirstOrDefault(m => m.ModuleName == "mono-2.0-bdwgc.dll");
    if (mono == null) throw new Exception("Waiting for Mono module");
    var main = modules.First(m => m.ModuleName == "Furi.exe");
    string assembly = System.IO.Path.Combine(System.IO.Path.GetDirectoryName(main.FileName),
        "Furi_Data", "Managed", "Assembly-CSharp.dll");
    using (var sha = System.Security.Cryptography.SHA256.Create())
    {
        string monoHash = BitConverter.ToString(sha.ComputeHash(System.IO.File.ReadAllBytes(mono.FileName))).Replace("-", "");
        string assemblyHash = BitConverter.ToString(sha.ComputeHash(System.IO.File.ReadAllBytes(assembly))).Replace("-", "");
        vars.supported = monoHash == "47B2F85724C9473182DF93BB5EC11ADCEB07633E00899CFF7138F40349542DFF"
            && assemblyHash == "303FAA314E027A44746B8D4400506118F419115F345F163AFAA74DED3FEA8465";
    }
    vars.globalTable = 0UL;
    vars.dataTable = 0UL;
    vars.managerTable = 0UL;
    vars.statisticsTable = 0UL;
    vars.hitCount = 0;
    vars.koCount = 0;
    vars.counterStatuses = new Dictionary<string, string>();
    // API publica del Counter instalado; no depende de teclas ni de una DLL
    // adicional para jugadores que no usan esta opcion.
    vars.setCounter = (Func<string, int, bool>)((metric, value) =>
    {
        if (timer.Layout == null) return false;
        object target = null;
        object defaultCounter = null;
        int totalCounters = 0;
        int matches = 0;
        foreach (var component in timer.Layout.Components)
        {
            if (component == null || component.GetType().FullName != "LiveSplit.UI.Components.CounterComponent") continue;
            var type = component.GetType();
            totalCounters++;
            var counterSettings = type.GetProperty("Settings").GetValue(component, null);
            if (counterSettings == null) continue;
            var label = counterSettings.GetType().GetProperty("CounterText").GetValue(counterSettings, null) as string;
            var counter = type.GetProperty("Counter").GetValue(component, null);
            if (counter == null) continue;
            label = (label ?? "").Trim().TrimEnd(':').Trim();
            if (label == "" || label.Equals("Counter", StringComparison.OrdinalIgnoreCase)) defaultCounter = counter;
            if (label.Equals("Furi " + metric, StringComparison.OrdinalIgnoreCase)
                || label.Equals(metric, StringComparison.OrdinalIgnoreCase))
            { target = counter; matches++; }
        }
        bool onlyMetric = metric == "Hits" ? !settings["koCounter"] : !settings["hitCounter"];
        if (matches == 0 && totalCounters == 1 && onlyMetric) target = defaultCounter;
        string status = matches > 1 ? "ambiguous" : target == null ? "not found" : "linked";
        var statuses = (Dictionary<string, string>)vars.counterStatuses;
        if (!statuses.ContainsKey(metric) || statuses[metric] != status)
        { statuses[metric] = status; print("Furi Counter " + metric + ": " + status); }
        if (matches > 1 || target == null) return false;
        if (target != null)
        {
            var count = target.GetType().GetProperty("Count");
            var setCount = target.GetType().GetMethod("SetCount", new Type[] { typeof(int) });
            if (count != null && setCount != null && (int)count.GetValue(target, null) != value)
                setCount.Invoke(target, new object[] { value });
        }
        return true;
    });
    vars.pawnManagerTable = 0UL;
    vars.bossPawnTable = 0UL;
    vars.phaseManager = 0UL;
    vars.phaseController = 0UL;
    vars.phaseControllerTable = 0UL;
    vars.phaseConfig = 0UL;
    vars.phaseConfigTable = 0UL;
    vars.phaseLevel = "";
    vars.lastBossPhase = -1;
    vars.maxBossPhase = -1;
    vars.phaseSplit = false;
    vars.gameSeconds = 0.0;
    vars.gameTimeValid = false;
    vars.sampleTimeValid = false;
    vars.lastData = 0UL;
    vars.lastDataMode = 0;
    vars.lastMode = 0;
    vars.baselineSeen = false;
    vars.armedManager = 0UL;
    vars.armedLevel = "";
    vars.completed = new HashSet<string>();
    vars.startPending = false;
    vars.practiceStartPending = false;
    vars.newRace = false;
    vars.automaticReset = false;
    vars.splitLevel = "";
    vars.splitSeconds = 0.0;
    vars.selectedSplit = false;
    vars.pendingLevel = "";
    vars.pendingManager = 0UL;
    version = vars.supported ? "1.0.0 - compatible" : "1.0.0 - UNSUPPORTED BUILD";
    print(vars.supported ? "Furi 1.0.0: compatible binaries" : "Furi 1.0.0: different binaries, actions disabled");
}

update
{
    int previousBossPhase = (int)vars.lastBossPhase;
    vars.lastBossPhase = -1;
    vars.phaseSplit = false;
    vars.newRace = false;
    vars.splitLevel = "";
    vars.selectedSplit = false;
    vars.sampleTimeValid = false;
    if (!vars.supported) return false;
    // No trasladar victorias/intenciones de inicio entre modos o a modos excluidos.
    if (current.domain != 0 && current.global != 0 && current.globalTable != 0
        && (vars.globalTable == 0UL || current.globalTable == vars.globalTable)
        && current.mode >= 0 && current.mode <= 4)
    {
        if (current.mode != vars.lastMode
            || (current.mode != 4 && !(settings["practiceMode"] && current.mode == 3)))
        {
            vars.phaseManager = 0UL;
            vars.phaseController = 0UL;
            vars.lastBossPhase = -1;
            vars.maxBossPhase = -1;
            previousBossPhase = -1;
            vars.pendingLevel = "";
            vars.pendingManager = 0UL;
            vars.armedManager = 0UL;
            vars.armedLevel = "";
            vars.startPending = false;
            vars.practiceStartPending = false;
        }
        vars.lastMode = current.mode;
    }
    // Registrar el menu limpio para reconocer el primer START de un proceso.
    if (current.domain != 0 && current.global != 0 && current.globalTable != 0
        && current.mode == 0 && current.data == 0)
    {
        vars.baselineSeen = true;
        vars.lastData = 0UL;
        return false;
    }
    bool practice = settings["practiceMode"] && current.mode == 3 && current.dataMode == 3;
    if (current.domain == 0 || current.global == 0 || current.globalTable == 0
        || current.data == 0 || current.dataTable == 0
        || (!practice && !(current.mode == 4 && current.dataMode == 4))
        || (current.difficulty != 1 && current.difficulty != 2)
        || current.levelLength <= 0 || current.levelLength > 32 || current.levelBytes == null)
    {
        vars.lastBossPhase = -1;
        return false;
    }
    if (vars.globalTable != 0UL && current.globalTable != vars.globalTable) return false;
    if (vars.dataTable != 0UL && current.dataTable != vars.dataTable) return false;
    vars.globalTable = current.globalTable;
    vars.dataTable = current.dataTable;
    string level = System.Text.Encoding.Unicode.GetString((byte[])current.levelBytes, 0, current.levelLength * 2);
    if (level.Any(c => !(c >= 'A' && c <= 'Z') && !(c >= '0' && c <= '9') && c != '_')) return false;
    if (!vars.baselineSeen)
    {
        // Adjuntar durante pelea/resultados no inicia LiveSplit.
        vars.lastData = current.data;
        vars.lastDataMode = current.mode;
        vars.baselineSeen = true;
    }
    else if (current.data != vars.lastData || current.mode != vars.lastDataMode)
    {
        vars.lastData = current.data;
        vars.lastDataMode = current.mode;
        vars.completed.Clear();
        vars.phaseManager = 0UL;
        vars.phaseController = 0UL;
        vars.lastBossPhase = -1;
        vars.maxBossPhase = -1;
        previousBossPhase = -1;
        vars.armedManager = 0UL;
        vars.armedLevel = "";
        vars.pendingLevel = "";
        vars.pendingManager = 0UL;
        vars.gameSeconds = 0.0;
        vars.hitCount = 0;
        vars.koCount = 0;
        vars.gameTimeValid = false;
        vars.newRace = !practice && level == "LAW";
        vars.startPending = vars.newRace && settings.StartEnabled
            && (timer.CurrentPhase == TimerPhase.NotRunning || (settings["autoReset"] && settings.ResetEnabled));
        vars.practiceStartPending = practice && settings.StartEnabled
            && timer.CurrentPhase == TimerPhase.NotRunning;
        print("Furi 1.0.0: new session, level=" + level);
    }
    // Leer el tiempo que el propio juego calcula; mantenerlo durante huecos/cargas.
    if (current.statistics != 0 && current.statisticsTable != 0
        && (vars.statisticsTable == 0UL || current.statisticsTable == vars.statisticsTable)
        && !float.IsNaN(current.inGameSeconds) && !float.IsInfinity(current.inGameSeconds)
        && current.inGameSeconds >= 0 && current.inGameSeconds < TimeSpan.MaxValue.TotalSeconds)
    {
        vars.statisticsTable = current.statisticsTable;
        vars.gameSeconds = Math.Max((double)vars.gameSeconds, (double)current.inGameSeconds);
        vars.gameTimeValid = true;
        vars.sampleTimeValid = true;
    }
    if (settings["hitCounter"] && (timer.CurrentPhase == TimerPhase.Running || timer.CurrentPhase == TimerPhase.Paused)
        && current.statistics != 0 && current.statisticsTable != 0 && current.statisticsTable == vars.statisticsTable
        && current.receivedHits >= 0)
    {
        vars.hitCount = Math.Max((int)vars.hitCount, (int)current.receivedHits);
        ((Func<string, int, bool>)vars.setCounter)("Hits", (int)vars.hitCount);
    }
    if (settings["koCounter"] && (timer.CurrentPhase == TimerPhase.Running || timer.CurrentPhase == TimerPhase.Paused)
        && current.statistics != 0 && current.statisticsTable != 0 && current.statisticsTable == vars.statisticsTable
        && current.receivedKO >= 0)
    {
        vars.koCount = Math.Max((int)vars.koCount, (int)current.receivedKO);
        ((Func<string, int, bool>)vars.setCounter)("KO", (int)vars.koCount);
    }
    if (current.manager == 0 || current.managerTable == 0
        || current.gameState < 0 || current.gameState > 17 || current.subState < 0 || current.subState > 9
        || current.ended > 1) return;
    if (vars.managerTable != 0UL && current.managerTable != vars.managerTable) return;
    vars.managerTable = current.managerTable;
    int sub = current.subState == 8 ? current.preUnfocused : current.subState;
    // Las acciones de victoria requieren una arena valida, nunca un ranking/menu.
    if (current.gameState != 4) return;
    if (practice && vars.practiceStartPending && current.ended == 0 && sub == 0
        && current.chrono != 0 && vars.sampleTimeValid)
        vars.startPending = settings.StartEnabled && timer.CurrentPhase == TimerPhase.NotRunning;
    if (current.ended == 0 && (sub == 0 || sub == 1))
    {
        vars.armedManager = current.manager;
        vars.armedLevel = level;
    }
    // Solo avances observados entre dos muestras validas del mismo combate.
    // Una regresion por muerte/reinicio no vuelve a dividir fases ya emitidas.
    bool phaseValid = settings["phaseSplits"] && current.ended == 0 && (sub == 0 || sub == 1)
        && current.pawnManager != 0 && current.pawnManagerTable != 0
        && (vars.pawnManagerTable == 0UL || current.pawnManagerTable == vars.pawnManagerTable)
        && current.bossPawn != 0 && current.bossPawnTable != 0
        && (vars.bossPawnTable == 0UL || current.bossPawnTable == vars.bossPawnTable)
        && current.bossController != 0 && current.bossControllerTable != 0
        && current.bossPhases != 0 && current.bossPhasesTable != 0 && current.bossPhaseList != 0
        && current.bossPhaseCount > 0 && current.bossPhaseCount <= 64
        && current.bossPhase >= 0 && current.bossPhase < current.bossPhaseCount;
    if (phaseValid)
    {
        vars.pawnManagerTable = current.pawnManagerTable;
        vars.bossPawnTable = current.bossPawnTable;
        if (vars.phaseManager != current.manager || vars.phaseLevel != level
            || vars.phaseController != current.bossController || vars.phaseConfig != current.bossPhases)
        {
            vars.phaseManager = current.manager;
            vars.phaseLevel = level;
            vars.phaseController = current.bossController;
            vars.phaseControllerTable = current.bossControllerTable;
            vars.phaseConfig = current.bossPhases;
            vars.phaseConfigTable = current.bossPhasesTable;
            vars.lastBossPhase = -1;
            vars.maxBossPhase = current.bossPhase;
            previousBossPhase = -1;
        }
        if (current.bossControllerTable == vars.phaseControllerTable && current.bossPhasesTable == vars.phaseConfigTable)
        {
            if (timer.CurrentPhase == TimerPhase.Running && vars.sampleTimeValid
                && previousBossPhase >= 0 && current.bossPhase == previousBossPhase + 1
                && current.bossPhase > vars.maxBossPhase && !vars.completed.Contains(level))
            {
                vars.phaseSplit = true;
                string phaseOption = "boss_" + level;
                vars.selectedSplit = settings["bossSplits"]
                    && (!settings.ContainsKey(phaseOption) || settings[phaseOption]);
            }
            vars.lastBossPhase = current.bossPhase;
            vars.maxBossPhase = Math.Max((int)vars.maxBossPhase, (int)current.bossPhase);
        }
        else vars.lastBossPhase = -1;
    }
    else vars.lastBossPhase = -1;
    // Al avanzar, el nivel nuevo puede aparecer con el GM anterior y ended=1.
    if (current.ended == 1 && sub == 7 && vars.armedManager == current.manager
        && vars.armedLevel == level && !vars.completed.Contains(level))
    {
        vars.pendingLevel = level;
        vars.pendingManager = current.manager;
        // EndLevelSpeedrun identifica estos finales segun la dificultad.
        // Sin siguiente arena, usar el acumulado valido de resultados.
        bool finalBoss = level == "MOTHERSHIP"
            || (current.difficulty == 2 && level == "BERNARD");
        if ((practice || finalBoss || settings["splitOnResults"]) && vars.sampleTimeValid)
        {
            vars.splitLevel = level;
            vars.splitSeconds = (double)vars.gameSeconds;
        }
    }
    if (!practice && !settings["splitOnResults"] && vars.pendingLevel != "" && current.manager != vars.pendingManager
        && level != vars.pendingLevel && current.ended == 0 && sub == 0 && current.chrono != 0
        && vars.sampleTimeValid && !float.IsNaN(current.chronoInitial) && !float.IsInfinity(current.chronoInitial)
        && current.chronoInitial >= 0 && current.chronoInitial <= vars.gameSeconds)
    {
        vars.splitLevel = vars.pendingLevel;
        // Chrono hereda el total exacto de la arena anterior. Evita capturar un
        // frame de retraso de Statistics o sumar primeros frames del nuevo jefe.
        vars.splitSeconds = (double)current.chronoInitial;
    }
    if (vars.splitLevel != "")
    {
        string option = "boss_" + (string)vars.splitLevel;
        // Niveles sin casilla conservan el comportamiento de la opcion general.
        vars.selectedSplit = settings["bossSplits"]
            && (!settings.ContainsKey(option) || settings[option]);
    }
}

start
{
    return vars.startPending;
}

reset
{
    if (settings["autoReset"] && vars.newRace && settings.ResetEnabled)
    {
        vars.automaticReset = true;
        return true;
    }
    return false;
}

split
{
    if (vars.phaseSplit) return settings.SplitEnabled && vars.selectedSplit;
    if (!settings.SplitEnabled || vars.splitLevel == "") return false;
    if (!vars.completed.Add((string)vars.splitLevel)) return false;
    // Consumir tambien los omitidos para no dividirlos despues en otra arena.
    if (vars.selectedSplit) print("Furi 1.0.0: completed segment " + vars.splitLevel);
    vars.pendingLevel = "";
    vars.pendingManager = 0UL;
    return vars.selectedSplit;
}

isLoading
{
    // Sin extrapolacion de LiveSplit: cada valor procede del reloj del juego.
    return true;
}

gameTime
{
    // gameTime corre antes de split: total heredado o acumulado de victoria final.
    if (vars.splitLevel != "" && settings.SplitEnabled && vars.selectedSplit && vars.gameTimeValid)
        return TimeSpan.FromSeconds((double)vars.splitSeconds);
    return TimeSpan.FromSeconds((double)vars.gameSeconds);
}

onStart
{
    vars.hitCount = 0;
    vars.koCount = 0;
    if (vars.supported && settings["hitCounter"]) ((Func<string, int, bool>)vars.setCounter)("Hits", 0);
    if (vars.supported && settings["koCounter"]) ((Func<string, int, bool>)vars.setCounter)("KO", 0);
    vars.lastBossPhase = -1;
    vars.phaseSplit = false;
    vars.startPending = false;
    vars.practiceStartPending = false;
    vars.completed.Clear();
    vars.armedManager = 0UL;
    vars.armedLevel = "";
    vars.pendingLevel = "";
    vars.pendingManager = 0UL;
}

onReset
{
    vars.hitCount = 0;
    vars.koCount = 0;
    if (vars.supported && settings["hitCounter"]) ((Func<string, int, bool>)vars.setCounter)("Hits", 0);
    if (vars.supported && settings["koCounter"]) ((Func<string, int, bool>)vars.setCounter)("KO", 0);
    vars.phaseManager = 0UL;
    vars.phaseController = 0UL;
    vars.lastBossPhase = -1;
    vars.maxBossPhase = -1;
    vars.phaseSplit = false;
    vars.completed.Clear();
    vars.armedManager = 0UL;
    vars.armedLevel = "";
    vars.pendingLevel = "";
    vars.pendingManager = 0UL;
    if (!vars.automaticReset) vars.startPending = false;
    vars.practiceStartPending = false;
    vars.automaticReset = false;
}
