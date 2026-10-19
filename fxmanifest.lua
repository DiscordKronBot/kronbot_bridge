fx_version 'cerulean'
game 'gta5'
lua54 'yes'

name 'kronbot_bridge'
author 'Kron (kronbot.xyz)'
description 'Links your FiveM server to the Kron Discord bot: player profiles in tickets, staff actions, live player board, in-city /report.'
version '1.4.0'

server_scripts {
  '@oxmysql/lib/MySQL.lua',
  'config.lua',
  'server/locale.lua',
  'server/frameworks/qb.lua',
  'server/main.lua',
}

dependency 'oxmysql'
