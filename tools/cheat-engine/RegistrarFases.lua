-- Diagnostico: solo consulta campos Mono. No cambia el juego ni LiveSplit.
-- Ejecutar con una arena cargada. Guarda cambios en local/research/Registros.
if furiMonitor then furiMonitor.destroy(); furiMonitor=nil end
assert(LaunchMonoDataCollector() ~= 0, 'Adjunta Cheat Engine a Furi y activa Mono')
local base=getAddressSafe('mono-2.0-bdwgc.dll')
assert(base and base ~= 0, 'Falta modulo Mono')
local dominio=readPointer(base+0x49AC78)
local encontrado=false
for _,d in ipairs(mono_enumDomains() or {}) do
  if d == dominio then encontrado=true end
end
assert(encontrado, 'La raiz no coincide con Mono; revisar build')
local function tipo(nombre)
  local c=mono_findClass('',nombre)
  assert(c and c ~= 0,'Falta clase '..nombre)
  local t=mono_class_getVTable(dominio,c)
  assert(t and t ~= 0,'Falta tabla '..nombre)
  local campos={}
  for _,f in ipairs(mono_class_enumFields(c,true) or {}) do
    if not f.isStatic then
      campos[f.name]=f.offset
      local p=f.name:match('^<(.+)>k__BackingField$')
      if p then campos[p]=f.offset end
    end
  end
  return {clase=c,tabla=t,campos=campos}
end
local pm=tipo('PawnManager')
local pawn=tipo('AIPawn')
local ctrl=tipo('AIPawnController')
local bfp=tipo('BossFightPhases')
local gm=tipo('GameManager')
local global=tipo('GlobalGameManager')
local data=tipo('GameDataInfo')
local stats=tipo('Statistics')
assert(pm.campos.arenaAIPawn and pawn.campos.aiPawnController
  and ctrl.campos._currentPhaseNumber and ctrl.campos._bfp and bfp.campos.phases,
  'Faltan campos de fases')
local function valido(obj,t)
  return obj and obj ~= 0 and readPointer(obj)==t.tabla
end
local origen=debug.getinfo(1,'S').source
local carpeta=origen:match('^@(.+[\\/])tools[\\/]cheat%-engine[\\/][^\\/]+$')
assert(carpeta,'Cargar mediante dofile con la ruta completa del archivo')
local ruta=carpeta..'local/research/Registros/fases-'..os.date('%Y%m%d-%H%M%S')..'.txt'
local archivo,err=io.open(ruta,'w')
assert(archivo, 'Crear local/research/Registros antes de ejecutar: '..tostring(err))
archivo:close()
local function guardar(linea)
  print(linea)
  local f,e=io.open(ruta,'a')
  assert(f,tostring(e))
  f:write(linea,'\n'); f:close()
end
local pid=getOpenedProcessID()
guardar('PHASE DIAGNOSTIC V3 | PID='..pid)
guardar('Registro: '..ruta)
-- Los estaticos especiales de Mono pueden no residir en el bloque de la clase.
-- Registrar la busqueda antes de resolver, incluso si no encuentra candidatos.
local slots={}
local visto={}
local clase=pm.clase
for profundidad=1,16 do
  if not clase or clase == 0 or visto[clase] then break end
  visto[clase]=true
  local estaticos=mono_class_getStaticFieldAddress(dominio,clase)
  guardar(string.format('class=%X staticBase=%X',clase,estaticos or 0))
  if estaticos and estaticos ~= 0 then
    for _,f in ipairs(mono_class_enumFields(clase,false) or {}) do
      if f.isStatic and not f.isConst then
        local slot=estaticos+f.offset
        local obj=readPointer(slot)
        guardar(string.format('static=%s offset=%X slot=%X value=%X',f.name,f.offset,slot,obj or 0))
        if valido(obj,pm) then slots[slot]=f.name end
      end
    end
  end
  clase=mono_class_getParent(clase)
end
-- Buscar referencias en una zona acotada del dominio, no en todo el heap.
-- Es una ruta candidata de diagnostico, validada por tabla; nunca se distribuye
-- automaticamente como offset del ASL por encontrar una coincidencia.
for pagina=0,0x3F000,0x1000 do
  local bytes=readBytes(dominio+pagina,0x1000,true)
  if bytes and #bytes==0x1000 then
    for offset=0,0xFF8,8 do
      local obj=0
      for i=7,0,-1 do obj=obj*256+bytes[offset+i+1] end
      if obj>=0x10000 and obj<0x800000000000 and obj%8==0 and valido(obj,pm) then
        slots[dominio+pagina+offset]='domain reference'
      end
    end
  end
end
local slot
local objetos={}
for s,nombre in pairs(slots) do
  local obj=readPointer(s)
  guardar(string.format('candidate slot=%X delta=%X object=%X source=%s',s,s-dominio,obj,nombre))
  objetos[obj]=true
  if not slot or s<slot then slot=s end
end
local cantidad=0
for obj in pairs(objetos) do cantidad=cantidad+1 end
if cantidad~=1 then
  guardar('STOPPED: objetos PawnManager encontrados='..cantidad..'; resolucion pendiente')
  error('PawnManager no resuelto; detalle guardado en '..ruta)
end
guardar(string.format('domain=%X pawnManagerSlot=%X domainDelta=%X staticField=%s',
  dominio,slot,slot-dominio,slots[slot]))
guardar(string.format('offsets arenaAIPawn=%X controller=%X phase=%X bfp=%X phases=%X',
  pm.campos.arenaAIPawn,pawn.campos.aiPawnController,ctrl.campos._currentPhaseNumber,
  ctrl.campos._bfp,bfp.campos.phases))
local inicio=getTickCount()
local anterior
local tamanosLista={}
local tiposDerivados={}
local function compatible(obj,t)
  if valido(obj,t) then return true end
  if not obj or obj==0 then return false end
  local tabla=readPointer(obj)
  if not tabla or tabla==0 then return false end
  local clave=string.format('%X:%X',tabla,t.clase)
  if tiposDerivados[clave]~=nil then return tiposDerivados[clave] end
  local actual=mono_object_getClass(obj)
  local clase=actual
  local aceptado=false
  local vistos={}
  if actual and actual~=0 and mono_class_getVTable(dominio,actual)==tabla then
    for profundidad=1,32 do
      if not clase or clase==0 or vistos[clase] then break end
      if clase==t.clase then aceptado=true; break end
      vistos[clase]=true
      clase=mono_class_getParent(clase)
    end
  end
  tiposDerivados[clave]=aceptado
  guardar(string.format('object=%X table=%X actualClass=%s expectedClass=%s compatible=%s',
    obj,tabla,actual and actual~=0 and mono_class_getName(actual) or '(unknown)',
    mono_class_getName(t.clase),tostring(aceptado)))
  return aceptado
end
local function muestra()
  assert(getOpenedProcessID()==pid,'Cambio el proceso adjunto')
  assert(readPointer(base+0x49AC78)==dominio,'Cambio el dominio')
  local p=readPointer(slot)
  local a=valido(p,pm) and readPointer(p+pm.campos.arenaAIPawn) or nil
  local c=valido(a,pawn) and readPointer(a+pawn.campos.aiPawnController) or nil
  local fase=compatible(c,ctrl) and readInteger(c+ctrl.campos._currentPhaseNumber) or nil
  local fases=compatible(c,ctrl) and readPointer(c+ctrl.campos._bfp) or nil
  local lista=compatible(fases,bfp) and readPointer(fases+bfp.campos.phases) or nil
  local total
  if lista and lista ~= 0 then
    local tabla=readPointer(lista)
    if tabla and tabla ~= 0 and not tamanosLista[tabla] then
      local lc=mono_object_getClass(lista)
      for _,f in ipairs(lc and mono_class_enumFields(lc,true) or {}) do
        if f.name=='_size' and not f.isStatic then
          tamanosLista[tabla]=f.offset
          guardar(string.format('phaseList=%X table=%X sizeOffset=%X',lista,tabla,f.offset))
        end
      end
    end
    if tamanosLista[tabla] then total=readInteger(lista+tamanosLista[tabla]) end
  end
  local g=readPointer(dominio+0x1EF48)
  -- Las rutas existentes se corroboran por clase en cada muestra.
  local d=valido(g,global) and readPointer(g+0x40) or nil
  local nombre='(invalid)'
  local modo,dificultad,tiempo
  if valido(d,data) then
    modo=readInteger(d+0x44); dificultad=readInteger(d+0x40)
    local s=readPointer(d+0x10)
    local n=s and s ~= 0 and readInteger(s+0x10) or nil
    if n and n>0 and n<=32 then nombre=readString(s+0x14,n*2,true) or nombre end
    local st=readPointer(d+0x28)
    if valido(st,stats) then tiempo=readFloat(st+0x20) end
  end
  local m=readPointer(dominio+0x1ED08)
  local estado,sub,fin
  if valido(m,gm) then
    estado=readInteger(m+0x64); sub=readInteger(m+0x70); fin=readBytes(m+0x7B,1)
  end
  local texto=string.format('data=%X level=%s mode=%s difficulty=%s GM=%X state=%s sub=%s ended=%s PM=%X pawn=%X controller=%X phase=%s count=%s',
    d or 0,nombre,tostring(modo),tostring(dificultad),m or 0,tostring(estado),
    tostring(sub),tostring(fin),p or 0,a or 0,c or 0,tostring(fase),tostring(total))
  if texto~=anterior then
    anterior=texto
    guardar(string.format('[%.3fs] %s gameTime=%s',(getTickCount()-inicio)/1000,texto,tostring(tiempo)))
  end
end
muestra()
furiMonitor=createTimer(nil,false)
furiMonitor.Interval=50
furiMonitor.OnTimer=function(t)
  local ok,e=pcall(muestra)
  if not ok then t.Enabled=false; guardar('STOPPED: '..tostring(e)) end
end
furiMonitor.Enabled=true
print('Registro:',ruta)
print('Detener: furiMonitor.destroy(); furiMonitor=nil')
