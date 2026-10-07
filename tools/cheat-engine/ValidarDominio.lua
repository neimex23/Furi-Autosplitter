-- Solo lectura. Prueba la HIPOTESIS dominio Mono + 0x1ED08 en proceso actual.
-- No usa direcciones absolutas ni candidatos guardados de sesiones anteriores.
if furiMonitor then furiMonitor.destroy(); furiMonitor=nil end
assert(LaunchMonoDataCollector() ~= 0, 'No se pudo activar Mono: adjunta CE al Furi actual')
local clase = mono_findClass('', 'GameManager')
assert(clase and clase ~= 0, 'No se encontro GameManager')
local campos = {}
for _, f in ipairs(mono_class_enumFields(clase) or {}) do
  if not f.isStatic then
    campos[f.name] = f.offset
    local propiedad = f.name:match('^<(.+)>k__BackingField$')
    if propiedad then campos[propiedad] = f.offset end
  end
end
assert(campos._gameState and campos._gameSubState and campos.endGameTriggered,
  'Faltan campos GameManager')
local dominios = mono_enumDomains() or {}
assert(#dominios > 0, 'No hay dominios Mono')
local tablas = {}
for _, dominio in ipairs(dominios) do
  local tabla = mono_class_getVTable(dominio, clase)
  if tabla and tabla ~= 0 then tablas[tabla] = true end
end
assert(next(tablas), 'No se obtuvo tabla de clase')
print('--- VALIDAR DOMINIO + 1ED08 (HIPOTESIS) ---')
print('PID:', getOpenedProcessID())
furiAnclajePrueba = {pid=getOpenedProcessID(), referencias={}}
for _, dominio in ipairs(dominios) do
  local ref = dominio+0x1ED08
  local obj = readPointer(ref)
  local tabla = obj and obj ~= 0 and readPointer(obj)
  print(string.format('Dominio=%X | ref=%X | contenido=%X', dominio, ref, obj or 0))
  if tabla and tablas[tabla] then
    local estado = readInteger(obj+campos._gameState)
    local sub = readInteger(obj+campos._gameSubState)
    local final = readBytes(obj+campos.endGameTriggered,1)
    if estado and estado >= 0 and estado <= 17 and sub and sub >= 0 and sub <= 9
      and (final == 0 or final == 1) then
      furiAnclajePrueba.referencias[#furiAnclajePrueba.referencias+1] = ref
      print(string.format('  CLASE Y CAMPOS VALIDOS: GM=%X | estado=%d | sub=%d | final=%d',
        obj, estado, sub, final))
    else
      print('  Clase coincide, pero campos fuera de rango: descartar muestra')
    end
  else
    print('  SIN GAMEMANAGER VALIDADO (en menu puede ser normal)')
  end
end
print('Referencias validadas:', #furiAnclajePrueba.referencias)
print('--- FIN VALIDAR DOMINIO ---')
