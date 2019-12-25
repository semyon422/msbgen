preset = Preset:new()
preset:load("presets/" .. presetName .. ".json")
preset:setKeymode(nc.columnCount .. "K")

newSprite = function(path, layer, origin, x, y) return sb.Sprite:new(path, layer, origin, x, y):insert(sb.sprites) end

ratio = 640/480
getColumnStart = function(fullWidth)
	return math.floor((480 * ratio - fullWidth) / 2)
end

-- noteHeight = preset:getHeight_opx("note", 1)

columnIndices = function(columnIndex)
	return getColumnStart(preset:getColumnWidth_opx(1) * nc.columnCount) + (columnIndex - 1) * preset:getColumnWidth_opx(1)
end

keyStartTime = -2000
keyEndTime = 1000000

noteScale = preset:getColumnWidth_opx(1) / preset:getWidth_px("note", 1)
hitPosition = preset:getHP()

getStartEndTime = function(noteStartTime, objectType, columnIndex)
	-- noteStartTime -> hitPosition - noteHeight
	-- endTime -> 480
	
	-- (endTime - noteStartTime) * 480 / (480 + noteHeight - hitPosition) / 1000 = speed
	
	local speed = preset:getSpeed() / rate
	local noteHeight = preset:getHeight_opx(objectType, columnIndex)
	local hitPosition = preset:getHP()
	
	local endTime = (1 / speed) * 1000 * (480 + noteHeight - hitPosition) / 480 + noteStartTime
	local startTime = hitPosition * (noteStartTime - endTime) / (480 + noteHeight - hitPosition) + noteStartTime
	
	return startTime, endTime
end

insertKeys = function(keymode)
	local keyScaleY = 480/768
	for columnIndex = 1, keymode do
		local keyHeight = preset:getHeight_px("key", columnIndex)
		local keyScaleX = preset:getColumnWidth_opx(columnIndex) / preset:getWidth_px("key", columnIndex)
		newSprite(preset:getImagePath("key", columnIndex), nil, "TopLeft", columnIndices(columnIndex), 480 - keyHeight * keyScaleY)
			:vector(keyStartTime, keyEndTime, keyScaleX, keyScaleY, keyScaleX, keyScaleY)
			:fade (keyStartTime, keyEndTime, 1, 1)
	end
end

insertNote = function(note, columnIndex, keymode)
	local hitPosition = preset:getHP()
	if not note.endTime then
		local noteHeight_opx = preset:getHeight_opx("note", columnIndex)
		local startTime, endTime = getStartEndTime(note.startTime, "note", columnIndex)
		newSprite(preset:getImagePath("note", columnIndex), nil, "TopLeft", columnIndices(columnIndex), -noteHeight_opx)
			:scale(startTime, endTime, noteScale, noteScale)
			:fade (startTime, note.startTime, 1, 1)
			:fade (note.startTime, endTime, 0, 0)
			:move (startTime, endTime, columnIndices(columnIndex), -noteHeight_opx, columnIndices(columnIndex), 480)
	else
		local startTime, endTime = getStartEndTime(note.startTime, "head", columnIndex)
		local startTime2, endTime2 = getStartEndTime(note.endTime, "tail", columnIndex)
		
		local noteHeightHead_opx = preset:getHeight_opx("head", columnIndex)
		local noteHeightTail_opx = preset:getHeight_opx("tail", columnIndex)
		local noteHeightBody_opx = preset:getHeight_opx("body", columnIndex)
		
		
		local s = (480 + noteHeightHead_opx) / (endTime - startTime) * (startTime2 - startTime)
		local yscale = s / noteHeightBody_opx
		
		-- newSprite(preset:getImagePath("body", columnIndex), nil, "TopLeft", columnIndices(columnIndex), -noteHeightHead_opx)
			-- :vector(startTime, endTime2, noteScale, noteScale * yscale, noteScale, noteScale * yscale)
			-- :fade (startTime, endTime2, 1, 1)
			-- :move (startTime, endTime2, columnIndices(columnIndex), -s - noteHeightHead_opx + noteHeightHead_opx/2, columnIndices(columnIndex), 480 + noteHeightHead_opx/2)
		
		newSprite(preset:getImagePath("body", columnIndex), nil, "TopLeft", columnIndices(columnIndex), -noteHeightHead_opx)
			:vector(startTime, note.startTime, noteScale, noteScale * yscale, noteScale, noteScale * yscale)
			:vector(note.startTime, note.endTime, noteScale, noteScale * yscale, noteScale, 0)
			:fade (startTime, endTime2, 1, 1)
			:move (startTime, endTime2, columnIndices(columnIndex), -s - noteHeightHead_opx + noteHeightHead_opx/2, columnIndices(columnIndex), 480 + noteHeightHead_opx/2)
		
		
		newSprite(preset:getImagePath("head", columnIndex), nil, "TopLeft", columnIndices(columnIndex), -noteHeightHead_opx)
			:scale(startTime, endTime, noteScale, noteScale)
			:fade (startTime, note.startTime, 1, 1)
			:fade (note.startTime, endTime, 0, 0)
			:move (startTime, endTime, columnIndices(columnIndex), -noteHeightHead_opx, columnIndices(columnIndex), 480)
		newSprite(preset:getImagePath("head", columnIndex), nil, "TopLeft", columnIndices(columnIndex), hitPosition - noteHeightHead_opx)
			:scale(note.startTime, note.endTime, noteScale, noteScale)
			:fade (note.startTime, note.endTime, 1, 1)
		
		newSprite(preset:getImagePath("tail", columnIndex), nil, "TopLeft", columnIndices(columnIndex), -noteHeightTail_opx)
			:scale(startTime2, endTime2, noteScale, noteScale)
			:fade (startTime2, note.endTime, 1, 1)
			:fade (note.endTime, endTime2, 0, 0)
			:move (startTime2, endTime2, columnIndices(columnIndex), -noteHeightTail_opx, columnIndices(columnIndex), 480)
	end
end
newSprite("_storyboard/black.jpg", nil, "Centre", 320, 240)
	:scale(keyStartTime, keyEndTime, 1, 1)
	:fade (keyStartTime, keyEndTime, 1, 1)