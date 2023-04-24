fx_version "adamant"
games {"rdr3"}
rdr3_warning 'I acknowledge that this is a prerelease build of RedM, and I am aware my resources *will* become incompatible once RedM ships.'

shared_script '@ox_lib/init.lua'
shared_script 'init.lua'

lua54 'yes'

files {
	'modules/**/client.lua',
	'shared/*.lua',
	'client.lua',
	'server.lua',
}