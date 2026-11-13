fx_version 'cerulean'
games { 'gta5', 'rdr3' }
rdr3_warning 'I acknowledge that this is a prerelease build of RedM, and I am aware my resources *will* become incompatible once RedM ships.'
lua54 'yes'

name 'kronbot_bridge'
author 'Kron (kronbot.xyz)'
description 'Links your FiveM or RedM server to the Kron Discord bot: player profiles in tickets, staff actions, live player board, in-city /report.'
version '1.5.1'

server_scripts {
  '@oxmysql/lib/MySQL.lua',
  'config.lua',
  'server/locale.lua',
  'server/frameworks/qb.lua',
  'server/main.lua',
}

dependency 'oxmysql'
