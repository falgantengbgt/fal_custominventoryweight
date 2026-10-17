fx_version 'cerulean'
game 'gta5'
lua54 'yes'

name 'fal_customweight'
author 'FalGntng'
description 'Custom inventory weight by falgntng'
version '1.2.0'

-- Shared Scripts
shared_scripts {
    '@ox_lib/init.lua',
    'config.lua'
}

-- Server Scripts
server_script 'server/main.lua'

-- Dependencies
dependencies {
    'ox_lib',
    'ox_inventory'
}