Replay = createClass()

local js = [[const osuReplayParser = require('osureplayparser'); const replayPath = '%s'; const replay = osuReplayParser.parseReplay(replayPath); console.log(JSON.stringify(replay));]]
local node = "node.exe"
--[[
replay
k1 2
d1 1
d2 4
k2 8
dd 10
kk 5

k2	d2	k1	d1
0	0	0	0

dd = k2 + k1
kk = d2 + d1
]]

Replay.getKey = function(self, taikoNoteType, deltaTime)
	return tmp:getKey(taikoNoteType, deltaTime)
end

Replay.parse = function(self, filePath)
	local osr = filePath
	local command = "\"\"" .. node .. "\"" .. " -e \"" .. js:format(osr) .. "\"\""
	local jsonText = io.popen(command):read("*all")
	self.jsonData = json.decode(jsonText)
	
	local temp = io.open("temp.json", "w")
	temp:write(jsonText)
	temp:close()
	-- error()
	
	self.noteData = {}
	self.metaData = {}
	self.timingData = {}
	
	if self.jsonData.gameMode == 1 then
		self:parseTaiko()
	elseif self.jsonData.gameMode == 2 then
		self:parseCatch()
	elseif self.jsonData.gameMode == 3 then
		self:parseMania()
	end
	table.sort(self.noteData, function(a, b) return a.startTime < b.startTime end)
	self.noteCount = #self.noteData
	
	return self
end

Replay.parseCatch = function(self)
	local lastNotes = {}
	local maxColumnIndex = 0
	local time = 0
	local prevTime = 0
	for _, event in ipairs(self.jsonData.replay_data) do
		time = time + event.timeSinceLastAction
		for key, state in pairs(event.keysPressed) do
			if state and key:sub(1,1) ~= "M" then
				print(key, state)
			end
			-- local columnIndex = tonumber(key:sub(4, -1))
			-- if not state and lastNotes[columnIndex] and lastNotes[columnIndex].startTime < time then
				-- if lastNotes[columnIndex].startTime + self.maniaHoldDelta < time then
					-- lastNotes[columnIndex].endTime = time
				-- end
				-- lastNotes[columnIndex] = nil
			-- end
			-- if state and not lastNotes[columnIndex] then
				-- lastNotes[columnIndex] = {
					-- startTime = time,
					-- columnIndex = columnIndex
				-- }
				-- if columnIndex > maxColumnIndex then
					-- maxColumnIndex = columnIndex
				-- end
				-- table.insert(self.noteData, lastNotes[columnIndex])
			-- end
		end
	end
	error()
	self.columnCount = maxColumnIndex
end

Replay.parseMania = function(self)
	local lastNotes = {}
	local maxColumnIndex = 0
	local time = 0
	local prevTime = 0
	for _, event in ipairs(self.jsonData.replay_data) do
		time = time + event.timeSinceLastAction
		for key, state in pairs(event.keysPressed) do
			local columnIndex = tonumber(key:sub(4, -1))
			if not state and lastNotes[columnIndex] and lastNotes[columnIndex].startTime < time then
				if lastNotes[columnIndex].startTime + self.maniaHoldDelta < time then
					lastNotes[columnIndex].endTime = time
				end
				lastNotes[columnIndex] = nil
			end
			if state and not lastNotes[columnIndex] then
				lastNotes[columnIndex] = {
					startTime = time,
					columnIndex = columnIndex
				}
				if columnIndex > maxColumnIndex then
					maxColumnIndex = columnIndex
				end
				table.insert(self.noteData, lastNotes[columnIndex])
			end
		end
	end
	self.columnCount = maxColumnIndex
end

Replay.parseTaiko = function(self)
	local lastNotes = {}
	local time = 0
	local prevTime = 0
	for _, event in ipairs(self.jsonData.replay_data) do
		time = time + event.timeSinceLastAction
		local bitwise = event.keyPressedBitwise
		-- print("----")
		-- print(bitwise)
		-- print(lastNotes[1], lastNotes[2], lastNotes[4], lastNotes[8])
		if bitwise then
			if bit.band(bitwise, 1) == 1 and not lastNotes[1] then
				lastNotes[1] = true
				
				table.insert(self.noteData, {
					startTime = time,
					columnIndex = self:getKey("don", time)
				})
			elseif bit.band(bitwise, 1) == 0 and lastNotes[1] then
				lastNotes[1] = false
			end
			
			if bit.band(bitwise, 2) == 2 and not lastNotes[2] then
				lastNotes[2] = true
				
				table.insert(self.noteData, {
					startTime = time,
					columnIndex = self:getKey("kat", time)
				})
			elseif bit.band(bitwise, 2) == 0 and lastNotes[2] then
				lastNotes[2] = false
			end
			
			if bit.band(bitwise, 4) == 4 and not lastNotes[4] then
				lastNotes[4] = true
				
				table.insert(self.noteData, {
					startTime = time,
					columnIndex = self:getKey("don", time)
				})
			elseif bit.band(bitwise, 4) == 0 and lastNotes[4] then
				lastNotes[4] = false
			end
			
			if bit.band(bitwise, 8) == 8 and not lastNotes[8] then
				lastNotes[8] = true
				
				table.insert(self.noteData, {
					startTime = time,
					columnIndex = self:getKey("kat", time)
				})
			elseif bit.band(bitwise, 8) == 0 and lastNotes[8] then
				lastNotes[8] = false
			end
		end
		-- print(lastNotes[1], lastNotes[2], lastNotes[4], lastNotes[8])
	end
	self.columnCount = 4
end
