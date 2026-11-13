Config = {}

-- The token is NOT set here: put it in server.cfg ->  set kron_token "kron_..."
Config.ApiUrl = 'https://kronbot.xyz/api/bridge'
-- Some hosts' FXServer cannot open kronbot.xyz (HTTP status 0) while dravo.run, the same API, works.
-- When the first address fails like that, the resource switches to this one by itself. false = never.
Config.ApiUrlFallback = 'https://dravo.run/api/bridge'

-- 'auto' detects qbx_core (Qbox) or qb-core (QBCore) on FiveM, rsg-core (RSG-Core) on RedM.
-- ESX and VORP support is coming.
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

-- "Unstuck" sends the character here (x, y, z, heading). FiveM default: Legion Square.
Config.UnstuckCoords = vector4(215.76, -810.12, 30.73, 160.0)
-- Same on RedM. Default: Valentine (rsg-core's first spawn): change it to your own safe spot.
Config.UnstuckCoordsRedM = vector4(-169.47, 629.38, 114.03, 236.79)

-- Garage used when a returned vehicle has none recorded (FiveM only)
Config.DefaultGarage = 'pillboxgarage'

-- Prints requests and errors in the server console
Config.Debug = false
