-- Solo lectura. Busca GlobalGameManager de Carrera y referencias al objeto.
assert(LaunchMonoDataCollector() ~= 0, 'No se pudo activar Mono')
assert(furiRutaModulo and furiRutaModulo.pid == getOpenedProcessID(),
  'Ejecuta ValidarRutaModulo.lua primero en este proceso')
local dominio = furiRutaModulo.dominio
local function metadatos(nombre)
  local clase = mono_findClass('', nombre)
  assert(clase and clase ~= 0, 'Falta clase '..nombre)
  local tabla = mono_class_getVTable(dominio, clase)
  assert(tabla and tabla ~= 0, 'Falta tabla '..nombre)
  local campos = {}
  for _, f in ipairs(mono_class_enumFields(clase) or {}) do
    if not f.isStatic then campos[f.name] = f.offset end
  end
  return tabla, campos
end
local tablaGlobal, g = metadatos('GlobalGameManager')
local tablaDatos, d = metadatos('GameDataInfo')
assert(g._currentGameMode and g._currentGameData and d._gameMode
  and d._gameDifficulty and d._currentLevel, 'Faltan campos')
local function buscar(valor)
  local scan = createMemScan()
  scan.firstScan(soExactValue, vtQword, rtRounded, string.format('%X', valor),
    '', 0, 0x7FFFFFFFFFFF, '', fsmAligned, '8', true, true, false, false)
  scan.waitTillDone()
  local lista = createFoundList(scan)
  lista.initialize()
  local resultado = {}
  for i=0, lista.Count-1 do resultado[#resultado+1] = tonumber(lista[i],16) end
  lista.destroy(); scan.destroy()
  return resultado
end
print('--- REFERENCIAS GLOBAL ACTUAL ---')
local global
for _, obj in ipairs(buscar(tablaGlobal)) do
  if readInteger(obj+g._currentGameMode) == 4 then
    local partida = readPointer(obj+g._currentGameData)
    if partida and partida ~= 0 and readPointer(partida) == tablaDatos
      and readInteger(partida+d._gameMode) == 4 then
      assert(not global, 'Varios globales de Carrera validos: no elegir automaticamente')
      global = obj
      print(string.format('Global=%X | partida=%X | dificultad=%s', obj, partida,
        tostring(readInteger(partida+d._gameDifficulty))))
      local texto = readPointer(partida+d._currentLevel)
      local largo = texto and texto ~= 0 and readInteger(texto+0x10)
      if largo and largo > 0 and largo <= 150 then
        print('Nivel:', readString(texto+0x14,largo*2,true))
      end
    end
  end
end
assert(global, 'No se encontro global de Carrera con partida validada')
furiGlobalReferencias = {pid=getOpenedProcessID(), origen=global,
  dominio=dominio, referencias=buscar(global)}
print(string.format('Offsets global: modo=%X | partida=%X',g._currentGameMode,g._currentGameData))
print('Referencias encontradas:', #furiGlobalReferencias.referencias)
for i, ref in ipairs(furiGlobalReferencias.referencias) do
  if i <= 40 then
    local delta = ref-dominio
    local relativo = delta >= 0 and string.format('+%X',delta) or string.format('-%X',-delta)
    print(string.format('#%d ref=%X | ref menos dominio=%s', i,ref,relativo))
  end
end
if #furiGlobalReferencias.referencias > 40 then print('Solo se muestran las primeras 40') end
print('Referencias candidatas: aun no validadas tras reiniciar proceso.')
print('--- FIN REFERENCIAS GLOBAL ---')
