local skinModule = {}

local eyes = textures:newTexture("eyes", 64, 64)
	:fill(0,0,64,64,vec(0,0,0,0))

local head = models.model.root.Head.Head
	:setSecondaryTexture("Custom", eyes)
	:setSecondaryRenderType("CUTOUT_EMISSIVE_SOLID")

-- Set eye colours and how dark the lower pixels are
function skinModule.updateEyes()
	eyes -- Primary Eye
		:setPixel(10, 12, colours[1]/255)
		:setPixel(10, 13, colours[1]/255 * eyeShadows[1])
		 -- Secondary Eye
		:setPixel(13, 12, colours[2]/255)
		:setPixel(13, 13, colours[2]/255 * eyeShadows[2])
		
		:update()
end


return skinModule