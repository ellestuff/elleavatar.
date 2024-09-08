local utility = require "scripts.utility"

windows = {}
buttons = {}

page = action_wheel:newPage()

		-- Plain Texture --
local windowBg = textures:newTexture("window bg", 1, 1)
	:fill(0,0,1,1,vec(1,1,1,1))


		-- Keybinds --
-- Force the NBT table view
binds.deleteLastWin = keybinds:newKeybind("Show NBT Table", "key.keyboard.y")

binds.deleteLastWin.press = function() deleteWindow(#windows) end


		-- Button | Create Palette Window --
-- Create Button
buttons.palette = page:newAction() -- Padding
	:title("Create New Palette Window")
	:color(colours[2]/255)
	:item("minecraft:pink_dye")

-- Click Behaviour
function buttons.palette.leftClick()
	createWindow("palette", {
		["colourId"] = 0
	})
end

logTable(textures:getTextures())

		-- Window Stuff --
-- Create New Palette Window
local winId = 0
function createWindow(t, data)
	local window = {
		["x"] = 100,
		["y"] = 100,
		["width"] = 128,
		["height"] = 64,
		["type"] = t,
		["data"] = data,
		["folder"] = models.model.HUD.windows:newPart(t..winId),
		["parts"] = {}
	}
	window.bg = utility.newNineSlice("bg", window.folder, textures["textures/nine slice.png"])
		:setPos(2,12)
	
	window.parts.text = window.folder:newText("text")
		:text("Who needs MarieOS when\nyou have Figura?")
		:setShadow(true)
		:setPos(-2,-2)
	
	
	winId = winId + 1
	
	table.insert(windows, window)
	
	updateWindows()
	
	return window
end

-- Delete a window
function deleteWindow(id)
	if (#windows == 0) then return end

	if (id == nil) then id = #windows end
	windows[id].folder:remove()
	table.remove(windows)
	updateWindows()
end

-- Handle Window Changes
function updateWindows()
	host:setUnlockCursor(#windows > 0)
	
	for i, v in ipairs(windows) do
		v.folder:setPos(-v.x, -v.y)
	end
end

action_wheel:setPage(page)