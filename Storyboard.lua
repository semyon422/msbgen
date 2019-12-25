Storyboard = {}

Storyboard.new = function(self, storyboard)
	local storyboard = storyboard or {}
	storyboard.sprites = {}
	
	setmetatable(storyboard, self)
	self.__index = self
	
	return storyboard
end

Storyboard.export = function(self, path)
	local outTable = {}
	for i, v in ipairs(self.sprites) do
		table.insert(outTable, v:getSpriteText())
	end

	outString = table.concat(outTable, "\n")

	file, err = io.open(path, "w")
	if not file then error(err) end
	file:write("[Events]\n")
	file:write("//Background and Video events\n")
	file:write("//Storyboard Layer 0 (Background)\n")
	file:write(outString)
	file:write("\n")
	file:write("//Storyboard Layer 1 (Fail)\n")
	file:write("//Storyboard Layer 2 (Pass)\n")
	file:write("//Storyboard Layer 3 (Foreground)\n")
	file:write("//Storyboard Sound Samples\n")
	file:write("\n")
end

Storyboard.Sprite = {}

Storyboard.Sprite.new = function(self, path, layer, origin, x, y)
	local sprite = {}
	sprite.eventSet = "Sprite," .. 
		(layer or "Foreground") .. "," .. 
		(origin or "Centre") .. "," .. 
		"\"" .. (path or "") .. "\"" .. "," .. 
		(x or 320) .. "," .. (y or 240)
		
	sprite.events = {}
	
	setmetatable(sprite, self)
	self.__index = self
	
	return sprite
end
Storyboard.Sprite.fade = function(self, startTime, endTime, startOpacity, endOpacity, easing)
	table.insert(self.events, 
		" F," .. 
		(easing or 0) .. "," ..
		math.floor(startTime or 0) .. "," ..
		math.floor(endTime or "") .. "," ..
		(startOpacity or 1) .. "," ..
		(endOpacity or 1)
	)
	
	return self
end
Storyboard.Sprite.move = function(self, startTime, endTime, startx, starty, endx, endy, easing)
	table.insert(self.events, 
		" M," .. 
		(easing or 0) .. "," ..
		math.floor(startTime or 0) .. "," ..
		math.floor(endTime or "") .. "," ..
		(startx or 320) .. "," ..
		(starty or 240) .. "," ..
		(endx or 320) .. "," ..
		(endy or 240)
	)
	
	return self
end
Storyboard.Sprite.scale = function(self, startTime, endTime, startScale, endScale, easing)
	table.insert(self.events, 
		" S," .. 
		(easing or 0) .. "," ..
		math.floor(startTime or 0) .. "," ..
		math.floor(endTime or "") .. "," ..
		(startScale or 1) .. "," ..
		(endScale or 1)
	)
	
	return self
end
Storyboard.Sprite.vector = function(self, startTime, endTime, startx, starty, endx, endy, easing)
	table.insert(self.events, 
		" V," .. 
		(easing or 0) .. "," ..
		math.floor(startTime or 0) .. "," ..
		math.floor(endTime or "") .. "," ..
		(startx or 1) .. "," ..
		(starty or 1) .. "," ..
		(endx or 1) .. "," ..
		(endy or 1)
	)
	
	return self
end
Storyboard.Sprite.rotate = function(self, startTime, endTime, startAngle, endAngle, easing)
	table.insert(self.events, 
		" R," .. 
		(easing or 0) .. "," ..
		math.floor(startTime or 0) .. "," ..
		math.floor(endTime or "") .. "," ..
		(startAngle or 0) .. "," ..
		(endAngle or 0)
	)
	
	return self
end
Storyboard.Sprite.colour = function(self, startTime, endTime, startColour, endColour, easing)
	table.insert(self.events, 
		" C," .. 
		(easing or 0) .. "," ..
		math.floor(startTime or 0) .. "," ..
		math.floor(endTime or "") .. "," ..
		(startColour or "255,255,255") .. "," ..
		(endColour or "255,255,255")
	)
	
	return self
end
Storyboard.Sprite.getSpriteText = function(self)
	return self.eventSet .. "\n" .. table.concat(self.events, "\n")
end
Storyboard.Sprite.insert = function(self, sprites)
	table.insert(sprites, self)
	return self
end


Storyboard.setBackground = function(self, path, startTime, endTime, scale, startOpacity, endOpacity, easing)
	local sprite = self.Sprite:new(path, "Background")
	sprite:fade(startTime, endTime, (startOpacity or 1), (endOpacity or 1), easing)
	sprite:scale(startTime, endTime, scale, scale, easing)
	
	table.insert(self.sprites, sprite)
	return sprite
end
Storyboard.simpleFlash = function(self, path, startTime, endTime)
	local sprite = self.Sprite:new(path)
	sprite:fade(1, 0, startTime, endTime)
	
	table.insert(self.sprites, sprite)
	return sprite
end
Storyboard.simplePulse = function(self, path, startTime, endTime, startScale, endScale)
	local sprite = self.Sprite:new(path)
	sprite:fade(1, 0, startTime, endTime)
	sprite:scale((startScale or 1), (endScale or (1.1*(startScale or 1))), startTime, endTime)
	
	table.insert(self.sprites, sprite)
	return sprite
end


Storyboard.pulse = function(self, path, startTime, endTime, x, y, startScale, endScale)
	local sprite = self.Sprite:new(path)
	sprite:move(x, y, x, y, startTime, startTime)
	sprite:fade(1, 0, startTime, endTime)
	sprite:scale((startScale or 1), (endScale or (1.1*(startScale or 1))), startTime, endTime)
	
	table.insert(self.sprites, sprite)
	return sprite
end
