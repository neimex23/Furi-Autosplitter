-- Solo lectura. Monitor conjunto mediante rutas desde modulo, sin escaneos.
if furiMonitor then furiMonitor.destroy(); furiMonitor=nil end
assert(LaunchMonoDataCollector() ~= 0, 'No se pudo activar Mono')
local base=getAddressSafe('mono-2.0-bdwgc.dll') or getAddressSafe('mono-2.0-bdwgc')
assert(base and base ~= 0,'Falta modulo Mono')
local dominio=readPointer(base+0x49AC78)
local coincide=false
for _, actual in ipairs(mono_enumDomains() or {}) do
  if actual == dominio then coincide=true end
end
assert(coincide,'Dominio no coincide: revisar version/ruta')
local function tabla(nombre)
  local clase=mono_findClass('',nombre)
  assert(clase and clase ~= 0,'Falta clase '..nombre)
  local t=mono_class_getVTable(dominio,clase)
  assert(t and t ~= 0,'Falta tabla '..nombre)
  return t, clase
end
local tg, claseGlobal=tabla('GlobalGameManager')
local tm=tabla('GameManager')
local td=tabla('GameDataInfo')
local ts=tabla('Statistics')
local camposGlobal={}
for _,f in ipairs(mono_class_enumFields(claseGlobal) or {}) do
  if not f.isStatic then camposGlobal[f.name]=f.offset end
end
local pid=getOpenedProcessID()
local inicio=getTickCount()
local anterior
furiRutasRegistro={}
local function nivel(obj)
  local p=readPointer(obj+0x10)
  if not p or p == 0 then return '(nulo)' end
  local n=readInteger(p+0x10)
  if not n or n < 0 or n > 150 then return '(ilegible)' end
  return n == 0 and '(vacio)' or (readString(p+0x14,n*2,true) or '(ilegible)')
end
local function muestra()
  assert(getOpenedProcessID() == pid,'Cambio el proceso adjunto')
  local texto='DOMINIO INVALIDO'
  local reloj=''
  if readPointer(base+0x49AC78) == dominio then
    local global=readPointer(dominio+0x1EF48)
    texto='Global INVALIDO'
    if global and global ~= 0 and readPointer(global) == tg then
      local datos=readPointer(global+0x40)
      texto=string.format('Global=%X modo=%s partida=%X',global,
        tostring(readInteger(global+0xB8)),datos or 0)
      if camposGlobal._gameState then
        texto=texto..' estadoGlobal='..tostring(readInteger(global+camposGlobal._gameState))
      end
      if camposGlobal._loadingState then
        texto=texto..' cargaGlobal='..tostring(readInteger(global+camposGlobal._loadingState))
      end
      if datos and datos ~= 0 and readPointer(datos) == td then
        texto=texto..string.format(' nivel=%s modoPartida=%s dificultad=%s',nivel(datos),
          tostring(readInteger(datos+0x44)),tostring(readInteger(datos+0x40)))
        local stats=readPointer(datos+0x28)
        if stats and stats ~= 0 and readPointer(stats)==ts then
          reloj=string.format(' | estadisticas=%X gameTime=%s',stats,tostring(readFloat(stats+0x20)))
        end
      else
        texto=texto..' partida NO VALIDADA'
      end
    end
    local gm=readPointer(dominio+0x1ED08)
    if gm and gm ~= 0 and readPointer(gm) == tm then
      texto=texto..string.format(' | GM=%X estado=%s sub=%s previoFoco=%s previoPausa=%s final=%s',
        gm,tostring(readInteger(gm+0x64)),tostring(readInteger(gm+0x70)),
        tostring(readInteger(gm+0x6C)),tostring(readInteger(gm+0x68)),
        tostring(readBytes(gm+0x7B,1)))
      local c=readPointer(gm+0x38)
      if c and c ~= 0 then
        reloj=reloj..string.format(' | chrono=%X inicio=%s inicial=%s pausaDesde=%s pausaAcum=%s pausado=%s',
          c,tostring(readFloat(c+0x50)),tostring(readFloat(c+0x54)),
          tostring(readFloat(c+0x5C)),tostring(readFloat(c+0x60)),tostring(readBytes(c+0x5A,1)))
      else
        reloj=reloj..' | chrono no disponible'
      end
    else
      texto=texto..' | GM INVALIDO'
    end
  end
  if texto ~= anterior then
    anterior=texto
    local linea=string.format('[%.2fs] %s%s',(getTickCount()-inicio)/1000,texto,reloj)
    furiRutasRegistro[#furiRutasRegistro+1]=linea
    print(linea)
  end
end
print('--- MONITOR DE RUTAS V2: estado global, partida, GM y Game Time, cada 100 ms ---')
muestra()
furiMonitor=createTimer(nil,false)
furiMonitor.Interval=100
furiMonitor.OnTimer=function(t)
  local ok,err=pcall(muestra)
  if not ok then t.Enabled=false; print('MONITOR DETENIDO:',tostring(err)) end
end
furiMonitor.Enabled=true
print('Monitor activo. Detener: furiMonitor.destroy(); furiMonitor=nil')
