fx_version 'adamant'
lua54 'yes'
game 'gta5'

shared_script {
    '@es_extended/imports.lua',
    '@ox_lib/init.lua',
    'config.lua'
}

client_scripts {
    'client.lua'
}

server_scripts { 
	'@oxmysql/lib/MySQL.lua',
    'server.lua'
}

dependencies {
	'gridsystem',
}
