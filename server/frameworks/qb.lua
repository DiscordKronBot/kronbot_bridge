-- QBCore and Qbox share the same database tables (players, player_vehicles).
-- Only the way to reach an online player differs.

local function decode(v)
  if type(v) == 'table' then return v end
  if type(v) ~= 'string' or v == '' then return {} end
  local ok, data = pcall(json.decode, v)
  return ok and data or {}
end

local function trim(s)
  return (s or ''):gsub('^%s+', ''):gsub('%s+$', '')
end

--- Jobs and gangs defined on the server (QBCore shared tables, Qbox exports).
local function sharedLists(kind)
  if kind == 'qbox' then
    return exports.qbx_core:GetJobs() or {}, exports.qbx_core:GetGangs() or {}
  end
  local QBCore = exports['qb-core']:GetCoreObject()
  return QBCore.Shared.Jobs or {}, QBCore.Shared.Gangs or {}
end

local function getPlayerFn(kind)
  if kind == 'qbox' then
    return function(citizenid) return exports.qbx_core:GetPlayerByCitizenId(citizenid) end
  end
  local QBCore = exports['qb-core']:GetCoreObject()
  return function(citizenid) return QBCore.Functions.GetPlayerByCitizenId(citizenid) end
end

function CreateQbAdapter(kind)
  local getPlayer = getPlayerFn(kind)
  local adapter = {}

  --- Characters of a license (live money when the character is online).
  function adapter.characters(license)
    local rows = MySQL.query.await('SELECT citizenid, charinfo, job, money FROM players WHERE license = ?', { license }) or {}
    local list = {}
    for _, row in ipairs(rows) do
      local charinfo, job, money = decode(row.charinfo), decode(row.job), decode(row.money)
      local player = getPlayer(row.citizenid)
      if player then money = player.PlayerData.money or money end
      local jobLabel = job.label
      if jobLabel and job.grade and job.grade.name then jobLabel = ('%s · %s'):format(jobLabel, job.grade.name) end
      list[#list + 1] = {
        citizenid = row.citizenid,
        name = trim(('%s %s'):format(charinfo.firstname or '', charinfo.lastname or '')),
        job = jobLabel,
        phone = charinfo.phone,
        cash = money.cash or 0,
        bank = money.bank or 0,
        online = player ~= nil,
      }
    end
    return { characters = list }
  end

  function adapter.vehicles(citizenid)
    local rows = MySQL.query.await('SELECT plate, vehicle, state, garage FROM player_vehicles WHERE citizenid = ?', { citizenid }) or {}
    local list = {}
    for _, row in ipairs(rows) do
      list[#list + 1] = { plate = trim(row.plate), model = row.vehicle, state = tonumber(row.state) or 0, garage = row.garage }
    end
    return { vehicles = list }
  end

  --- Online: teleport now. Offline: rewrite the saved position.
  function adapter.unstuck(license, citizenid)
    local c = Config.UnstuckCoords
    local player = getPlayer(citizenid)
    if player then
      if player.PlayerData.license ~= license then return nil, 'not_found' end
      local ped = GetPlayerPed(player.PlayerData.source)
      SetEntityCoords(ped, c.x, c.y, c.z, false, false, false, false)
      SetEntityHeading(ped, c.w)
      TriggerClientEvent('chat:addMessage', player.PlayerData.source, { color = { 217, 119, 87 }, args = { 'Kron', L('unstuck') } })
      return { mode = 'online' }
    end
    local changed = MySQL.update.await('UPDATE players SET position = ? WHERE citizenid = ? AND license = ?', {
      json.encode({ x = c.x, y = c.y, z = c.z, w = c.w }),
      citizenid,
      license,
    })
    if not changed or changed == 0 then return nil, 'not_found' end
    return { mode = 'offline' }
  end

  --- Despawn the vehicle if it is out, then mark it as stored.
  function adapter.garage(citizenid, plate)
    local row = MySQL.single.await('SELECT plate, garage FROM player_vehicles WHERE citizenid = ? AND plate = ?', { citizenid, plate })
    if not row then return nil, 'not_found' end
    for _, veh in ipairs(GetAllVehicles()) do
      if trim(GetVehicleNumberPlateText(veh)) == trim(plate) then DeleteEntity(veh) end
    end
    MySQL.update.await('UPDATE player_vehicles SET state = 1, garage = ? WHERE citizenid = ? AND plate = ?', {
      row.garage or Config.DefaultGarage,
      citizenid,
      plate,
    })
    local player = getPlayer(citizenid)
    if player then
      TriggerClientEvent('chat:addMessage', player.PlayerData.source, { color = { 217, 119, 87 }, args = { 'Kron', L('garage', trim(plate)) } })
    end
    return {}
  end

  --- Jobs and gangs (name, label, type), without the "nobody" entries.
  function adapter.jobs()
    local jobs, gangs = sharedLists(kind)
    local out = { jobs = {}, gangs = {} }
    for name, job in pairs(jobs) do
      if name ~= 'unemployed' then out.jobs[#out.jobs + 1] = { name = name, label = job.label or name, type = job.type } end
    end
    for name, gang in pairs(gangs) do
      if name ~= 'none' then out.gangs[#out.gangs + 1] = { name = name, label = gang.label or name } end
    end
    return out
  end

  return adapter
end
