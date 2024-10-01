-- Require other scripts
local blockInfo = require "scripts.block"
local entityInfo = require "scripts.entity"
local skin = require "scripts.skin"
local utility = require "scripts.utility"
local paletteModule = require "scripts.palette"

-- Hide Original Player Model
vanilla_model.PLAYER:setVisible(false)

		-- Local Variables --
local padding = 2

local hud_x = 110
local hud_y = 6

local range = 20

local blockBlacklist = {
	"minecraft:air",
	"minecraft:cave_air",
	"minecraft:nether_portal"
}

local entityBlacklist = {
	"create:stationary_contraption",
	"create:carriage_contraption",
	"create:super_glue",
	"amarite:amarite_disc"
}

-- how do i do this shit
pixelTex = textures:newTexture("pixel", 1, 1)
	:fill(0,0,1,1,vec(1,1,1,1))


		-- Keybinds --
-- Force the NBT table view
binds = {}
binds.showNbtTable = keybinds:newKeybind("Show NBT Table", "key.keyboard.tab")
local showNbtTable = false

function pings.nbtTableTogglePing(state) showNbtTable = state end

binds.showNbtTable.press = function() pings.nbtTableTogglePing(true) end
binds.showNbtTable.release = function() pings.nbtTableTogglePing(false) end


		-- HUD Parts --
-- Info HUD
local hud_facing = models.model.HUD.info:newPart("facing")

-- Info HUD
local hud_biome = models.model.HUD.info:newPart("biome")


		-- Facing Elements --
-- Name of Block
local hud_name = hud_facing:newText('name')
	:setShadow(true)

-- Block's internal id, including namespace
local hud_id = hud_facing:newText('id')
	:setShadow(true)

-- Item texture for block
local hud_item = hud_facing:newItem('item')

-- BG for Facing HUD
local hud_facing_back = utilityModule.createBlock("back", palette.colours[1]/255, 0.75, hud_facing)
	
-- Entity/BlockEntity NBT Data
local hud_nbt = hud_facing:newText('nbt')
	:setShadow(true)


		-- Biome Elements --
-- Current Biome's Name
local hud_biome_name = hud_biome:newText('name')
	:setShadow(true)

-- Current Biome's Mod
local hud_biome_mod = hud_biome:newText('mod')
	:setShadow(true)

-- BG for Biome HUD
local hud_biome_back = utilityModule.createBlock("back", palette.colours[2]/255, 0.75, hud_biome)

		-- Extra stuff --
-- Velocity display
local hud_velocity = models.model.HUD:newText('velocity')
	:setShadow(true)

-- Stronghold Ring display
local hud_stronghold_ring = models.model.HUD:newText('stronghold ring')
	:setShadow(true)


		-- Events --
function events.tick()
	local facingState = 0
	
	local hud_draw_offset = 0
	
	local block, bPos, bSide = player:getTargetedBlock(true,range)
	local entity, ePos = player:getTargetedEntity(math.min(range, host:getReachDistance()))
	
	if (block.id == "create:water_wheel_structure") then block = blockInfo.findWaterWheelCenter(block) end
	
	if (not(utility.tableContains(blockBlacklist, block.id))) then facingState = 1 end
	if (entity ~= nil) then
		if (not(utility.tableContains(entityBlacklist, entity:getType()))) then facingState = 2 end
	end
	
	local biome_name = utility.splitString(world.getBiome(player:getPos()).id, ":")
	biome_name[1] = utility.formatString(biome_name[1])
	biome_name[2] = utility.formatString(biome_name[2])
	
	models.model.HUD.info:setPos(-hud_x,-hud_y)
	
	hud_facing:setVisible(facingState ~= 0)
	
	hud_item:setVisible(facingState == 1)
	
	if (facingState == 1 and host:isHost()) then
		local itemstack = block:asItem()
		local blockname = itemstack:getName()
		
		hud_facing:setPos(-padding,-padding)
		
		local w = math.max(
			client.getTextWidth(blockname),
			client.getTextWidth(block.id) / 2 + 1)
			+ (padding * 2) + 18
		
		-- Back box thing		i wanna replace this with a 9-slice eventually but idk how to make one
		hud_facing_back:setScale(w, 16 + (padding * 2))
			:setPos(padding, padding)
		
		-- Block name
		hud_name:setPos(-18,0)
			:text(blockname)
		
		-- Block item
		hud_item:setPos(-8,-8)
			:item(itemstack)
		
		-- Block ID
		hud_id:setPos(-18, -10)
			:text(block.id)
			:setScale(0.5,0.5)
		
		
		-- Block Data
		hud_nbt:setPos(0,-18)
			:setScale(0.5,0.5)
			:text(blockInfo.getText(block, showNbtTable))
		
		
		hud_draw_offset = hud_draw_offset - w - (padding * 2)
	end
	if (facingState == 2 and host:isHost()) then
		local entity, pos = player:getTargetedEntity(host:getReachDistance())
		--local entityPos = entity:getPos()
		
		local w = math.max(
			client.getTextWidth(entity:getName()),
			client.getTextWidth(entity:getType()) / 2 + 1)
			+ (padding * 2)
		
		-- Back box thing		i wanna replace this with a 9-slice eventually but idk how to make one
		hud_facing_back:setScale(w, 16 + (padding * 2))
			:setPos(padding, padding)
		
		-- Entity name
		hud_name:setPos(0,0)
			:text(entity:getName())
		
		-- Entity ID
		hud_id:setPos(0, -10)
			:text(entity:getType())
			:setScale(0.5,0.5)
		
		-- Entity NBT Data
		hud_nbt:setPos(0,-18)
			:setScale(0.5,0.5)
			:text(entityInfo.getText(entity, showNbtTable))
		
		
		hud_draw_offset = hud_draw_offset - w - (padding * 2)
	end
	
	local w = math.max(
		client.getTextWidth(biome_name[2]),
		client.getTextWidth(biome_name[1]) / 2 + 1)
		+ (padding * 2)
	
	hud_biome:setPos(hud_draw_offset-padding, -padding)
	
	hud_biome_back:setPos(padding,padding)
		:setScale(w, 16 + (padding * 2))
	-- Current Biome
	hud_biome_name:setPos(0, 0)
		:text(biome_name[2])
	
	-- Current Biome Namespace
	hud_biome_mod:setPos(0, -10)
		:text(biome_name[1])
		:setScale(0.5,0.5)
	
	local vel = player:getVelocity()*20
	local velocity = math.floor(math.sqrt(vel.x^2 + vel.y^2 + vel.z^2)*10)/10
	local velText = velocity.." m/s"
	hud_velocity:setPos((client.getTextWidth(velText) / 2)-55,-130)
		:text(velText)
	
	local ringDist = math.sqrt(player:getPos().x^2 + player:getPos().z^2)
	if (world:getDimension() == "minecraft:the_nether") then ringDist = ringDist*8 end
	local ringI, ringMin, ringMax, strongholdCount = utility.getStrongholdRing(ringDist)
	
	
	local distText = "Distance from spawn: "..math.floor(ringDist).." blocks\n"
	local ringText = distText.."Not in any Stronghold Ring"
	if (ringI ~= 0) then ringText = distText.."Ring "..ringI.." ("..strongholdCount.." Strongholds)\nBetween "..ringMin.." and "..ringMax end
	hud_stronghold_ring:setPos(-4,-150)
		:text(ringText)
		:setVisible(world:getDimension() == "minecraft:overworld" or world:getDimension() == "minecraft:the_nether")
end