paletteModule = {}
local skin = require "scripts.skin"

palettes = config:load("colours") or {
	["default"] = {
		["name"] = "Default Palette",
		["colours"] = {
			vec(118, 216, 218),
			vec(255, 83, 169)
		},
		["shadowAlpha"] = {0.8, 0.85},
		["eyeIndexes"] = {1,2}
	}
}

currentPalette = "default"

palette = palettes[currentPalette]

skin.updateEyes(palette)

return paletteModule