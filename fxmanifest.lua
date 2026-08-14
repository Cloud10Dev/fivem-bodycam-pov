fx_version 'cerulean'
game 'gta5'

lua54 'yes'

author 'Cloud10Dev'
description 'Standalone forced first-person bodycam POV with red-orange HUD and weapon telemetry.'
version '1.3.0'

ui_page 'html/index.html'

files {
    'html/index.html',
    'html/style.css',
    'html/app.js'
}

shared_script 'config.lua'
client_script 'client/main.lua'
