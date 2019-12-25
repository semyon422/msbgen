TaikoManiaProcessor = createClass()

TaikoManiaProcessor.donState = 1
TaikoManiaProcessor.katState = 1
TaikoManiaProcessor.donPrevTime = 0
TaikoManiaProcessor.katPrevTime = 0

TaikoManiaProcessor.getKey = function(self, taikoNoteType, startTime)
	local char = taikoNoteType:sub(1, 1)
	local columns = {}
	local mainColumns = {}
	local mainState = 0
	for i = 1, 4 do
		if self.layout:sub(i, i):lower() == char then
			table.insert(columns, i)
			if self.layout:sub(i, i) ~= char then
				table.insert(mainColumns, i)
				if #columns == #mainColumns then
					mainState = -1
				else
					mainState = 1
				end
			end
		end
	end
	
	local deltaTime
	if taikoNoteType == "don" then
		deltaTime = startTime - self.donPrevTime
		self.donPrevTime = startTime
	elseif taikoNoteType == "kat" then
		deltaTime = startTime - self.katPrevTime
		self.katPrevTime = startTime
	end
	
	if deltaTime > self.alternationMaxDelta then
		local state
		if taikoNoteType == "don" then
			self.donState = -self.donState
			state = self.donState
		elseif taikoNoteType == "kat" then
			self.katState = -self.katState
			state = self.katState
		end
		if mainColumns[1] then
			if taikoNoteType == "don" then
				self.donState = mainState
			elseif taikoNoteType == "kat" then
				self.katState = mainState
			end
			return mainColumns[1]
		elseif state == -1 then
			return columns[1]
		elseif state == 1 then
			return columns[2]
		end
	else
		local state
		if taikoNoteType == "don" then
			self.donState = -self.donState
			state = self.donState
		elseif taikoNoteType == "kat" then
			self.katState = -self.katState
			state = self.katState
		end
		if state == -1 then
			return columns[1]
		elseif state == 1 then
			return columns[2]
		end
	end
end

TaikoManiaProcessor.alternationMaxDelta = 60000/157/2
TaikoManiaProcessor.alternationType = 2
TaikoManiaProcessor.hitSoundType = 1
-- TaikoManiaProcessor.holds = false
TaikoManiaProcessor.doubles = true

TaikoManiaProcessor.processLine = function(self, line)
	local maniaNotes = {}
		-- print(line)
	
	local noteTable = line:split(",")
	
	local startTime = tonumber(noteTable[3])
	local noteType = tonumber(noteTable[4])
	local hitSound = tonumber(noteTable[5])
	
	-- local tr = nc.metaData["SliderTickRate"]
	-- local minHitRate = nc:getMinHitDelay(startTime)
	
	local count
	local length
	local edgeHitsounds = {}
	local beat = nc:getBeatDuration(startTime)
	local tick = beat / nc.metaData["SliderTickRate"]
	if bit.band(noteType, 2) == 2 then
		-- if true then return {} end
		_repeat = tonumber(noteTable[7])
		length = tonumber(noteTable[8]) / (100 * nc.metaData["SliderMultiplier"]) * beat / nc:getVelocity(startTime)
		-- _repeat = length0 * _repeat0 / minHitRate
		-- length = minHitRate
		if noteTable[9] then
			edgeHitsounds = noteTable[9]:split("|")
		end
		if length < 16 then
			_repeat = 0
		end
		-- if startTime == 281291 then print(length, _repeat) end
		local lastHs
		for i = 0, _repeat do
			local offset = startTime + i * length
			local hs
			-- if i == 0 then
				hs = tonumber(edgeHitsounds[i + 1]) or hitSound
				-- lastHs = hs
			-- elseif i > 0 and (tonumber(edgeHitsounds[i + 1]) == 0 or not tonumber(edgeHitsounds[i + 1])) then
				-- hs = lastHs
			-- elseif i > 0 and (tonumber(edgeHitsounds[i + 1]) ~= 0 or tonumber(edgeHitsounds[i + 1])) then
				-- hs = tonumber(edgeHitsounds[i + 1]) or hitSound
				-- lastHs = hs
			-- end	
			
			local nextOffset = startTime + (i + 1) * length - 1
			local localManiaNotes = self:getNotes(offset, hs)
			for j, v in ipairs(localManiaNotes) do
				table.insert(maniaNotes, v)
			end
			if i < _repeat then
				for o = offset + tick, nextOffset, tick do
					local localManiaNotes = self:getNotes(o, hs)
					for j, v in ipairs(localManiaNotes) do
						table.insert(maniaNotes, v)
					end
				end
			end
		end
	else
		maniaNotes = self:getNotes(startTime, hitSound)
	end
	-- if startTime == 22279 then error() end
	--[[
		nc w f c
		1000 d	0
		0100 k	2
		1100 k	2
		0010 dd	4
		1010 dd	4
		0110 kk	6
		1110 kk	6
		0001 k	8
		1001 k	8
		0101 k	10
		1101 k	10
		0011 kk	12
		1011 kk	12
		0111 kk	14
		1111 kk	14
		
		single yellow short
		256,192,281291,6,0,L,1,0.01
		
		double yellow
		152,96,57312,2,4,L|224:80,18,40
	]]
	
	return maniaNotes
end

TaikoManiaProcessor.getNotes = function(self, startTime, hitSound)
	local maniaNotes = {}
	
	local taikoNoteType = ""
	local isDouble = false
	if hitSound == 0 or hitSound == 4 then
		taikoNoteType = "don"
		if self.doubles and hitSound == 4 then
			isDouble = true
		end
	else
		taikoNoteType = "kat"
		if self.doubles and (hitSound == 6 or hitSound == 12 or hitSound == 14) then
			isDouble = true
		end
	end
	if not isDouble then
		local columnIndex = self:getKey(taikoNoteType, startTime)
		
		maniaNotes[1] = {}
		maniaNotes[1].startTime = startTime
		maniaNotes[1].baseColumnIndex = columnIndex
		maniaNotes[1].columnIndex = columnIndex
	else
		local columnIndex1 = self:getKey(taikoNoteType, startTime)
		local columnIndex2 = self:getKey(taikoNoteType, startTime)
		
		-- if startTime == 163638 then print(columnIndex1, columnIndex2) end
		maniaNotes[1] = {}
		maniaNotes[2] = {}
		
		maniaNotes[1].startTime = startTime
		maniaNotes[2].startTime = startTime
		
		maniaNotes[1].columnIndex = columnIndex1
		maniaNotes[1].baseColumnIndex = columnIndex1
		maniaNotes[2].columnIndex = columnIndex2
		maniaNotes[2].baseColumnIndex = columnIndex2
	end
	
	return maniaNotes
end