fx_version 'cerulean'
games { 'gta5' }
lua54 'yes'

name "Ultimate Lighting Controls"
description "The ultimate non-els lighting controller."
author "Dawnstar"
version "0.1.0"

ui_page "ui/lights.html"

files {
	"ui/lights.html",
	"ui/lights.js",
	"ui/lights.css",
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
	'client/*.lua'
}

server_scripts {
	'server/*.lua'
}

