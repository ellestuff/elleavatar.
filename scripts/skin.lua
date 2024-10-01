local skinModule = {}

local eyes = textures:newTexture("eyes", 64, 64)
	:fill(0,0,64,64,vec(0,0,0,0))

local head = models.model.root.Head.Head
	:setSecondaryTexture("Custom", eyes)
	:setSecondaryRenderType("CUTOUT_EMISSIVE_SOLID")

-- Set eye colours and how dark the lower pixels are
function skinModule.updateEyes(palette)
	local i1 = palette.eyeIndexes[1]
	local i2 = palette.eyeIndexes[2]
	
	eyes -- Primary Eye
		:setPixel(10, 12, palette.colours[i1]/255)
		:setPixel(10, 13, palette.colours[i1]/255 * palette.shadowAlpha[1])
		 -- Secondary Eye
		:setPixel(13, 12, palette.colours[i2]/255)
		:setPixel(13, 13, palette.colours[i2]/255 * palette.shadowAlpha[2])
		
		:update()
end

return skinModule