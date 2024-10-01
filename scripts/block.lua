local utility = require "scripts.utility"

local blockModule = {}

-- Find the center block on a Large Water Wheel
function blockModule.findWaterWheelCenter(block)
	local directions = {
		["east"]	= vec( 1, 0, 0),
		["west"]	= vec(-1, 0, 0),
		["up"]		= vec( 0, 1, 0),
		["down"]	= vec( 0,-1, 0),
		["south"]	= vec( 0, 0, 1),
		["north"]	= vec( 0, 0,-1)
	}
	
	-- Edges -> Center / Corners -> Edges
	block = world.getBlockState(block:getPos():add(directions[block:getProperties().facing]))
	
	-- Edges -> Center
	if (block.id ~= "create:water_wheel") then block = world.getBlockState(block:getPos():add(directions[block:getProperties().facing])) end
	
	return block
end

-- Different Displays for BlockEntity Data
function blockModule.getText(block, rawData)
	if (not(host:isHost())) then return "" end
	
	local id = block.id
	local nbt = block:getEntityData()
	local properties = block:getProperties()
	
	-- Use DimDoors rift data
	if (properties.half == "upper" and string.sub(block.id, 1, 22) == "dimdoors:block_ag_dim_") then nbt = world.getBlockState(block:getPos():add(0,-1,0)):getEntityData() end
	
	local createComponent = 0
	local isSign = false
	local isSophisticated = false
	-- BlockEntity Type Checking
	if (nbt ~= nil) then
		-- Check for Create Component data
		if (nbt.Speed ~= nil) then
			createComponent = 1
			if (nbt.Network ~= nil) then
				if (nbt.Network.Capacity ~= nil and nbt.Network.Stress ~= nil) then createComponent = 2 end
			end
		end
		
		-- Check for Sophisticated Storage/Backpacks Data
		isSophisticated =
			id:sub(1, 21) == "sophisticatedstorage:" and
			id ~= "sophisticatedstorage:storage_link" and
			id ~= "sophisticatedstorage:controller"
		
		-- Check for sign
		if (nbt.back_text ~= nil and nbt.front_text ~= nil) then
			if (nbt.back_text.messages ~= nil and nbt.front_text.messages ~= nil) then isSign = true end
		end
	end
	
			-- Different displays --
	-- Show the Raw Table
	if (rawData) then
		local pos = block:getPos()
		local str = "Position:\n	x: "..pos.x.."\n	y: "..pos.y.."\n	z: "..pos.z
		if (next(properties) ~= nil) then str = str.."\n\nProperties:\n"..printTable(properties,4,true) end
		if (nbt ~= nil) then str = str.."\n\nNBT:\n"..printTable(nbt,4,true) end
		return str
	end
	
	-- Sophisticated Storage Controllers
	if (id == "sophisticatedstorage:controller") then 
		local positions = ""
		for i,pos in ipairs(nbt.storagePositions) do
			local x, y, z = utility.decodeSophStorageCoords(pos)
			positions = positions..(x..", "..y..", "..z.."   :   "..pos).."\n"
		end
		return printTable(positions,6,true)
	end
	
	-- Jukebox
	if (id == "minecraft:jukebox") then
		local str = "Cached Playtime: "..utility.formatTime(nbt.TickCount)
		if (properties.has_record == "true") then str = str.."\n§l[Contains Music Disc]" end
		return str
	end
	
	-- Create components
	if (createComponent > 0) then
		local speed = math.abs(nbt.Speed)
		local stress = "N"
		local capacity = "A"
		local direction = "?"
		local addedStress = ""
		
		if (nbt.Speed > 0) then direction = "Clockwise"
		elseif (nbt.Speed < 0) then direction = "Counter-Clockwise"
		else direction = "Static" end
		
		if (createComponent == 2) then
			stress = nbt.Network.Stress
			capacity = nbt.Network.Capacity
			
			if (nbt.Network.AddedStress ~= nil) then addedStress = "\nStress Cost: "..math.abs(nbt.Speed) * nbt.Network.AddedStress
			elseif (nbt.Network.AddedCapacity ~= nil) then addedStress = "\nIncreases Stress cap by "..math.abs(nbt.Speed) * nbt.Network.AddedCapacity end
		end
		
		return "Speed: "..speed.."\nStress: "..stress.."/"..capacity.."\nDirection: "..direction..addedStress
	end
	
	-- Sophisticated Storage/Backpacks
	if (isSophisticated) then
		if (nbt.storageWrapper.renderInfo == nil) then return "" end
		
		-- Upgrades
		local upgrades = "\n\nUpgrades:\n"
		local upgradeCount = 0
		
		for i, v in ipairs(nbt.storageWrapper.renderInfo.upgradeItems) do
			if (v.id ~= "minecraft:air") then
				local upgr = utility.formatString(utility.splitString(v.id, ":")[2])
				upgrades = upgrades.."	"..upgr.."\n"
				upgradeCount = upgradeCount + 1
			end
		end
		
		if (upgradeCount == 0) then upgrades = "\nNo Upgrades" end
		
		-- Other stuff
		local locked = ""
		if (nbt.locked == 1) then locked = "\n\n§l[Locked]" end
		
		local controller = ""
		if (nbt.controllerPos ~= nil) then
			local x,y,z = utility.decodeSophStorageCoords(nbt.controllerPos)
			controller = "\nController Location:\n	"..x..", "..y..", "..z
		end
		
		return "Slot Count: "..nbt.storageWrapper.numberOfInventorySlots..upgrades..controller..locked
	end
	
	-- Sign Data
	if (isSign) then
		local colours = {
			["black"] = "§f",
			["gray"] = "§8",
			["light_gray"] = "§7",
			["white"] = "§f",
			["red"] = "§c",
			["orange"] = "§6",
			["yellow"] = "§e",
			["lime"] = "§a",
			["green"] = "§2",
			["cyan"] = "§3",
			["light_blue"] = "§b",
			["blue"] = "§9",
			["purple"] = "§5",
			["magenta"] = "§d",
			["pink"] = "§d",
			["brown"] = "§6"
		}
		
		local front = "Front Side:\n"
		for i, txt in ipairs(nbt.front_text.messages) do
			local text = string.sub(txt, 10, #txt-2)
			if (txt[1] ~= "{") then text = string.sub(txt, 2, #txt-1) end
			front = front.."	"..colours[nbt.front_text.color]..text.."§r\n"
		end
		front = front.."Colour: "..colours[nbt.front_text.color]..utility.formatString(nbt.front_text.color).."§r\n"
		if (nbt.front_text.has_glowing_text == 1) then front = front .. "§e(Glowing)§r\n" end
		
		local back = "Back Side:\n"
		for i, txt in ipairs(nbt.back_text.messages) do
			local text = string.sub(txt, 10, #txt-2)
			if (txt[1] ~= "{") then text = string.sub(txt, 2, #txt-1) end
			back = back.."	"..colours[nbt.back_text.color]..text.."§r\n"
		end
		back = back.."Colour: "..colours[nbt.back_text.color]..utility.formatString(nbt.back_text.color).."\n"
		if (nbt.back_text.has_glowing_text == 1) then back = back .. "§e(Glowing)" end
		
		local compare1 = nbt.front_text.messages[1]..nbt.front_text.messages[2]..nbt.front_text.messages[3]..nbt.front_text.messages[4]
		local compare2 = nbt.back_text.messages[1]..nbt.back_text.messages[2]..nbt.back_text.messages[3]..nbt.back_text.messages[4]
		local compare3 = '{"text":""}{"text":""}{"text":""}{"text":""}'
		local str = ""
		if (compare1 ~= compare3 and compare1 ~= "\"\"\"\"\"\"\"\"") then str = front.."\n" end
		if (compare2 ~= compare3 and compare2 ~= "\"\"\"\"\"\"\"\"") then str = str..back end
		
		return str
	end
	
	-- Basin
	if (id == "create:basin") then
		-- Ingredients
		local inputs = "Ingredients:\n"
		for i, v in ipairs(nbt.InputItems.Items) do
			inputs = inputs.."	"..v.Count.."x "..utility.formatString(utility.splitString(v.id,":")[2]).."\n"
		end
		
		-- Results
		local outputs = "Results:\n"
		for i, v in ipairs(nbt.OutputItems.Items) do
			outputs = outputs.."	"..v.Count.."x "..utility.formatString(utility.splitString(v.id,":")[2]).."\n"
		end
		
		return inputs.."\n"..outputs
	end
	
	-- Fluid Tanks
	if (id == "create:fluid_tank") then
		if (nbt.Controller ~= nil) then nbt = world.getBlockState(nbt.Controller.X, nbt.Controller.Y, nbt.Controller.Z):getEntityData() end -- fill with correct path once game is up
		
		local isBoiler = nbt.Boiler.Engines > 0
		
		if (isBoiler) then
			-- Engine Count
			local engines = nbt.Boiler.Engines.." Engine"
			if (nbt.Boiler.Engines ~= 1) then engines = engines.."s" end
			
			-- Burner Count
			
			local burners = nbt.Boiler.ActiveHeat.."/"..(nbt.Boiler.PassiveHeat + nbt.Boiler.ActiveHeat).." Active Burners"
			
			-- Supply
			local amount = ""
			if (nbt.Boiler.Supply > 0) then amount = "\nRecieving Water" end
			
			return engines.."\n"..burners..amount
		else
			local amount = utility.formatMillibuckets(nbt.TankContent.Amount/81).."/"..utility.formatMillibuckets(nbt.TankContent.Capacity/81)
			return nbt.TankContent.Variant.fluid.."\n"..amount
		end
	end
	
	-- Blaze Burners
	if (id == "create:blaze_burner") then
		
		if (nbt.isCreative ~= nil) then return "Infinite Fuel Remaining\nHas Creative Blaze Cake" else
			local cake = ""
			if (nbt.fuelLevel == 2) then cake = "\nHas Blaze Cake" end
			
			return math.ceil(nbt.burnTimeRemaining/20).."s Fuel Remaining"..cake
		end
	end
	
	return ""
end

return blockModule