// Furi Autosplitter 0.1.0-beta.1 - Windows / LiveSplit / Extras > Carrera.
// Solo los binarios con las huellas indicadas en init. No requiere Cheat Engine.
// El ultimo split de Carrera es MANUAL en esta beta.
// Game Time lee Statistics._time, actualizado por el juego con GameManager.GameTime.
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
    ulong manager : "mono-2.0-bdwgc.dll", 0x49AC78, 0x1ED08;
    ulong managerTable : "mono-2.0-bdwgc.dll", 0x49AC78, 0x1ED08, 0x0;
    int gameState : "mono-2.0-bdwgc.dll", 0x49AC78, 0x1ED08, 0x64;
    int subState : "mono-2.0-bdwgc.dll", 0x49AC78, 0x1ED08, 0x70;
    int preUnfocused : "mono-2.0-bdwgc.dll", 0x49AC78, 0x1ED08, 0x6C;
    byte ended : "mono-2.0-bdwgc.dll", 0x49AC78, 0x1ED08, 0x7B;
    ulong chrono : "mono-2.0-bdwgc.dll", 0x49AC78, 0x1ED08, 0x38;
    float chronoInitial : "mono-2.0-bdwgc.dll", 0x49AC78, 0x1ED08, 0x38, 0x54;
}

startup
{
    refreshRate = 60;
    settings.Add("bossSplits", true, "Un split al cargar el siguiente jefe");
    settings.Add("autoReset", false, "Reiniciar LiveSplit al iniciar otra Carrera (experimental)");
    settings.SetToolTip("bossSplits", "Guarda la victoria y divide al quedar lista la siguiente arena. El ultimo split de Carrera es MANUAL en esta beta.");
    settings.SetToolTip("autoReset", "Requiere Reset activado. Reinicia un intento en curso al reiniciar Carrera o iniciar una nueva desde el menu. Desactivado por defecto.");
}

init
{
    vars.supported = false;
    var mono = modules.FirstOrDefault(m => m.ModuleName == "mono-2.0-bdwgc.dll");
    if (mono == null) throw new Exception("Esperando modulo Mono");
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
    vars.gameSeconds = 0.0;
    vars.gameTimeValid = false;
    vars.sampleTimeValid = false;
    vars.lastData = 0UL;
    vars.baselineSeen = false;
    vars.armedManager = 0UL;
    vars.armedLevel = "";
    vars.completed = new HashSet<string>();
    vars.startPending = false;
    vars.newRace = false;
    vars.automaticReset = false;
    vars.splitLevel = "";
    vars.splitSeconds = 0.0;
    vars.pendingLevel = "";
    vars.pendingManager = 0UL;
    version = vars.supported ? "0.1.0-beta.1 - compatible" : "0.1.0-beta.1 - BUILD NO COMPATIBLE";
    print(vars.supported ? "Furi beta: binarios compatibles" : "Furi beta: binarios diferentes, acciones desactivadas");
}

update
{
    vars.newRace = false;
    vars.splitLevel = "";
    vars.sampleTimeValid = false;
    if (!vars.supported) return false;
    // Al entrar a otro modo, no conservar una victoria pendiente de Carrera.
    if (current.domain != 0 && current.global != 0 && current.globalTable != 0
        && (vars.globalTable == 0UL || current.globalTable == vars.globalTable)
        && current.mode >= 0 && current.mode <= 4 && current.mode != 4)
    {
        vars.pendingLevel = "";
        vars.pendingManager = 0UL;
        vars.armedManager = 0UL;
        vars.armedLevel = "";
        vars.startPending = false;
    }
    // Registrar el menu limpio para reconocer el primer START de un proceso.
    if (current.domain != 0 && current.global != 0 && current.globalTable != 0
        && current.mode == 0 && current.data == 0)
    {
        vars.baselineSeen = true;
        vars.lastData = 0UL;
        return false;
    }
    if (current.domain == 0 || current.global == 0 || current.globalTable == 0
        || current.data == 0 || current.dataTable == 0 || current.mode != 4 || current.dataMode != 4
        || (current.difficulty != 1 && current.difficulty != 2)
        || current.levelLength <= 0 || current.levelLength > 32 || current.levelBytes == null)
        return false;
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
        vars.baselineSeen = true;
    }
    else if (current.data != vars.lastData)
    {
        vars.lastData = current.data;
        vars.completed.Clear();
        vars.armedManager = 0UL;
        vars.armedLevel = "";
        vars.pendingLevel = "";
        vars.pendingManager = 0UL;
        vars.gameSeconds = 0.0;
        vars.gameTimeValid = false;
        vars.newRace = level == "LAW";
        vars.startPending = vars.newRace && settings.StartEnabled
            && (timer.CurrentPhase == TimerPhase.NotRunning || (settings["autoReset"] && settings.ResetEnabled));
        print("Furi beta: partida nueva, nivel=" + level);
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
    if (current.manager == 0 || current.managerTable == 0
        || current.gameState < 0 || current.gameState > 17 || current.subState < 0 || current.subState > 9
        || current.ended > 1) return;
    if (vars.managerTable != 0UL && current.managerTable != vars.managerTable) return;
    vars.managerTable = current.managerTable;
    int sub = current.subState == 8 ? current.preUnfocused : current.subState;
    // Sin siguiente arena no se genera split: cierre final manual en esta beta.
    if (current.gameState != 4) return;
    if (current.ended == 0 && (sub == 0 || sub == 1))
    {
        vars.armedManager = current.manager;
        vars.armedLevel = level;
    }
    // Al avanzar, el nivel nuevo puede aparecer con el GM anterior y ended=1.
    if (current.ended == 1 && sub == 7 && vars.armedManager == current.manager
        && vars.armedLevel == level && !vars.completed.Contains(level))
    {
        vars.pendingLevel = level;
        vars.pendingManager = current.manager;
    }
    if (vars.pendingLevel != "" && current.manager != vars.pendingManager
        && level != vars.pendingLevel && current.ended == 0 && sub == 0 && current.chrono != 0
        && vars.sampleTimeValid && !float.IsNaN(current.chronoInitial) && !float.IsInfinity(current.chronoInitial)
        && current.chronoInitial >= 0 && current.chronoInitial <= vars.gameSeconds)
    {
        vars.splitLevel = vars.pendingLevel;
        // Chrono hereda el total exacto de la arena anterior. Evita capturar un
        // frame de retraso de Statistics o sumar primeros frames del nuevo jefe.
        vars.splitSeconds = (double)current.chronoInitial;
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
    if (!settings["bossSplits"] || !settings.SplitEnabled || vars.splitLevel == "") return false;
    if (!vars.completed.Add((string)vars.splitLevel)) return false;
    print("Furi beta: tramo completado " + vars.splitLevel);
    vars.pendingLevel = "";
    vars.pendingManager = 0UL;
    return true;
}

isLoading
{
    // Sin extrapolacion de LiveSplit: cada valor procede del reloj del juego.
    return true;
}

gameTime
{
    // gameTime corre antes de split: el total heredado es el limite del tramo.
    if (vars.splitLevel != "" && settings.SplitEnabled && settings["bossSplits"] && vars.gameTimeValid)
        return TimeSpan.FromSeconds((double)vars.splitSeconds);
    return TimeSpan.FromSeconds((double)vars.gameSeconds);
}

onStart
{
    vars.startPending = false;
    vars.completed.Clear();
    vars.armedManager = 0UL;
    vars.armedLevel = "";
    vars.pendingLevel = "";
    vars.pendingManager = 0UL;
}

onReset
{
    vars.completed.Clear();
    vars.armedManager = 0UL;
    vars.armedLevel = "";
    vars.pendingLevel = "";
    vars.pendingManager = 0UL;
    if (!vars.automaticReset) vars.startPending = false;
    vars.automaticReset = false;
}
