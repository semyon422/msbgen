Preset = createClass()

Preset.load = function(self, filePath)
	self.jsonData = json.decode(io.open(filePath, "r"):read("*all"))
	
	self.images = {}
end

Preset.getImagePath = function(self, object, columnIndex)
	return self.data[object][columnIndex]
end

Preset.getImage = function(self, filePath)
	if not self.images[filePath] then
		self.images[filePath] = love.graphics.newImage(filePath)
	end
	
	return self.images[filePath]
end

Preset.setKeymode = function(self, keymode)
	self.keymode = keymode
	self.data = self.jsonData[keymode]
end



Preset.getWidth_px = function(self, object, columnIndex)
	return self:getImage(self.data[object][columnIndex]):getWidth()
end

Preset.getHeight_px = function(self, object, columnIndex)
	-- print(object, columnIndex)
	return self:getImage(self.data[object][columnIndex]):getHeight()
end

Preset.getWidth_opx = function(self, object, columnIndex)
	return preset:getColumnWidth_opx(columnIndex)
end

Preset.getHeight_opx = function(self, object, columnIndex)
	return preset:getHeight_px(object, columnIndex) / preset:getWidth_px(object, columnIndex) * preset:getColumnWidth_opx(columnIndex)
end


Preset.getColumnWidth_opx = function(self, columnIndex)
	return self.data.columnWidth[columnIndex]
end

Preset.getHP = function(self)
	return self.data.hitPosition
end

Preset.getSpeed = function(self)
	return self.data.speed
end