-- Solo lectura: impactos registrados por el juego, sin controlar LiveSplit.
if furiMonitor then furiMonitor.destroy(); furiMonitor=nil end
assert(LaunchMonoDataCollector()~=0,'Adjunta Cheat Engine a Furi')
local base=getAddressSafe('mono-2.0-bdwgc.dll')
assert(base and base~=0,'Falta Mono')
local dominio=readPointer(base+0x49AC78)
local coincide=false
for _,d in ipairs(mono_enumDomains() or {}) do if d==dominio then coincide=true end end
assert(coincide,'Dominio no coincide; revisar build')
local function tipo(nombre)
  local c=mono_findClass('',nombre)
  assert(c and c~=0,'Falta clase '..nombre)
  local t=mono_class_getVTable(dominio,c)
  assert(t and t~=0,'Falta tabla '..nombre)
  local campos={}
  for _,f in ipairs(mono_class_enumFields(c,true) or {}) do
    if not f.isStatic then campos[f.name]=f.offset end
  end
  return {tabla=t,campos=campos}
end
local g=tipo('GlobalGameManager')
local d=tipo('GameDataInfo')
local s=tipo('Statistics')
local m=tipo('GameManager')
assert(s.campos._hits and s.campos._KO and s.campos._time,'Faltan campos Statistics')
assert(g.campos._currentGameData and d.campos._currentStatistics,'Faltan campos de partida')
local origen=debug.getinfo(1,'S').source
local carpeta=origen:match('^@(.+[\\/])tools[\\/]cheat%-engine[\\/][^\\/]+$')
assert(carpeta,'Ejecutar mediante dofile con ruta completa')
local ruta=carpeta..'local/research/Registros/impactos-'..os.date('%Y%m%d-%H%M%S')..'.txt'
local archivo,err=io.open(ruta,'w'); assert(archivo,tostring(err)); archivo:close()
local function guardar(texto)
  print(texto)
  local f,e=io.open(ruta,'a'); assert(f,tostring(e)); f:write(texto,'\n'); f:close()
end
local function valido(obj,t) return obj and obj~=0 and readPointer(obj)==t.tabla end
local pid=getOpenedProcessID()
guardar('HIT DIAGNOSTIC V1 | PID='..pid)
guardar('Registro: '..ruta)
guardar(string.format('offsets data=%X statistics=%X hits=%X KO=%X time=%X',
  g.campos._currentGameData,d.campos._currentStatistics,s.campos._hits,s.campos._KO,s.campos._time))
local inicio=getTickCount()
local anterior
local function muestra()
  assert(getOpenedProcessID()==pid and readPointer(base+0x49AC78)==dominio,'Cambio proceso/dominio')
  local global=readPointer(dominio+0x1EF48)
  local data=valido(global,g) and readPointer(global+g.campos._currentGameData) or nil
  local stats=valido(data,d) and readPointer(data+d.campos._currentStatistics) or nil
  local hits,ko,time,modo,dificultad,startHits
  local nivel='(invalid)'
  if valido(data,d) then
    modo=readInteger(data+0x44); dificultad=readInteger(data+0x40)
    local str=readPointer(data+0x10)
    local n=str and str~=0 and readInteger(str+0x10) or nil
    if n and n>0 and n<=32 then nivel=readString(str+0x14,n*2,true) or nivel end
    if d.campos._startLevelStatistics then
      local st=readPointer(data+d.campos._startLevelStatistics)
      if valido(st,s) then startHits=readInteger(st+s.campos._hits) end
    end
  end
  if valido(stats,s) then
    hits=readInteger(stats+s.campos._hits); ko=readInteger(stats+s.campos._KO)
    time=readFloat(stats+s.campos._time)
  end
  local gm=readPointer(dominio+0x1ED08)
  local state,sub,ended
  if valido(gm,m) then state=readInteger(gm+0x64); sub=readInteger(gm+0x70); ended=readBytes(gm+0x7B,1) end
  local texto=string.format('data=%X level=%s mode=%s difficulty=%s statistics=%X hits=%s startHits=%s KO=%s GM=%X state=%s sub=%s ended=%s',
    data or 0,nivel,tostring(modo),tostring(dificultad),stats or 0,tostring(hits),tostring(startHits),
    tostring(ko),gm or 0,tostring(state),tostring(sub),tostring(ended))
  if texto~=anterior then
    anterior=texto
    guardar(string.format('[%.3fs] %s gameTime=%s',(getTickCount()-inicio)/1000,texto,tostring(time)))
  end
end
muestra()
furiMonitor=createTimer(nil,false); furiMonitor.Interval=50
furiMonitor.OnTimer=function(t)
  local ok,e=pcall(muestra)
  if not ok then t.Enabled=false; guardar('STOPPED: '..tostring(e)) end
end
furiMonitor.Enabled=true
print('Monitor activo. Detener: furiMonitor.destroy(); furiMonitor=nil')
