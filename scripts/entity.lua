local utility = require "scripts.utility"

local entityModule = {}

function entityModule.getText(entity, rawData)
	local data = entity:getNbt()
	local id = entity:getType()
	
	-- Show the Raw Table
	if (rawData) then return "NBT:\n"..printTable(data,4,true) end
	
	-- Show Item Stuff
	if (id == "minecraft:item") then
		
		local str = "Time Left: "..utility.formatTime(6000-data.Age)
		return str
	end
	
	return ""
end

return entityModule