fx_version 'cerulean'
games { 'gta5' }
lua54 'yes'

name "Ultimate Lighting Controls"
description "The ultimate non-els lighting controller. Documentation: https://docs.dwnstr.com/ulc/overview"
author "Dawnstar"
version "1.2.0"

ui_page "ui/lights.html"

files {
	"ui/lights.html",
	"ui/lights.js",
	"ui/lights.css",
}

dependencies {
	"baseevents"
}

escrow_ignore {
	'config.lua',
	"ui/*"
}

shared_scripts {
	'config.lua',
	'shared/*.lua'
}

client_scripts {
	'client/c_main.lua',
	'client/c_brake.lua',
	'client/c_cruise.lua',
	'client/c_horn.lua',
	'client/c_park.lua',
	'client/c_reverse.lua',
	'client/c_beeps.lua'

}

server_scripts {
	'server/s_main.lua'
}

