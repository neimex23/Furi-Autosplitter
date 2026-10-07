using System;
using System.Collections.Generic;
using System.Diagnostics;
using System.Dynamic;
using System.IO;
using System.Reflection;
using System.Runtime.Serialization;
using System.Text;
using System.Text.RegularExpressions;
using LiveSplit.ASL;
using LiveSplit.Model;

public static class FuriReplay
{
    private sealed class Runner
    {
        public ASLScript Script;
        public object Methods;
        public ASLSettings Settings = new ASLSettings();
        public LiveSplitState Timer = (LiveSplitState)FormatterServices.GetUninitializedObject(typeof(LiveSplitState));
        public Process Game;
        public ExpandoObject Old = new ExpandoObject();
        public string Version = "";
        public double Rate = 60;
        public int Starts, Resets, Splits;
        public double LastGameTime;
        public List<double> SplitGameTimes=new List<double>();
        public Runner(string source, Process game, bool reset)
        {
            Game=game;
            Script=ASLParser.Parse(source);
            Methods=typeof(ASLScript).GetField("_methods",BindingFlags.NonPublic|BindingFlags.Instance).GetValue(Script);
            Timer.CurrentPhase=TimerPhase.NotRunning;
            Call("startup",Old);
            Settings.AddBasicSetting("start"); Settings.AddBasicSetting("split"); Settings.AddBasicSetting("reset");
            Settings.BasicSettings["start"].Value=true; Settings.BasicSettings["split"].Value=true; Settings.BasicSettings["reset"].Value=true;
            Settings.Settings["autoReset"].Value=reset;
            Call("init",Old);
            if (!(bool)((IDictionary<string,object>)Script.Vars)["supported"])
                throw new Exception("Los binarios actuales no pasaron init");
        }
        public object Call(string name, ExpandoObject current)
        {
            var method=(ASLMethod)Methods.GetType().GetField(name).GetValue(Methods);
            object reader=name=="startup"?(object)new ASLSettingsBuilder(Settings):new ASLSettingsReader(Settings);
            return method.Call(Timer,Script.Vars,ref Version,ref Rate,reader,Old,current,Game);
        }
        public void Tick(ExpandoObject current)
        {
            var update=Call("update",current);
            if (!(update is bool) || (bool)update)
            {
                if(Timer.CurrentPhase==TimerPhase.Running)
                {
                    if(!Object.Equals(Call("isLoading",current),true)) throw new Exception("Game Time debe quedar sin extrapolacion");
                    LastGameTime=((TimeSpan)Call("gameTime",current)).TotalSeconds;
                    if(Object.Equals(Call("reset",current),true))
                    { Resets++; Timer.CurrentPhase=TimerPhase.NotRunning; Call("onReset",current); }
                    else if(Object.Equals(Call("split",current),true)) { Splits++; SplitGameTimes.Add(LastGameTime); }
                }
                if(Timer.CurrentPhase==TimerPhase.NotRunning && Object.Equals(Call("start",current),true))
                { Starts++; Timer.CurrentPhase=TimerPhase.Running; Call("onStart",current); }
            }
            Old=current;
        }
    }
    public static string CheckUnsupportedCounter(string sourcePath,int pid)
    {
        var runner=new Runner(File.ReadAllText(sourcePath),Process.GetProcessById(pid),false);
        var vars=(IDictionary<string,object>)runner.Script.Vars;
        vars["supported"]=false;
        vars["setCounter"]=(Func<string,int,bool>)((metric,value) => { throw new Exception("Unsupported build wrote Counter"); });
        runner.Settings.Settings["hitCounter"].Value=true;
        runner.Settings.Settings["koCounter"].Value=true;
        runner.Call("onStart",new ExpandoObject()); runner.Call("onReset",new ExpandoObject());
        return "Unsupported build: manual Start/Reset does not write Counter OK";
    }
    private static string Field(string line,string key)
    { var m=Regex.Match(line,@"\b"+key+@"=([^\s|]+)"); return m.Success?m.Groups[1].Value:null; }
    private static LiveSplit.UI.Components.IComponent CounterComponent(string label, out object counter)
    {
        var assembly=Assembly.LoadFrom(Path.Combine(Path.GetDirectoryName(typeof(ASLScript).Assembly.Location),"LiveSplit.Counter.dll"));
        var componentType=assembly.GetType("LiveSplit.UI.Components.CounterComponent");
        var settingsType=assembly.GetType("LiveSplit.UI.Components.CounterComponentSettings");
        var component=FormatterServices.GetUninitializedObject(componentType);
        var settings=FormatterServices.GetUninitializedObject(settingsType);
        settingsType.GetField("<CounterText>k__BackingField",BindingFlags.NonPublic|BindingFlags.Instance).SetValue(settings,label);
        counter=Activator.CreateInstance(assembly.GetType("LiveSplit.UI.Components.Counter"),new object[]{0,1});
        counter.GetType().GetMethod("SetCount").Invoke(counter,new object[]{0});
        componentType.GetProperty("Counter").SetValue(component,counter,null);
        componentType.GetProperty("Settings").SetValue(component,settings,null);
        return (LiveSplit.UI.Components.IComponent)component;
    }
    private static int CounterValue(object counter)
    { return (int)counter.GetType().GetProperty("Count").GetValue(counter,null); }
    private static ulong Hex(string line,string key)
    { var s=Field(line,key); return s==null?0UL:Convert.ToUInt64(s,16); }
    private static int Number(string line,string key)
    { var s=Field(line,key); return s==null?0:Int32.Parse(s,System.Globalization.CultureInfo.InvariantCulture); }
    private static float Float(string line,string key)
    { var s=Field(line,key); return s==null?0:Single.Parse(s,System.Globalization.CultureInfo.InvariantCulture); }
    private static ExpandoObject Sample(string line)
    {
        dynamic s=new ExpandoObject();
        s.domain=1UL; s.global=Hex(line,"Global"); s.globalTable=s.global==0?0UL:0x100UL;
        s.mode=Number(line,"modo"); s.data=Hex(line,"partida");
        string level=Field(line,"nivel"); s.dataTable=level==null?0UL:0x200UL;
        s.dataMode=Number(line,"modoPartida"); s.difficulty=Number(line,"dificultad");
        s.levelLength=level==null?0:level.Length;
        var bytes=new byte[64]; if(level!=null) Array.Copy(Encoding.Unicode.GetBytes(level),bytes,level.Length*2);
        s.levelBytes=bytes;
        s.manager=Hex(line,"GM"); s.managerTable=s.manager==0?0UL:0x300UL;
        s.gameState=Number(line,"estado"); s.subState=Number(line,"sub");
        s.preUnfocused=Number(line,"previoFoco"); s.ended=(byte)Number(line,"final");
        s.chrono=Hex(line,"chrono");
        s.chronoInitial=Float(line,"inicial");
        s.statistics=s.data==0?0UL:0x400UL; s.statisticsTable=level==null?0UL:0x500UL;
        string timeKey=Field(line,"gameTime")!=null?"gameTime":"reloj";
        float gameSeconds=Float(line,timeKey);
        if(Field(line,timeKey)==null && Number(line,"pausado")==1 && Field(line,"inicio")!=null)
            gameSeconds=Float(line,"inicial")+Float(line,"pausaDesde")-Float(line,"inicio")-Float(line,"pausaAcum");
        else if(Field(line,timeKey)==null && Field(line,"inicial")!=null) gameSeconds=Float(line,"inicial");
        s.inGameSeconds=gameSeconds;
        s.receivedHits=Number(line,"hits");
        s.receivedKO=Number(line,"KO");
        s.pawnManager=Hex(line,"PM"); s.pawnManagerTable=s.pawnManager==0?0UL:0x600UL;
        s.bossPawn=Hex(line,"pawn"); s.bossPawnTable=s.bossPawn==0?0UL:0x700UL;
        s.bossController=Hex(line,"controller"); s.bossControllerTable=s.bossController==0?0UL:0x800UL;
        s.bossPhases=Hex(line,"phaseConfig"); s.bossPhasesTable=s.bossPhases==0?0UL:0x900UL;
        s.bossPhaseList=Hex(line,"phaseList");
        s.bossPhase=Number(line,"phase"); s.bossPhaseCount=Number(line,"count");
        return s;
    }
    public static string Run(string sourcePath,string logPath,int pid)
    {
        string source=File.ReadAllText(sourcePath); var game=Process.GetProcessById(pid);
        var output=new List<string>();
        foreach(bool autoReset in new[]{false,true})
        {
            var runner=new Runner(source,game,autoReset);
            foreach(string line in File.ReadAllLines(logPath))
                if(line.StartsWith("[")) runner.Tick(Sample(line));
            // Repetir resultados no debe duplicar el split.
            runner.Tick(Sample("Global=10 modo=4 partida=1CFFA6B7D80 nivel=NEMESIS modoPartida=4 dificultad=1 | GM=1CD83A3A6E0 estado=4 sub=8 previoFoco=0 final=0"));
            int starts=autoReset?2:1, resets=autoReset?1:0;
            if(runner.Starts!=starts || runner.Resets!=resets || runner.Splits!=1)
                throw new Exception(String.Format("Replay fallido: autoReset={0}, starts={1}, resets={2}, splits={3}",autoReset,runner.Starts,runner.Resets,runner.Splits));
            output.Add(String.Format("Replay autoReset={0}: starts={1}, resets={2}, splits={3} OK",autoReset,runner.Starts,runner.Resets,runner.Splits));
        }
        var first=new Runner(source,game,false);
        first.Tick(Sample("Global=10 modo=0 partida=0 | GM INVALIDO"));
        first.Tick(Sample("Global=10 modo=4 partida=20 nivel=LAW modoPartida=4 dificultad=2 | GM INVALIDO"));
        if(first.Starts!=1 || first.Splits!=0) throw new Exception("Primer inicio desde menu limpio fallo");
        output.Add("Menu limpio -> primer START Furiosa: un inicio OK");
        var attach=new Runner(source,game,false);
        string results="Global=10 modo=4 partida=20 nivel=LAW modoPartida=4 dificultad=1 | GM=30 estado=4 sub=7 previoFoco=0 final=1";
        attach.Tick(Sample(results)); attach.Tick(Sample(results));
        if(attach.Starts!=0 || attach.Splits!=0) throw new Exception("Adjuntar en resultados produjo evento");
        output.Add("Adjuntar en resultados: sin inicio ni split OK");
        var duplicate=new Runner(source,game,false);
        duplicate.Tick(Sample("Global=10 modo=4 partida=20 nivel=LAW modoPartida=4 dificultad=1 | GM=30 estado=4 sub=0 previoFoco=0 final=0"));
        duplicate.Timer.CurrentPhase=TimerPhase.Running; duplicate.Call("onStart",new ExpandoObject());
        duplicate.Tick(Sample("Global=10 modo=4 partida=20 nivel=LAW modoPartida=4 dificultad=1 | GM=30 estado=4 sub=0 previoFoco=0 final=0"));
        duplicate.Tick(Sample(results)); duplicate.Tick(Sample(results));
        duplicate.Tick(Sample("Global=10 modo=4 partida=20 nivel=NEMESIS modoPartida=4 dificultad=1 | GM=30 estado=4 sub=7 previoFoco=7 final=1"));
        if(duplicate.Splits!=0) throw new Exception("Split prematuro en resultados/cambio de nivel");
        duplicate.Tick(Sample("Global=10 modo=4 partida=20 nivel=NEMESIS modoPartida=4 dificultad=1 | GM=40 estado=4 sub=5 previoFoco=0 final=0"));
        if(duplicate.Splits!=0) throw new Exception("Split prematuro durante carga");
        string loaded="Global=10 modo=4 partida=20 nivel=NEMESIS modoPartida=4 dificultad=1 | GM=40 estado=4 sub=0 previoFoco=0 final=0 | chrono=50";
        duplicate.Tick(Sample(loaded)); duplicate.Tick(Sample(loaded));
        if(duplicate.Splits!=1) throw new Exception("Split al cargar siguiente arena ausente o duplicado");
        output.Add("Resultados/carga: cero splits; siguiente arena lista: un split OK");
        var clock=new Runner(source,game,false);
        string combat="Global=10 modo=4 partida=20 nivel=LAW modoPartida=4 dificultad=1 | GM=30 estado=4 sub=0 previoFoco=0 final=0 | chrono=50 reloj=200";
        clock.Tick(Sample(combat)); clock.Timer.CurrentPhase=TimerPhase.Running; clock.Call("onStart",new ExpandoObject());
        clock.Tick(Sample(combat));
        string paused="Global=10 modo=4 partida=20 nivel=LAW modoPartida=4 dificultad=1 | GM=30 estado=4 sub=8 previoFoco=4 final=0 | chrono=50 reloj=217.30";
        clock.Tick(Sample(paused)); clock.Tick(Sample(paused)); clock.Tick(Sample("Global INVALIDO | GM INVALIDO"));
        if(Math.Abs(clock.LastGameTime-217.30)>0.001) throw new Exception("Pausa/hueco altero Game Time");
        clock.Tick(Sample(combat+" ")); // lectura anterior menor debe descartarse como retroceso
        if(Math.Abs(clock.LastGameTime-217.30)>0.001) throw new Exception("Lectura atrasada hizo retroceder IGT");
        clock.Tick(Sample(results+" | reloj=217.30"));
        clock.Tick(Sample("Global=10 modo=4 partida=20 nivel=NEMESIS modoPartida=4 dificultad=1 | GM=40 estado=4 sub=5 previoFoco=0 final=0 | reloj=217.30"));
        clock.Tick(Sample(loaded+" inicial=217.30 reloj=217.90"));
        if(clock.Splits!=1 || Math.Abs(clock.SplitGameTimes[0]-217.30)>0.001) throw new Exception("Split no conserva total exacto del jefe anterior");
        clock.Tick(Sample(loaded+" inicial=217.30 reloj=218.50"));
        if(Math.Abs(clock.LastGameTime-218.50)>0.001) throw new Exception("IGT no continua acumulado en siguiente jefe");
        output.Add("IGT: pausa/carga/huecos conservan total; split usa 217.30; siguiente jefe continua OK");
        // Statistics puede quedar un frame atras al ganar: usar el total heredado.
        var delayed=new Runner(source,game,false);
        delayed.Tick(Sample(combat)); delayed.Timer.CurrentPhase=TimerPhase.Running;
        delayed.Tick(Sample(results+" reloj=217.28"));
        var invalidClock=Sample(loaded+" inicial=217.30 reloj=NaN");
        delayed.Tick(invalidClock);
        if(delayed.Splits!=0) throw new Exception("Split con lectura de tiempo invalida");
        delayed.Tick(Sample(loaded+" inicial=217.30 reloj=217.90"));
        if(delayed.Splits!=1 || Math.Abs(delayed.SplitGameTimes[0]-217.30)>0.001)
            throw new Exception("No se uso el total exacto heredado por Chrono");
        output.Add("Statistics atrasado/NaN: espera dato valido y divide en total heredado OK");
        var mode=new Runner(source,game,false);
        mode.Tick(Sample(combat)); mode.Timer.CurrentPhase=TimerPhase.Running;
        mode.Tick(Sample(results+" reloj=217.30"));
        mode.Tick(Sample("Global=10 modo=3 partida=60 nivel=MOTHERSHIP modoPartida=3 dificultad=1 | GM=70 estado=4 sub=7 previoFoco=0 final=1 | reloj=52.95"));
        mode.Tick(Sample(loaded+" inicial=217.30 reloj=218.50"));
        if(mode.Starts!=0 || mode.Resets!=0 || mode.Splits!=0)
            throw new Exception("Practica produjo evento o dejo victoria pendiente");
        output.Add("Practica: sin eventos, limpia victoria pendiente OK");
        foreach(int difficulty in new[]{1,2})
        {
            // Normal, sin LAW ni jefe final: cualquier jefe seleccionado en Practica.
            var practice=new Runner(source,game,true);
            if(practice.Settings.Settings["practiceMode"].Value)
                throw new Exception("Practica debe estar desactivada por defecto");
            practice.Settings.Settings["practiceMode"].Value=true;
            string prefix="Global=10 modo=3 partida=60 nivel=NEMESIS modoPartida=3 dificultad="+difficulty+" | GM=70 estado=4 ";
            string active=prefix+"sub=0 final=0 | chrono=80 reloj=0.05";
            practice.Tick(Sample("Global=10 modo=0 partida=0 | GM INVALIDO"));
            practice.Tick(Sample(prefix+"sub=5 final=0 reloj=0"));
            if(practice.Starts!=0) throw new Exception("Practica inicio durante carga");
            practice.Tick(Sample(active)); practice.Tick(Sample(active));
            if(practice.Starts!=1 || practice.Resets!=0) throw new Exception("Practica no inicia una vez al quedar lista");
            practice.Tick(Sample(prefix+"sub=8 previoFoco=4 final=0 | chrono=80 reloj=12.5"));
            practice.Tick(Sample("Global INVALIDO | GM INVALIDO"));
            if(Math.Abs(practice.LastGameTime-12.5)>0.001) throw new Exception("Pausa/hueco de Practica altero reloj");
            practice.Tick(Sample(prefix+"sub=3 final=0 reloj=12.5"));
            practice.Tick(Sample(active));
            practice.Tick(Sample(prefix+"sub=2 final=0 reloj=13"));
            practice.Tick(Sample(prefix+"sub=7 final=1 reloj=NaN"));
            if(practice.Splits!=0) throw new Exception("Practica divide en muerte/fase/NaN");
            string victory=prefix+"sub=8 previoFoco=7 final=1 reloj=15.25";
            practice.Tick(Sample(victory)); practice.Tick(Sample(victory));
            if(practice.Splits!=1 || Math.Abs(practice.SplitGameTimes[0]-15.25)>0.001)
                throw new Exception("Practica no divide una vez en victoria con su tiempo");
            // El reset opcional de Carrera no se aplica a otra Practica.
            practice.Tick(Sample(active.Replace("partida=60","partida=90").Replace("GM=70","GM=A0")));
            if(practice.Resets!=0 || practice.Starts!=1) throw new Exception("Practica disparo reset de Carrera");
            practice.Timer.CurrentPhase=TimerPhase.NotRunning; practice.Call("onReset",new ExpandoObject());
            practice.Settings.Settings["boss_NEMESIS"].Value=false;
            string newActive=active.Replace("partida=60","partida=B0").Replace("GM=70","GM=C0");
            practice.Tick(Sample(newActive)); practice.Tick(Sample(newActive));
            practice.Tick(Sample(victory.Replace("partida=60","partida=B0").Replace("GM=70","GM=C0")));
            if(practice.Starts!=2 || practice.Splits!=1) throw new Exception("Practica no respeta casilla del jefe");
            output.Add("Practica dificultad="+difficulty+": START en arena lista, reloj/pausa, victoria unica y casilla; sin reset de Carrera OK (sintetico)");
        }
        var practiceAttach=new Runner(source,game,false);
        practiceAttach.Settings.Settings["practiceMode"].Value=true;
        practiceAttach.Tick(Sample(combat.Replace("modo=4","modo=3").Replace("modoPartida=4","modoPartida=3")));
        if(practiceAttach.Starts!=0) throw new Exception("Adjuntar en Practica inicio automaticamente");
        practiceAttach.Timer.CurrentPhase=TimerPhase.Running; practiceAttach.Call("onStart",new ExpandoObject());
        practiceAttach.Tick(Sample(results.Replace("modo=4","modo=3").Replace("modoPartida=4","modoPartida=3")));
        if(practiceAttach.Splits!=0) throw new Exception("Practica sin observacion activa posterior al START dividio");
        var modeSwitch=new Runner(source,game,false);
        modeSwitch.Settings.Settings["practiceMode"].Value=true;
        modeSwitch.Tick(Sample(combat)); modeSwitch.Timer.CurrentPhase=TimerPhase.Running;
        modeSwitch.Tick(Sample(results+" reloj=217.30"));
        modeSwitch.Tick(Sample(results.Replace("modo=4","modo=3").Replace("modoPartida=4","modoPartida=3")+" reloj=1"));
        modeSwitch.Tick(Sample(loaded+" inicial=217.30 reloj=218.50"));
        if(modeSwitch.Splits!=0) throw new Exception("Cambio Carrera/Practica heredo victoria pendiente");
        output.Add("Practica: adjuntar no inicia; cambio de modo limpia pendiente incluso con misma partida OK");
        // Cada casilla filtra el jefe completado, no el que acaba de cargar.
        foreach(string level in new[]{"LAW","NEMESIS","WISE","SCALE","FATHER","WING","MAZE","CHALLENGER","HORN","MOTHERSHIP","AVENGER","BERNARD"})
        {
            int difficulty=level=="BERNARD"?2:1;
            var selection=new Runner(source,game,false);
            string option="boss_"+level;
            if(!selection.Settings.Settings[option].Value || !selection.Settings.Settings["bossSplits"].Value)
                throw new Exception("Casillas deben estar activadas por defecto: "+level);
            string fight=combat.Replace("LAW",level).Replace("dificultad=1","dificultad="+difficulty);
            string victory=results.Replace("LAW",level).Replace("dificultad=1","dificultad="+difficulty);
            string next=loaded.Replace("NEMESIS","TEST_NEXT").Replace("dificultad=1","dificultad="+difficulty)+" inicial=217.30 reloj=217.90";
            selection.Settings.Settings[option].Value=false;
            selection.Tick(Sample(fight)); selection.Timer.CurrentPhase=TimerPhase.Running;
            selection.Tick(Sample(victory+" reloj=217.30"));
            selection.Tick(Sample(next));
            if(selection.Splits!=0 || Math.Abs(selection.LastGameTime-217.90)>0.001)
                throw new Exception("Casilla desactivada divide o altera reloj: "+level);
            selection.Settings.Settings[option].Value=true;
            selection.Tick(Sample(next));
            if(selection.Splits!=0) throw new Exception("Jefe omitido quedo pendiente: "+level);
            // Nueva partida: la misma casilla activada debe dividir una sola vez.
            selection.Tick(Sample(fight.Replace("partida=20","partida=60").Replace("GM=30","GM=70")));
            string newVictory= victory.Replace("partida=20","partida=60").Replace("GM=30","GM=70")+" reloj=217.30";
            string newNext=next.Replace("partida=20","partida=60").Replace("GM=40","GM=80");
            selection.Tick(Sample(newVictory)); selection.Tick(Sample(newNext)); selection.Tick(Sample(newNext));
            if(selection.Splits!=1 || Math.Abs(selection.SplitGameTimes[0]-217.30)>0.001)
                throw new Exception("Casilla activada ausente/duplicada o tiempo incorrecto: "+level);
        }
        output.Add("12 casillas: activadas por defecto; omitir conserva IGT y consume pendiente; activar divide una vez OK (sintetico)");
        var general=new Runner(source,game,false);
        general.Settings.Settings["bossSplits"].Value=false;
        general.Tick(Sample(combat)); general.Timer.CurrentPhase=TimerPhase.Running;
        general.Tick(Sample(results+" reloj=217.30")); general.Tick(Sample(loaded+" inicial=217.30 reloj=217.90"));
        if(general.Splits!=0 || Math.Abs(general.LastGameTime-217.90)>0.001)
            throw new Exception("Opcion general no domina casillas o altera reloj");
        output.Add("Opcion general desactivada domina casillas activadas y conserva reloj OK");
        foreach(int difficulty in new[]{1,2})
        {
            var early=new Runner(source,game,false);
            if(early.Settings.Settings["splitOnResults"].Value)
                throw new Exception("Timing por defecto debe ser siguiente arena");
            early.Settings.Settings["splitOnResults"].Value=true;
            string fight=combat.Replace("dificultad=1","dificultad="+difficulty);
            string victory=results.Replace("dificultad=1","dificultad="+difficulty);
            early.Tick(Sample(fight)); early.Timer.CurrentPhase=TimerPhase.Running;
            early.Tick(Sample(victory.Replace("sub=7","sub=3")+" reloj=210"));
            early.Tick(Sample(victory.Replace("sub=7","sub=2")+" reloj=211"));
            early.Tick(Sample(victory+" reloj=NaN"));
            if(early.Splits!=0) throw new Exception("Timing resultados divide en muerte/fase/NaN");
            early.Tick(Sample(victory+" reloj=217.30")); early.Tick(Sample(victory+" reloj=217.30"));
            early.Tick(Sample(loaded.Replace("dificultad=1","dificultad="+difficulty)+" inicial=217.30 reloj=217.90"));
            if(early.Splits!=1 || Math.Abs(early.SplitGameTimes[0]-217.30)>0.001 || Math.Abs(early.LastGameTime-217.90)>0.001)
                throw new Exception("Timing resultados: split ausente/duplicado o reloj incorrecto");
            early.Settings.Settings["boss_LAW"].Value=false;
            early.Tick(Sample(fight.Replace("partida=20","partida=60").Replace("GM=30","GM=70")));
            early.Tick(Sample(victory.Replace("partida=20","partida=60").Replace("GM=30","GM=70")+" reloj=217.30"));
            if(early.Splits!=1) throw new Exception("Timing resultados ignora casilla desactivada");
            output.Add("Timing resultados dificultad="+difficulty+": split inmediato unico, reloj continua, casillas y falsos positivos OK");
        }
        foreach(int difficulty in new[]{1,2})
        {
            string level=difficulty==1?"MOTHERSHIP":"BERNARD";
            string fight=combat.Replace("LAW",level).Replace("dificultad=1","dificultad="+difficulty);
            string victory=results.Replace("LAW",level).Replace("dificultad=1","dificultad="+difficulty);
            var finalBoss=new Runner(source,game,false);
            finalBoss.Tick(Sample(fight)); finalBoss.Timer.CurrentPhase=TimerPhase.Running;
            finalBoss.Tick(Sample(victory.Replace("sub=7","sub=2")+" reloj=215"));
            finalBoss.Tick(Sample(victory.Replace("sub=7","sub=3")+" reloj=216"));
            finalBoss.Tick(Sample("Global INVALIDO | GM INVALIDO"));
            finalBoss.Tick(Sample(victory+" reloj=NaN"));
            if(finalBoss.Splits!=0) throw new Exception("Cierre en fase/muerte/hueco/tiempo invalido");
            finalBoss.Tick(Sample(victory.Replace("sub=7 previoFoco=0","sub=8 previoFoco=7")+" reloj=217.30"));
            finalBoss.Tick(Sample(victory+" reloj=217.30"));
            finalBoss.Tick(Sample(victory.Replace("estado=4","estado=17")+" reloj=217.30"));
            finalBoss.Tick(Sample("Global=10 modo=0 partida=0 | GM INVALIDO"));
            if(finalBoss.Splits!=1 || Math.Abs(finalBoss.SplitGameTimes[0]-217.30)>0.001)
                throw new Exception("Cierre final ausente/duplicado o tiempo incorrecto: "+level);
            foreach(string excluded in new[]{"modo=3 modoPartida=3", "modo=1 modoPartida=1"})
            {
                string[] modes=excluded.Split(' ');
                var other=new Runner(source,game,false); other.Timer.CurrentPhase=TimerPhase.Running;
                other.Tick(Sample(fight.Replace("modo=4",modes[0]).Replace("modoPartida=4",modes[1])));
                other.Tick(Sample(victory.Replace("modo=4",modes[0]).Replace("modoPartida=4",modes[1])+" reloj=217.30"));
                if(other.Splits!=0) throw new Exception("Cierre fuera de Carrera: "+excluded);
            }
            var unarmed=new Runner(source,game,false); unarmed.Timer.CurrentPhase=TimerPhase.Running;
            unarmed.Tick(Sample(victory+" reloj=217.30"));
            if(unarmed.Splits!=0) throw new Exception("Adjuntar en victoria final produjo split");
            var wrongDifficulty=new Runner(source,game,false);
            int otherDifficulty=difficulty==1?2:1;
            wrongDifficulty.Tick(Sample(fight.Replace("dificultad="+difficulty,"dificultad="+otherDifficulty)));
            wrongDifficulty.Timer.CurrentPhase=TimerPhase.Running;
            wrongDifficulty.Tick(Sample(victory.Replace("dificultad="+difficulty,"dificultad="+otherDifficulty)+" reloj=217.30"));
            int expected=level=="MOTHERSHIP"?1:0;
            if(wrongDifficulty.Splits!=expected) throw new Exception("Star siempre en resultados o Bernard solo final Furiosa fallo");
            var disabled=new Runner(source,game,false); disabled.Tick(Sample(fight));
            disabled.Timer.CurrentPhase=TimerPhase.Running; disabled.Settings.Settings["bossSplits"].Value=false;
            disabled.Tick(Sample(victory+" reloj=217.30"));
            if(disabled.Splits!=0) throw new Exception("Cierre con splits desactivados");
            output.Add("Final "+level+" dificultad="+difficulty+": un split en victoria a 217.30; exclusiones y duplicados OK (sintetico)");
        }
        foreach(int phaseMode in new[]{3,4}) foreach(int difficulty in new[]{1,2})
        {
            var phases=new Runner(source,game,false);
            if(phases.Settings.Settings["phaseSplits"].Value) throw new Exception("Fases deben estar desactivadas por defecto");
            phases.Settings.Settings["phaseSplits"].Value=true;
            phases.Settings.Settings["practiceMode"].Value=true;
            string arena="Global=10 modo="+phaseMode+" partida=20 nivel=LAW modoPartida="+phaseMode+" dificultad="+difficulty
                +" | GM=30 estado=4 sub=0 previoFoco=0 final=0 chrono=50 PM=60 pawn=70 controller=80 phaseConfig=90 phaseList=A0 count=4";
            phases.Tick(Sample(arena+" phase=0 reloj=1"));
            phases.Timer.CurrentPhase=TimerPhase.Running; phases.Call("onStart",new ExpandoObject());
            phases.Tick(Sample(arena+" phase=0 reloj=1"));
            phases.Tick(Sample(arena.Replace("sub=0","sub=1")+" phase=1 reloj=36.3831367"));
            phases.Tick(Sample(arena+" phase=1 reloj=41.75938"));
            if(phases.Splits!=1 || Math.Abs(phases.SplitGameTimes[0]-36.3831367)>0.001)
                throw new Exception("Fase 0 -> 1 debe dividir una vez con Statistics");
            // Regresion y repeticion de una fase ya dividida: nunca duplicar.
            phases.Tick(Sample(arena.Replace("sub=0","sub=3")+" phase=1 reloj=45"));
            phases.Tick(Sample(arena+" phase=0 reloj=46"));
            phases.Tick(Sample(arena+" phase=1 reloj=47"));
            if(phases.Splits!=1) throw new Exception("Muerte/regresion duplico fase");
            // Un jefe desmarcado consume el avance; reactivarlo no lo repite.
            phases.Settings.Settings["boss_LAW"].Value=false;
            phases.Tick(Sample(arena+" phase=2 reloj=48"));
            phases.Settings.Settings["boss_LAW"].Value=true;
            phases.Tick(Sample(arena+" phase=2 reloj=49"));
            if(phases.Splits!=1 || Math.Abs(phases.LastGameTime-49)>0.001) throw new Exception("Filtro de jefe en fases altero splits/reloj");
            phases.Settings.Settings["bossSplits"].Value=false;
            phases.Tick(Sample(arena+" phase=3 reloj=50"));
            phases.Settings.Settings["bossSplits"].Value=true;
            phases.Tick(Sample(arena+" phase=3 reloj=51"));
            if(phases.Splits!=1) throw new Exception("Opcion general no filtro las fases");
            string victory=arena.Replace("sub=0","sub=7").Replace("final=0","final=1")+" phase=3 reloj=55";
            phases.Tick(Sample(victory)); phases.Tick(Sample(victory));
            if(phaseMode==4)
            {
                if(phases.Splits!=1) throw new Exception("Fases cambio el limite de victoria de Carrera");
                string next=arena.Replace("LAW","NEMESIS").Replace("GM=30","GM=40").Replace("controller=80","controller=B0")+" phase=0 inicial=55 reloj=56";
                phases.Tick(Sample(next)); phases.Tick(Sample(next));
            }
            if(phases.Splits!=2 || Math.Abs(phases.SplitGameTimes[1]-55)>0.001) throw new Exception("Victoria final de fase duplicada/ausente");
            // Nueva partida: gaps, NaN, saltos multiples y datos fuera de rango.
            arena=arena.Replace("partida=20","partida=C0").Replace("GM=30","GM=D0");
            phases.Tick(Sample(arena+" phase=0 reloj=1"));
            phases.Tick(Sample("Global INVALIDO | GM INVALIDO"));
            phases.Tick(Sample(arena+" phase=1 reloj=2"));
            phases.Tick(Sample(arena+" phase=2 reloj=NaN"));
            phases.Tick(Sample(arena+" phase=2 reloj=3"));
            if(phases.Splits!=2) throw new Exception("Gap/NaN recuperado produjo fase tardia");
            phases.Tick(Sample(arena+" phase=3 reloj=4"));
            if(phases.Splits!=3) throw new Exception("Avance valido posterior a gap ausente");
            phases.Tick(Sample(arena.Replace("controller=80","controller=0")+" phase=0 reloj=5"));
            phases.Tick(Sample(arena.Replace("count=4","count=0")+" phase=1 reloj=6"));
            phases.Tick(Sample(arena+" phase=20 reloj=7"));
            phases.Tick(Sample(arena+" phase=0 reloj=8"));
            phases.Tick(Sample(arena+" phase=3 reloj=9"));
            if(phases.Splits!=3) throw new Exception("Puntero/contador invalido o salto multiple dividio");
            output.Add("Fases modo="+phaseMode+" dificultad="+difficulty+": avance unico, filtros, regresion, gaps/NaN, ultima victoria y reloj OK (sintetico)");
        }
        var hitsRunner=new Runner(source,game,false);
        if(hitsRunner.Settings.Settings["hitCounter"].Value) throw new Exception("Counter debe ser opt-in");
        hitsRunner.Settings.Settings["hitCounter"].Value=true;
        hitsRunner.Settings.Settings["practiceMode"].Value=true;
        hitsRunner.Timer.Layout=new LiveSplit.UI.Layout();
        object actualCounter,otherCounter,ambiguousCounter;
        hitsRunner.Timer.Layout.LayoutComponents.Add(new LiveSplit.UI.Components.LayoutComponent("LiveSplit.Counter.dll",CounterComponent("Furi Hits",out actualCounter)));
        hitsRunner.Timer.Layout.LayoutComponents.Add(new LiveSplit.UI.Components.LayoutComponent("LiveSplit.Counter.dll",CounterComponent("Other",out otherCounter)));
        string hitsArena="Global=10 modo=4 partida=20 nivel=LAW modoPartida=4 dificultad=1 | GM=30 estado=4 sub=0 previoFoco=0 final=0 reloj=1 hits=0";
        hitsRunner.Tick(Sample(hitsArena)); hitsRunner.Timer.CurrentPhase=TimerPhase.Running; hitsRunner.Call("onStart",new ExpandoObject());
        foreach(int hits in new[]{1,2,15,15,16,24}) hitsRunner.Tick(Sample(hitsArena.Replace("hits=0","hits="+hits)));
        hitsRunner.Tick(Sample("Global INVALIDO | GM INVALIDO"));
        hitsRunner.Tick(Sample(hitsArena.Replace("LAW","NEMESIS").Replace("GM=30","GM=40").Replace("hits=0","hits=24")));
        hitsRunner.Tick(Sample(hitsArena.Replace("hits=0","hits=-1")));
        hitsRunner.Tick(Sample(hitsArena.Replace("hits=0","hits=2")));
        if((int)((IDictionary<string,object>)hitsRunner.Script.Vars)["hitCount"]!=24) throw new Exception("Hits perdidos por muerte/carga/lectura atrasada");
        if(CounterValue(actualCounter)!=24 || CounterValue(otherCounter)!=0) throw new Exception("Counter real no sincronizado o contador ajeno modificado");
        var ambiguous=new LiveSplit.UI.Components.LayoutComponent("LiveSplit.Counter.dll",CounterComponent("Furi Hits",out ambiguousCounter));
        hitsRunner.Timer.Layout.LayoutComponents.Add(ambiguous);
        hitsRunner.Tick(Sample(hitsArena.Replace("hits=0","hits=25")));
        if(CounterValue(actualCounter)!=24 || CounterValue(ambiguousCounter)!=0) throw new Exception("Contadores ambiguos modificados");
        hitsRunner.Timer.Layout.LayoutComponents.Remove(ambiguous);
        hitsRunner.Settings.Settings["hitCounter"].Value=false;
        hitsRunner.Tick(Sample(hitsArena.Replace("hits=0","hits=30")));
        if(CounterValue(actualCounter)!=24) throw new Exception("Opcion apagada escribio Counter");
        hitsRunner.Settings.Settings["hitCounter"].Value=true;
        hitsRunner.Tick(Sample(hitsArena.Replace("modo=4","modo=2").Replace("modoPartida=4","modoPartida=2").Replace("hits=0","hits=99")));
        if((int)((IDictionary<string,object>)hitsRunner.Script.Vars)["hitCount"]!=25) throw new Exception("Historia actualizo Counter");
        hitsRunner.Tick(Sample(hitsArena.Replace("partida=20","partida=60").Replace("hits=0","hits=0")));
        if((int)((IDictionary<string,object>)hitsRunner.Script.Vars)["hitCount"]!=0) throw new Exception("Nueva Carrera no reinicio hits");
        hitsRunner.Tick(Sample(hitsArena.Replace("modo=4","modo=3").Replace("modoPartida=4","modoPartida=3").Replace("partida=20","partida=70").Replace("hits=0","hits=3")));
        if((int)((IDictionary<string,object>)hitsRunner.Script.Vars)["hitCount"]!=3) throw new Exception("Practica habilitada sin hits");
        hitsRunner.Call("onReset",new ExpandoObject());
        if((int)((IDictionary<string,object>)hitsRunner.Script.Vars)["hitCount"]!=0) throw new Exception("Reset no limpio hits");
        if(CounterValue(actualCounter)!=0 || CounterValue(otherCounter)!=0) throw new Exception("Reset Counter real fallo");
        object koCounter;
        hitsRunner.Timer.Layout.LayoutComponents.Add(new LiveSplit.UI.Components.LayoutComponent("LiveSplit.Counter.dll",CounterComponent("ko:",out koCounter)));
        hitsRunner.Settings.Settings["koCounter"].Value=true;
        string koArena=hitsArena.Replace("partida=20","partida=80").Replace("hits=0","hits=4")+" KO=1";
        hitsRunner.Tick(Sample(koArena));
        if(CounterValue(actualCounter)!=4 || CounterValue(koCounter)!=1 || CounterValue(otherCounter)!=0) throw new Exception("Hits y KO no son independientes");
        hitsRunner.Tick(Sample(koArena.Replace("KO=1","KO=2")));
        hitsRunner.Tick(Sample("Global INVALIDO | GM INVALIDO"));
        hitsRunner.Tick(Sample(koArena));
        if(CounterValue(koCounter)!=2) throw new Exception("KO perdidos por gap/retroceso");
        hitsRunner.Settings.Settings["hitCounter"].Value=false;
        hitsRunner.Tick(Sample(koArena.Replace("hits=4","hits=9").Replace("KO=1","KO=3")));
        if(CounterValue(actualCounter)!=4 || CounterValue(koCounter)!=3) throw new Exception("Opcion KO modifico Hits desactivados");
        hitsRunner.Call("onReset",new ExpandoObject());
        if(CounterValue(koCounter)!=0 || CounterValue(actualCounter)!=4) throw new Exception("Reset KO no respeto opciones independientes");
        hitsRunner.Timer.Layout.LayoutComponents.Clear();
        object defaultCounter;
        hitsRunner.Timer.Layout.LayoutComponents.Add(new LiveSplit.UI.Components.LayoutComponent("LiveSplit.Counter.dll",CounterComponent("Counter",out defaultCounter)));
        hitsRunner.Tick(Sample(koArena.Replace("KO=1","KO=5")));
        if(CounterValue(defaultCounter)!=5) throw new Exception("Counter predeterminado unico no recibe KO");
        hitsRunner.Settings.Settings["hitCounter"].Value=true;
        hitsRunner.Tick(Sample(koArena.Replace("KO=1","KO=6")));
        if(CounterValue(defaultCounter)!=5) throw new Exception("Counter generico ambiguo entre Hits/KO modificado");
        hitsRunner.Settings.Settings["koCounter"].Value=false;
        hitsRunner.Tick(Sample(koArena.Replace("hits=4","hits=10")));
        if(CounterValue(defaultCounter)!=10) throw new Exception("Counter predeterminado unico no recibe Hits");
        output.Add("Hits: acumulado, carga, lecturas invalidas/atrasadas, modos y nueva sesion/reset OK (sintetico)");
        output.Add("Counter: KO independiente, alias, gaps, reset, opciones y Counter predeterminado sin ambiguedad OK (DLL instalada)");
        output.Add(CheckUnsupportedCounter(sourcePath,pid));
        return String.Join(Environment.NewLine,output);
    }
}
