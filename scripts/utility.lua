utilityModule = {}

function utilityModule.splitString(inputstr, sep)
	local t = {}
	for str in string.gmatch(inputstr, "([^"..sep.."]+)") do
		table.insert(t, str)
	end
	return t
end

function utilityModule.formatString(input)
	local words = utilityModule.splitString(input, "_")
	for i, word in ipairs(words) do
		words[i] = word:sub(1, 1):upper() .. word:sub(2):lower()
	end
	return table.concat(words, " ")
end

function utilityModule.decodeSophStorageCoords(encodedValue)
	-- Decode x, z, and y from encoded value
	local x = math.floor(encodedValue / 2^38)
	local remainder = encodedValue - (x * 2^38)

	local z = math.floor(remainder / 4096)
	local y = remainder - (z * 4096)

	-- Handling wrapping or offset
	local MAX_Y = 512
	local MAX_Z = 61000000

	if y >= 512 then y = y - 4096 end
	
	if z >= 61000000 then z = z - 67108864 end

	return x, y, z
end

function utilityModule.tableContains(arr, value)
	local contains = false
	local pos = 0
	for i, entry in ipairs(arr) do
		if (entry == value) then
			contains = true
			pos = i
			break
		end
	end
	return contains, pos
end


function utilityModule.getStrongholdRing(dist)
	local strongholdRings = {3,6,10,15,21,28,36,9}
	for i, v in ipairs(strongholdRings) do
		local mn = i * 3072 - 1792
		local mx = i * 3072 - 256
		if (mn <= dist and dist <= mx) then return i, mn, mx end
	end
	return 0, 0, 0
end

function utilityModule.formatMillibuckets(amount)
	local str = math.floor(amount/1000).."B"
	if (amount % 1000 ~= 0) then str = str..", "..(amount % 1000).."mB" end
	return str
end

function utilityModule.formatTime(ticks)
	local rawSecs = math.floor((ticks+10)/20)
	local secs = rawSecs%60
	local mins = math.floor(rawSecs/60)%60
	local hours = math.floor(rawSecs/3600)%60
	
	local str = ""
	if (hours ~= 0) then str = hours.."h " end
	if (mins ~= 0) then str = str..mins.."m " end
	if (secs ~= 0 or (mins == 0 and hours == 0)) then str = str..secs.."s" end
	
	return str
end

function utilityModule.newNineSlice(name,parent,texture,left,right,top,bottom)
	local slice = models:newPart(name)
		:moveTo(parent)
		
		-- Top
		:newSprite("top")
			:setTexture(texture)
	
	return slice
end

function utilityModule.scaleNineSlice(slice,w,h)
	
end

return utilityModule