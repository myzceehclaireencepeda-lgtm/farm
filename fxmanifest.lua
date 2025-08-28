fx_version 'cerulean'
game 'gta5'

name 'qbx_truckerjob'
description 'Enhanced Trucker Job System with Modern NUI'
author 'QBX Development'
version '2.0.0'

shared_scripts {
    '@ox_lib/init.lua',
    'config/shared.lua'
}

client_scripts {
    'config/client.lua',
    'client/main.lua'
}

server_scripts {
    'config/server.lua',
    'server/main.lua'
}

ui_page 'html/index.html'

files {
    'html/index.html',
    'html/style.css',
    'html/script.js'
}

dependencies {
    'ox_lib',
    'qbx_core',
    'ox_target'
}

lua54 'yes'
use_experimental_fxv2_oal 'yes'