using System;
using System.Collections.Generic;
using System.IO;
using System.Reflection;
using System.Reflection.Emit;
using System.Text;

public static class FuriIL
{
    public static string Dump(string path, string typeName)
    {
        string dir=Path.GetDirectoryName(path);
        ResolveEventHandler handler=(sender,args)=> {
            foreach(var loaded in AppDomain.CurrentDomain.ReflectionOnlyGetAssemblies())
                if(loaded.FullName==args.Name) return loaded;
            string file=Path.Combine(dir,new AssemblyName(args.Name).Name+".dll");
            return File.Exists(file)?Assembly.ReflectionOnlyLoadFrom(file):Assembly.ReflectionOnlyLoad(args.Name);
        };
        AppDomain.CurrentDomain.ReflectionOnlyAssemblyResolve+=handler;
        try
        {
            var assembly=Assembly.ReflectionOnlyLoadFrom(path);
            var t=assembly.GetType(typeName,true);
            var output=new StringBuilder();
            var ops=new Dictionary<ushort,OpCode>();
            foreach(var f in typeof(OpCodes).GetFields(BindingFlags.Public|BindingFlags.Static))
                if(f.FieldType==typeof(OpCode)) { var op=(OpCode)f.GetValue(null); ops[(ushort)op.Value]=op; }
            foreach(var f in t.GetFields(BindingFlags.Public|BindingFlags.NonPublic|BindingFlags.Instance|BindingFlags.Static))
                output.AppendLine(f.ToString());
            foreach(var m in t.GetMethods(BindingFlags.Public|BindingFlags.NonPublic|BindingFlags.Instance|BindingFlags.Static|BindingFlags.DeclaredOnly))
            {
                output.AppendLine("\nMETHOD "+m.ToString());
                var body=m.GetMethodBody(); if(body==null) continue;
                var il=body.GetILAsByteArray(); int p=0;
                while(p<il.Length)
                {
                    int offset=p; ushort code=il[p++]; if(code==0xfe) code=(ushort)(0xfe00|il[p++]);
                    var op=ops[code]; string value=""; int n=0;
                    switch(op.OperandType)
                    {
                        case OperandType.InlineNone: break;
                        case OperandType.ShortInlineI: case OperandType.ShortInlineVar: n=1; value=il[p].ToString(); break;
                        case OperandType.InlineVar: n=2; value=BitConverter.ToUInt16(il,p).ToString(); break;
                        case OperandType.ShortInlineBrTarget: n=1; value=(p+1+(sbyte)il[p]).ToString("X4"); break;
                        case OperandType.InlineBrTarget: n=4; value=(p+4+BitConverter.ToInt32(il,p)).ToString("X4"); break;
                        case OperandType.ShortInlineR: n=4; value=BitConverter.ToSingle(il,p).ToString("R"); break;
                        case OperandType.InlineR: n=8; value=BitConverter.ToDouble(il,p).ToString("R"); break;
                        case OperandType.InlineI8: n=8; value=BitConverter.ToInt64(il,p).ToString(); break;
                        case OperandType.InlineI: n=4; value=BitConverter.ToInt32(il,p).ToString(); break;
                        case OperandType.InlineSwitch: n=4+4*BitConverter.ToInt32(il,p); value="switch"; break;
                        default:
                            n=4; int token=BitConverter.ToInt32(il,p);
                            try { value=op.OperandType==OperandType.InlineString?m.Module.ResolveString(token):m.Module.ResolveMember(token).ToString(); }
                            catch { value="token "+token.ToString("X8"); }
                            break;
                    }
                    output.AppendLine(String.Format("{0:X4}: {1} {2}",offset,op.Name,value)); p+=n;
                }
            }
            return output.ToString();
        }
        finally { AppDomain.CurrentDomain.ReflectionOnlyAssemblyResolve-=handler; }
    }
}
