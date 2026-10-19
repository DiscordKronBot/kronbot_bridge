Config = {}

-- The token is NOT set here: put it in server.cfg ->  set kron_token "kron_..."
Config.ApiUrl = 'https://kronbot.xyz/api/bridge'

-- 'auto' detects qbx_core (Qbox) or qb-core (QBCore). ESX support is coming.
Config.Framework = 'auto'

-- Language of the messages players see in game: 'fr' or 'en'
Config.Locale = 'fr'

-- How often the resource talks to Kron (seconds)
Config.HeartbeatSeconds = 30
Config.PollSeconds = 3

-- In-city report command (/report <message>) and per-player cooldown (seconds).
-- Registered only when reports are on in the Kron dashboard; false = never.
Config.ReportCommand = 'report'
Config.ReportCooldown = 15

-- "Unstuck" sends the character here (x, y, z, heading). Default: Legion Square.
Config.UnstuckCoords = vector4(215.76, -810.12, 30.73, 160.0)

-- Garage used when a returned vehicle has none recorded
Config.DefaultGarage = 'pillboxgarage'

-- Prints requests and errors in the server console
Config.Debug = false
