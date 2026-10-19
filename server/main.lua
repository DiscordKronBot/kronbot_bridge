-- kronbot_bridge: links this FiveM server to Kron.
-- Outbound HTTPS only (no port to open): heartbeat, job polling, results, /report.

-- kron_token; dravo_token is the name before 1.3.0, still read so old server.cfg files keep working.
local TOKEN = GetConvar('kron_token', '')
if TOKEN == '' then TOKEN = GetConvar('dravo_token', '') end
local VERSION = GetResourceMetadata(GetCurrentResourceName(), 'version', 0) or '1.0.0'
local framework, adapter = nil, nil
local connected = false

local function debug(...)
  if Config.Debug then print('[kronbot_bridge]', ...) end
end

local function detectFramework()
  if Config.Framework ~= 'auto' then return Config.Framework end
  if GetResourceState('qbx_core') == 'started' then return 'qbox' end
  if GetResourceState('qb-core') == 'started' then return 'qbcore' end
  if GetResourceState('es_extended') == 'started' then return 'esx' end
  return 'none'
end

local function request(method, path, body, cb)
  PerformHttpRequest(Config.ApiUrl .. path, function(status, text)
    local data = nil
    if text and text ~= '' then
      local ok, decoded = pcall(json.decode, text)
      if ok then data = decoded end
    end
    if status == 401 and connected ~= 'bad_token' then
      print(L('bad_token'))
      connected = 'bad_token'
    end
    debug(method, path, status)
    if cb then cb(status, data) end
  end, method, body and json.encode(body) or '', {
    ['Content-Type'] = 'application/json',
    ['Authorization'] = 'Bearer ' .. TOKEN,
  })
end

local function identifier(src, kind)
  local id = GetPlayerIdentifierByType(src, kind)
  if not id then return nil end
  if kind == 'discord' then return id:gsub('^discord:', '') end
  return id
end

local function playerInfo(src)
  return {
    source = tonumber(src),
    name = GetPlayerName(src) or '?',
    discordId = identifier(src, 'discord'),
    license = identifier(src, 'license') or ('unknown:' .. tostring(src)),
  }
end

local function sourceByLicense(license)
  for _, src in ipairs(GetPlayers()) do
    if identifier(src, 'license') == license then return tonumber(src) end
  end
  return nil
end

local function tell(src, author, message)
  TriggerClientEvent('chat:addMessage', src, { color = { 217, 119, 87 }, multiline = true, args = { author, message } })
end

-- ----- Jobs sent by Kron -----
local Jobs = {}

function Jobs.characters(p)
  return adapter.characters(p.license)
end

function Jobs.vehicles(p)
  return adapter.vehicles(p.citizenid)
end

function Jobs.unstuck(p)
  return adapter.unstuck(p.license, p.citizenid)
end

function Jobs.garage(p)
  return adapter.garage(p.citizenid, p.plate)
end

function Jobs.jobs()
  return adapter.jobs()
end

function Jobs.report_reply(p)
  local src = sourceByLicense(p.license)
  if not src then return nil, 'not_found' end
  tell(src, ('Staff · %s'):format(p.staff or 'Kron'), p.message or '')
  return {}
end

function Jobs.report_closed(p)
  local src = sourceByLicense(p.license)
  if src then tell(src, 'Kron', L('closed', tostring(p.id), p.staff or 'staff')) end
  return {}
end

local function runJob(job)
  local handler = Jobs[job.type]
  local ok, result, err
  if not handler then
    ok, err = false, 'unsupported'
  elseif not adapter and job.type ~= 'report_reply' and job.type ~= 'report_closed' then
    ok, err = false, 'unsupported'
  else
    local success, res, handlerErr = pcall(handler, job.payload or {})
    if not success then
      print('[kronbot_bridge] job error:', job.type, res)
      ok, err = false, 'failed'
    elseif res == nil then
      ok, err = false, handlerErr or 'failed'
    else
      ok, result = true, res
    end
  end
  request('POST', '/result', { id = job.id, ok = ok, data = result, error = err })
end

local registerReport

-- ----- Loops -----
local function heartbeat()
  local players = {}
  for _, src in ipairs(GetPlayers()) do players[#players + 1] = playerInfo(src) end
  request('POST', '/hello', {
    version = VERSION,
    framework = framework,
    serverName = GetConvar('sv_projectName', GetConvar('sv_hostname', 'FiveM')):sub(1, 120),
    players = players,
  }, function(status, data)
    if status == 200 and connected ~= true then
      print(L('connected', framework))
      connected = true
    end
    -- /report exists only once the server turns it on in the dashboard, so a
    -- server with its own /report keeps it.
    if status == 200 and data and data.reports then registerReport() end
  end)
end

CreateThread(function()
  if TOKEN == '' then
    print(L('no_token'))
    return
  end
  framework = detectFramework()
  if framework == 'qbcore' or framework == 'qbox' then
    adapter = CreateQbAdapter(framework)
  else
    print(('[kronbot_bridge] Framework "%s" not supported yet: profiles and staff actions are disabled, /report still works.'):format(framework))
  end

  CreateThread(function()
    while true do
      heartbeat()
      Wait(Config.HeartbeatSeconds * 1000)
    end
  end)

  while true do
    Wait(Config.PollSeconds * 1000)
    if connected ~= 'bad_token' then
      request('GET', '/poll', nil, function(status, data)
        if status == 200 and data and data.jobs then
          for _, job in ipairs(data.jobs) do CreateThread(function() runJob(job) end) end
        end
      end)
    end
  end
end)

-- Keep the Discord <-> license link fresh between heartbeats.
AddEventHandler('playerJoining', function()
  if TOKEN ~= '' then request('POST', '/player', { event = 'join', player = playerInfo(source) }) end
end)

AddEventHandler('playerDropped', function()
  if TOKEN ~= '' then request('POST', '/player', { event = 'drop', player = playerInfo(source) }) end
end)

-- ----- /report -----
local lastReport = {}
local reportRegistered = false

-- FiveM cannot unregister a command: once on, turning reports off in the
-- dashboard answers "disabled" until the next restart.
registerReport = function()
  if reportRegistered or not Config.ReportCommand then return end
  reportRegistered = true
  RegisterCommand(Config.ReportCommand, function(src, args)
    if src == 0 then return end
    local message = table.concat(args, ' ')
    if message == '' then
      tell(src, 'Kron', L('usage', Config.ReportCommand))
      return
    end
    local now = os.time()
    if lastReport[src] and now - lastReport[src] < Config.ReportCooldown then
      tell(src, 'Kron', L('cooldown'))
      return
    end
    lastReport[src] = now
    request('POST', '/report', { player = playerInfo(src), message = message:sub(1, 1000) }, function(status, data)
      if status == 200 and data then
        tell(src, 'Kron', data.appended and L('appended') or L('sent'))
      elseif status == 409 then
        tell(src, 'Kron', L('disabled'))
      else
        tell(src, 'Kron', L('failed'))
      end
    end)
  end, false)
end

AddEventHandler('playerDropped', function()
  lastReport[source] = nil
end)
