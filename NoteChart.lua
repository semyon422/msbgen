NoteChart = createClass()

NoteChart.parse = function(self, filePath)
	self.filePath = filePath
	local file, err = io.open(filePath, "r")
	if err then print(err) end
	self.noteData = {}
	self.metaData = {}
	self.timingData = {}
	
	self.currentBlockName = ""
	for line in file:lines() do
		if line:find("^%[") then
			self.currentBlockName = line:match("^%[(.+)%]")
		else
			if line:find("^%a+:.*$") then
				local key, value = line:match("^(%a+):%s?(.*)")
				self.metaData[key] = value:trim()
				if key == "Mode" and value:trim() == "3" then
					self.mania = true
				end
				if key == "CircleSize" then
					self.columnCount = self.mania and tonumber(value) or 4
				end
			elseif self.currentBlockName == "TimingPoints" and line:trim() ~= "" then
				local timingPoint = {}
				timingPoint.noteChart = self
				
				local data = line:split(",")
				timingPoint.data = data
				timingPoint.line = line
				
				table.insert(self.timingData, timingPoint)
			elseif self.currentBlockName == "HitObjects" and line:trim() ~= "" then
				if self.mania then
					local note = {}
					note.noteChart = self
					
					local data = line:split(",")
					note.data = data
					
					local interval = 512 / note.noteChart.columnCount
					for columnIndex = 1, note.noteChart.columnCount do
						if tonumber(data[1]) >= interval * (columnIndex - 1) and tonumber(data[1]) < columnIndex * interval then
							note.columnIndex = columnIndex
							break
						end
					end
					
					note.startTime = tonumber(data[3])
					if bit.band(tonumber(data[4]), 128) == 128 then
						note.endTime = tonumber(data[6]:split(":")[1])
					end
					
					table.insert(self.noteData, note)
				else
					for _, note in ipairs(tmp:processLine(line)) do
						table.insert(self.noteData, note)
						note.noteChart = self
						note.data = {}
					end
				end
			end
		end
	end
	file:close()
	
	table.sort(self.noteData, function(a, b) return a.startTime < b.startTime end)
	self.noteCount = #self.noteData
	
	return self
end

NoteChart.getBeatDuration = function(self, startTime)
	local beatDuration
	for _, timingPoint in ipairs(self.timingData) do
		if timingPoint.data[7] == "1" then
			if not beatDuration or tonumber(timingPoint.data[1]) < startTime then
				beatDuration = tonumber(timingPoint.data[2])
			else
				return beatDuration
			end
		end
	end
	return beatDuration
end

NoteChart.getVelocity = function(self, startTime)
	local velocity = 1
	for _, timingPoint in ipairs(self.timingData) do
		if timingPoint.data[7] == "0" then
			if tonumber(timingPoint.data[1]) <= startTime then
				velocity = -100 / timingPoint.data[2]
			else
				return velocity
			end
		end
	end
	return velocity
end

-- NoteChart.getMinHitDelay = function(self, startTime)
	-- local tr = nc.metaData["SliderTickRate"]
	-- local minHitDelay = 0
	
	-- local maxRate
	-- if ((tr == 3) or (tr == 6) or (tr == 1.5)) then
		-- maxRate = self:getBeatDuration(startTime) / 6
	-- else
		-- maxRate = self:getBeatDuration(startTime) / 8
	-- end
	-- while (maxRate < 60) do
		-- maxRate = maxRate * 2
	-- end
	-- while (maxRate > 120) do
		-- maxRate = maxRate / 2
	-- end
	-- minHitDelay = maxRate

	-- return minHitDelay
-- end