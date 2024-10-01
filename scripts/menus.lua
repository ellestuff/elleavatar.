local utility = require "scripts.utility"
windows = {}
buttons = {}

page = action_wheel:newPage()


		-- Keybinds --
binds.toggleWinMode = keybinds:newKeybind("Toggle window interactions", "key.keyboard.j")
	:setGUI(false)
local toggleWinMode = false

function pings.toggleWinMode() toggleWinMode = not(toggleWinMode) end
binds.toggleWinMode.press = function() pings.toggleWinMode() end


		-- Button | Create Palette Window --
-- Create Button
buttons.palette = page:newAction() -- Padding
	:title("Create New Palette Window")
	:color(1,1,1)
	:item("minecraft:white_dye")

-- Click Behaviour
function buttons.palette.leftClick()
	createWindow("palette", {
		["colourId"] = 1
	})
end


		-- Window Creation --
-- Create New Palette Window
local winId = 0
function createWindow(t, data)
	if (#windows == 0) then toggleWinMode = true end
	
	local window = {
		-- Values
		["x"] = 100,
		["y"] = 100,
		["width"] = 128,
		["height"] = 64,
		["type"] = t,
		["data"] = data,
		["id"] = winId,
		["part"] =  models.model.HUD.windows:newPart(t..winId),
		["parts"] = {},
		["base"] = {},
		["name"] = t..winId,
		["colour"] = vec(1,1,1)
	}
	
	-- Window Functions
	window.createFolders = function(win)
		win.folder = win.part:newPart("parts")
		
		win.baseFolder = win.part:newPart("base")
			:setPos(0,0,16)
	end
	
	window.newBlockPart = function(win, name, c, a)
		win.parts[name] = utility.createBlock("block:"..name, win.colour, 0.5, win.folder)
	end
	
	window.createBase = function(win)
		-- Back
		win.base.bg = utility.createBlock("back", win.colour, 0.5, win.baseFolder)
			:setPos(0,0)
		
		-- Top
		win.base.top = utility.createBlock("top", win.colour, 0.75, win.baseFolder)
			:setPos(0,12)
			
		-- Close
		win.base.close = utility.createBlock("delete", win.colour, 1, win.baseFolder)
			:setScale(12,12)
		
		-- Name
		win.base.name = win.baseFolder:newText("name")
			:setShadow(true)
			:setPos(-2,10)
		
		-- Close X
		win.base.x = win.baseFolder:newText("x")
			:text("X")
			:setShadow(true)
			:setPos(9-win.width,10)
	end
	
	winId = winId + 1
	
	window:createFolders()
	window:createBase()
	
	table.insert(windows, window)
	
	createWindowSpecificParts(window)
	
	updateAllWindows()
	
	return window
end

-- Delete a window
function deleteWindow(id)
	if (#windows == 0) then return end

	if (id == nil) then id = #windows end
	windows[id].part:remove()
	table.remove(windows)
	updateAllWindows()
	
	if (#windows == 0) then toggleWinMode = false end
end

-- Create parts for a Window
function createWindowSpecificParts(window)
	local winType = window.type
	local d = window.data
	
	if (winType == "palette") then
		d.colourId = math.random(2)
		
		window:newBlockPart("test", vec(1,1,1), 1)
	end
end

-- Handle Window Changes
function updateAllWindows()
	host:setUnlockCursor(#windows > 0)
	
	for i, v in ipairs(windows) do
		updateWindow(v)
	end
	printTable(windows)
end

-- Update a single Window
function updateWindow(window)
	updateWindowBase(window)
	updateWindowParts(window)
end

-- Update the base of a window
function updateWindowBase(window)
	-- Positions
	window.part:setPos(-window.x, -window.y)
	window.base.close:setPos(12-window.width,12)
	
	-- Sizes
	window.base.bg:setScale(window.width,window.height)
	window.base.top:setScale(window.width,12)
	
	-- colours
	window.base.bg:setColor(window.colour.x, window.colour.y, window.colour.z, 0.5)
	window.base.top:setColor(window.colour.x, window.colour.y, window.colour.z, 0.75)
	window.base.close:setColor(window.colour)
	
	
	-- Other
	window.base.name:text(window.name)
end

-- Create parts for a Window
function updateWindowParts(window)
	-- aaaaaaaaaaaaaaaaaaaaaaaaaa again
	if (window.type == "palette") then
		window.name = "Editing Colour #"..window.data.colourId
		window.colour = palette.colours[window.data.colourId]/255
		updateWindowBase(window)
	end
end


		-- Window Interactions --
local currentWin = 0
local currentPart = 0

local savedCursorPos = vec(0,0)

local cursorPos = vec(0,0)
local relativeCursorPos = vec(0,0)

local clickAction = ""
local actionStartPos = vec(0,0)
local actionWin = 0

-- Tick Function
function events.tick()
	host:setUnlockCursor(toggleWinMode)
	if (#windows == 0) then return end
	
	currentWin = 0
	currentPart = 0
	
	if (not(toggleWinMode)) then return end
	
	cursorPos = client:getMousePos()/client:getWindowSize()*client:getScaledWindowSize()
	
	for i, v in ipairs(windows) do
		relativeCursorPos = cursorPos - vec(v.x,v.y)
		if (relativeCursorPos.x >= 0 and relativeCursorPos.x < v.width and relativeCursorPos.y >= -12 and relativeCursorPos.y < v.height) then
			currentWin = i
			
			if (relativeCursorPos.y < 0) then
				currentPart = 1
				if (relativeCursorPos.x >= v.width-12) then currentPart = 2 end
			end
		end
	end
	
	local win = windows[currentWin]
	
	if (clickAction == "drag") then
		local dWin = windows[actionWin]
		
		dWin.x = cursorPos.x - actionStartPos.x
		dWin.y = cursorPos.y - actionStartPos.y
		updateWindow(dWin)
	end
end

function events.mouse_press(button, action, modifier)
	if (#windows == 0) then return end
	
	-- Left Click stuff
	if (button == 0 and (toggleWinMode or not(host:isContainerOpen()))) then
		local win = windows[currentWin]
		
		-- Close a Window
		if (clickAction == "close" and currentWin == actionWin and action == 0) then deleteWindow(actionWin) end
		
		-- Click types
		if (action == 1 and currentWin > 0) then
			-- Dragging
			if (currentPart == 1) then
				clickAction = "drag"
				actionStartPos = cursorPos - vec(win.x,win.y)
				actionWin = currentWin
			end
			
			-- Closing
			if (currentPart == 2) then
				clickAction = "close"
				actionWin = currentWin
			end
		else
			clickAction = ""
		end
	end
end

		-- Final Stuff --
action_wheel:setPage(page)