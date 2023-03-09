fx_version 'cerulean'
games { 'gta5' }
lua54 'yes'

name "Ultimate Lighting Controls"
description "The ultimate non-els lighting controller. Documentation: https://docs.dwnstr.com/ulc/overview"
author "Dawnstar"
version "1.5.0"

ui_page "html/index.html"

files {
	"ui/lights.html",
	"ui/lights.js",
	"ui/lights.css",
	"html/index.html",
	"html/assets/*.js",
	"html/assets/*.css",
	"html/assets/*.png",
	"html/assets/*.jpg"
}

dependencies {
	"baseevents"
}

shared_scripts {
	'config.lua',
	'shared/shared_functions.lua'
}

client_scripts {
	'client/c_main.lua',
	'client/c_hud.lua',
	'client/c_buttons.lua',
	'client/c_brake.lua',
	'client/c_cruise.lua',
	'client/c_horn.lua',
	'client/c_park.lua',
	'client/c_reverse.lua',
	'client/c_beeps.lua'
}

server_scripts {
	'server/s_main.lua',
	'server/s_main.js'
}

