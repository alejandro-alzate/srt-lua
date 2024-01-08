local srt = {
	_VERSION		= '',
	_DESCRIPTION	= 'SRT parser for lua',
	_URL			= 'github.com/alejandro-alzate/srt-lua',
	_LICENSE		= [[]]
}

local function update(self, dt)
	local dt = dt or 0
	self.clock = self.clock + dt
	outputString = self:parse(self)
end

local function getText(self, time)
	return self.outputString
end

local function getTime(self)
	return self.clock
end

local function setTime(self, time)
	local time = time or 0
	self.clock = time
	self:update(0)
end

local function strToTbl(string)
	local returnTable = {}
	local line = ''
	if type(string) ~= 'string' then
		return returnTable
	end
	for i=1, string:len() do
		if string:sub(i,i) == '\n' then
			table.insert(returnTable, line)
			line = ''
		end
		line = line .. string:sub(i,i):gsub('\n', '')
	end
	return returnTable
end

local function parse(self)
	local stringAsTable = {}
	local result1 = 0
	local result2 = 0
	local time = self.clock or 0
	self.outputString = ''
	if self.srtString == nil then
		return false
	end
	--	if self.clock == 0 then
	--		self.outputString = ''
	--		return
	--	end
	stringAsTable = strToTbl(self.srtString)
	for i,v in ipairs(stringAsTable) do
		--Get a match on "XX:XX:XX,XXX --> XX:XX:XX,XXX"
		if v:match('%d%d%:%d%d%:%d%d%,%d%d%d% %-%-%>% %d%d%:%d%d%:%d%d%,%d%d%d') then
			--Hardcoded cuz i'm suck at this
			--I bet this will break/slow on larger/longer files
			local hour		= 0
			local minute	= 0
			local second	= 0
			local mili		= 0

			local hour2		= 0
			local minute2	= 0
			local second2	= 0
			local mili2		= 0

			hour = v:sub(1,2)
			minute = v:sub(4,5)
			second = v:sub(7,8)
			mili = v:sub(10,12)

			hour2 = v:sub(18,19)
			minute2 = v:sub(21,22)
			second2 = v:sub(24,25)
			mili2 = v:sub(27,29)


			result1 = mili / 1000
			result1 = result1 + second
			result1 = result1 + (minute * 60)
			result1 = result1 + (hour * 3600)

			result2 = mili2 / 1000
			result2 = result2 + (tonumber(second2))
			result2 = result2 + (tonumber(minute2) * 60)
			result2 = result2 + (tonumber(hour2) * 3600)

			local outputText = ''
			local stopFlag = false
			for i2=i+1, i+30 do
				if not((stringAsTable[i2] == nil) or (stopFlag)) then
					outputText = outputText .. stringAsTable[i2] .. '\n'
					if stringAsTable[i2]:len() <= 1 then
						if (result1 <= self.clock) and (result2 >= self.clock) then
							self.outputString = outputText:sub(1, outputText:len() - 1)
							return true
						end
						stopFlag = true
					end
				end
				if stopFlag == true then
					break
				end
			end
		end
	end
	return false
end

function srt.new(string)
	return {
		update			= update,
		load			= load,
		getText			= getText,
		setTime			= setTime,
		getTime			= getTime,
		clock			= 0,
		text			= '',
		srtString		= tostring(string) or '',
		outputString	= '',
		parse			= parse
	}
end

return srt