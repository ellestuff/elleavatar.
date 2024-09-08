require "scripts/main"

-- a
function colourToHex(c, small)
	if (small) then c = c/255 end
	local str = "#"..string.format("%02x", c.x)..string.format("%02x", c.y)..string.format("%02x", c.z)
	return str
end

local c1 = colourToHex(colours[1], false)
local c2 = colourToHex(colours[2], false)

-- Default
nameplate.ALL:setText(
	toJson({
		{ text = 'elle', color = c1 },
		{ text = 'stuff', color = c2 },
		{ text = '.', color = c1 },
	})
)

-- Chat
nameplate.CHAT:setText(
	toJson({
		{ text = 'elle', color = c1 },
		{ text = '.', color = c2 }
	})
)

-- Logo Colour
avatar:setColor(colours[2]/255)