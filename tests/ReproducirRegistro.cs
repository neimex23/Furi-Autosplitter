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
    private static string Field(string line,string key)
    { var m=Regex.Match(line,@"\b"+key+@"=([^\s|]+)"); return m.Success?m.Groups[1].Value:null; }
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
        var finalBoss=new Runner(source,game,false);
        finalBoss.Tick(Sample(combat.Replace("LAW","MOTHERSHIP")));
        finalBoss.Timer.CurrentPhase=TimerPhase.Running;
        finalBoss.Tick(Sample(results.Replace("LAW","MOTHERSHIP")+" reloj=217.30"));
        finalBoss.Tick(Sample(results.Replace("LAW","MOTHERSHIP").Replace("estado=4","estado=17")+" reloj=217.30"));
        if(finalBoss.Splits!=0) throw new Exception("Se genero cierre automatico no validado");
        output.Add("Ultimo jefe/ranking: cierre manual, sin split automatico supuesto OK");
        return String.Join(Environment.NewLine,output);
    }
}
