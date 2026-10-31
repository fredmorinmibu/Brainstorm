Brainstorm = {}
function initBrainstorm()
	-- A second installed copy injects this call again: load the mod only once
	if Brainstorm.LOADED then
		return
	end
	Brainstorm.LOADED = true
	local lovely = require("lovely")
	local nativefs = require("nativefs")
	assert(load(nativefs.read(lovely.mod_dir .. "/Brainstorm/Brainstorm_main.lua")))()
	assert(load(nativefs.read(lovely.mod_dir .. "/Brainstorm/Brainstorm_UI.lua")))()
	assert(load(nativefs.read(lovely.mod_dir .. "/Brainstorm/Brainstorm_keyhandler.lua")))()
	assert(load(nativefs.read(lovely.mod_dir .. "/Brainstorm/Brainstorm_reroll.lua")))()
	if nativefs.getInfo(lovely.mod_dir .. "/Brainstorm/settings.lua") then
		local settings_file = STR_UNPACK(nativefs.read((lovely.mod_dir .. "/Brainstorm/settings.lua")))
		if settings_file ~= nil then
			Brainstorm.SETTINGS = settings_file
		end
	end
  _RELEASE_MODE = not Brainstorm.SETTINGS.debug_mode
	-- That copy also injects the key handler again, and Ctrl+A would turn itself back off
	local key_press_update = Brainstorm.key_press_update
	local last_press = nil
	Brainstorm.key_press_update = function(key)
		local press = key .. G.FRAMES.MOVE
		if press ~= last_press then
			last_press = press
			key_press_update(key)
		end
	end
end


