-- Diagnostico de esta sesion. NO es un autosplitter ni modifica el juego.
-- Usa referencias guardadas del proceso actual, sin direcciones antiguas.
-- Para detener: ejecutar furiMonitor.destroy(); furiMonitor=nil
if furiMonitor then furiMonitor.destroy(); furiMonitor=nil end
assert(LaunchMonoDataCollector() ~= 0, 'No se pudo activar Mono')
local clase = mono_findClass('', 'GameManager')
assert(clase and clase ~= 0, 'No se encontro GameManager')
local tablas = {}
for _, dominio in ipairs(mono_enumDomains() or {}) do
  local tabla = mono_class_getVTable(dominio, clase)
  if tabla and tabla ~= 0 then tablas[tabla] = true end
end
assert(next(tablas), 'No se obtuvo la tabla de GameManager')
assert(furiReferenciasPID == getOpenedProcessID() and furiReferencias,
  'Faltan referencias del proceso actual')
local referencia
for _, candidata in ipairs(furiReferencias) do
  local objeto = readPointer(candidata)
  local tabla = objeto and objeto ~= 0 and readPointer(objeto)
  if tabla and tablas[tabla] and readInteger(objeto+0x64) == 4 then
    assert(not referencia, 'Varias referencias de arena: falta compararlas tras cambiar escena')
    referencia = candidata
  end
end
assert(referencia, 'Ninguna referencia apunta a arena: ejecutar en el jefe')
local pid = getOpenedProcessID()
local anterior
local inicio = getTickCount()
furiRegistro = furiRegistro or {}
local function muestra()
  assert(getOpenedProcessID() == pid, 'Cambio el proceso adjunto')
  local gm = readPointer(referencia)
  local tabla = gm and gm ~= 0 and readPointer(gm)
  local texto = 'SIN REFERENCIA VALIDA (posible carga)'
  if tabla and tablas[tabla] then
    texto = string.format('GM=%X | estado=%s | sub=%s | previoFoco=%s | previoPausa=%s | final=%s',
      gm, tostring(readInteger(gm+0x64)), tostring(readInteger(gm+0x70)),
      tostring(readInteger(gm+0x6C)), tostring(readInteger(gm+0x68)),
      tostring(readBytes(gm+0x7B,1)))
  end
  if texto ~= anterior then
    anterior = texto
    local reloj = ''
    if tabla and tablas[tabla] then
      local chrono = readPointer(gm+0x38)
      if chrono and chrono ~= 0 then
        reloj = string.format(' | chrono=%X | inicio=%s | inicial=%s | pausaDesde=%s | pausaAcum=%s | pausado=%s | inicioJefe=%s | inicioSesion=%s',
          chrono, tostring(readFloat(chrono+0x50)), tostring(readFloat(chrono+0x54)),
          tostring(readFloat(chrono+0x5C)), tostring(readFloat(chrono+0x60)),
          tostring(readBytes(chrono+0x5A,1)), tostring(readFloat(gm+0x84)),
          tostring(readFloat(gm+0x88)))
      else
        reloj = ' | chrono=no disponible'
      end
    end
    local linea = string.format('[%.2fs] %s%s', (getTickCount()-inicio)/1000, texto, reloj)
    furiRegistro[#furiRegistro+1] = linea
    print(linea)
  end
end
print(string.format('Referencia seleccionada de esta sesion: %X', referencia))
print('--- MONITOR V3 INICIADO (estados y reloj, cada 100 ms) ---')
muestra()
furiMonitor = createTimer(nil, false)
furiMonitor.Interval = 100
furiMonitor.OnTimer = function(t)
  local ok, err = pcall(muestra)
  if not ok then
    t.Enabled = false
    print('MONITOR DETENIDO POR ERROR:', tostring(err))
  end
end
furiMonitor.Enabled = true
