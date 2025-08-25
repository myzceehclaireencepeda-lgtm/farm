fx_version 'cerulean'
game 'gta5'

name 'animal_farming'
description 'Advanced Animal Farming System for FiveM'
author 'YourName'
version '1.0.0'

-- Modern Lua syntax
lua54 'yes'

-- Dependencies
dependencies {
    'ox_lib',
    'ox_inventory',
    'ox_target',
    'oxmysql',
    'qbx_core'
}

-- Shared files
shared_scripts {
    '@ox_lib/init.lua',
    'config.lua'
}

-- Client files
client_scripts {
    'client/*.lua'
}

-- Server files
server_scripts {
    '@oxmysql/lib/MySQL.lua',
    'server/main.lua'
}

-- UI files
ui_page 'ui/index.html'

files {
    'ui/index.html',
    'ui/style.css',
    'ui/script.js'
}

-- Permissions (if using ace permissions)
add_ace 'group.admin' 'animal_farming.admin' allow