fx_version 'cerulean'
game 'gta5'
lua54 'yes'

name 'dravo_bridge'
author 'Dravo (dravo.run)'
description 'Links your FiveM server to the Dravo Discord bot: player profiles in tickets, staff actions, in-city /report.'
version '1.0.0'

server_scripts {
  '@oxmysql/lib/MySQL.lua',
  'config.lua',
  'server/locale.lua',
  'server/frameworks/qb.lua',
  'server/main.lua',
}

dependency 'oxmysql'
