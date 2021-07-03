fx_version 'bodacious'
game 'gta5'
description 'ESX Database Insert - Easily insert vehicles & trailers to database'
author 'Abel Gaming'
version '1.0'

server_scripts {
	'@mysql-async/lib/MySQL.lua',
	'config.lua',
	'server/main.lua'
}

client_scripts {
	'config.lua',
	'client/main.lua'
}
