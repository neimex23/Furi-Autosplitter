-- Solo lectura: tiempo acumulado que ScoreManager.Update copia de GameTime.
assert(LaunchMonoDataCollector() ~= 0,'No se pudo activar Mono')
local base=getAddressSafe('mono-2.0-bdwgc.dll') or getAddressSafe('mono-2.0-bdwgc')
assert(base and base ~= 0,'Falta modulo Mono')
local dominio=readPointer(base+0x49AC78)
assert(dominio and dominio ~= 0,'Falta dominio')
local function validar(obj,nombre)
  assert(obj and obj ~= 0,'Sin objeto '..nombre)
  local clase=mono_findClass('',nombre)
  assert(clase and clase ~= 0,'Falta clase '..nombre)
  local tabla=mono_class_getVTable(dominio,clase)
  assert(tabla and tabla ~= 0 and readPointer(obj)==tabla,'Clase distinta de '..nombre)
  local campos={}
  for _,f in ipairs(mono_class_enumFields(clase) or {}) do
    if not f.isStatic then campos[f.name]=f.offset end
  end
  return campos
end
print('--- TIEMPO DE ESTADISTICAS ---')
local global=readPointer(dominio+0x1EF48)
local g=validar(global,'GlobalGameManager')
assert(g._currentGameData,'Falta _currentGameData')
local partida=readPointer(global+g._currentGameData)
local d=validar(partida,'GameDataInfo')
assert(d._currentStatistics,'Falta _currentStatistics')
local stats=readPointer(partida+d._currentStatistics)
local s=validar(stats,'Statistics')
assert(s._time,'Falta _time')
print(string.format('Offset partida._currentStatistics=%X | Statistics._time=%X',d._currentStatistics,s._time))
print(string.format('Global=%X | partida=%X | estadisticas=%X',global,partida,stats))
print('Tiempo acumulado (segundos):',readFloat(stats+s._time))
local gm=readPointer(dominio+0x1ED08)
local m=validar(gm,'GameManager')
assert(m._gameChrono,'Falta _gameChrono')
local chrono=readPointer(gm+m._gameChrono)
if chrono and chrono ~= 0 then
  local c=validar(chrono,'Chrono')
  print(string.format('Chrono=%X | modo=%s | dependenciaEscala=%s | pausado=%s',chrono,
    tostring(readInteger(chrono+c._mode)),tostring(readBytes(chrono+c._timeScaleDependent,1)),
    tostring(readBytes(chrono+c._paused,1))))
  local inicial=readFloat(chrono+c._initialTime)
  local pausa=readFloat(chrono+c._startPausedTime)
  local inicio=readFloat(chrono+c._startTime)
  local acumulada=readFloat(chrono+c._countPausedTime)
  if inicial and pausa and inicio and acumulada then
    print('Chrono si pausado/terminado (segundos):',inicial+pausa-inicio-acumulada)
  end
end
print('--- FIN TIEMPO ESTADISTICAS ---')
