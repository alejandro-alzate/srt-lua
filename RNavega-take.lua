-- Allow 'srt' to be used as a metatable for instances of subtitles objects.
local srt = {}
srt.__index = srt


-- The 'msDT' time offset should be in MILLISECONDS.
--
-- To be called from love.update() like so:
-- mySubtitle:advance(dt * 1000)
function srt:advance(msDT)
    self.time = self.time + msDT
    -- Check if we need to advance to a future node whose end time is ahead of
    -- the current seek time.
    if self.currentNode and self.time > self.currentNode.endTime then
        local currentIndex = self.currentNode.index
        local node = self.currentNode
        while node and self.time > node.endTime do
            currentIndex = currentIndex + 1
            node = self.parsedNodes[currentIndex]
        end
        if self.currentNode ~= node then
            self.currentNode = node
            return true
        end
    end
    return false
end


function srt:getText()
    if self.currentNode and self.time >= self.currentNode.startTime then
        return self.currentNode.text
    else
        return nil
    end
end


function srt:getTime()
	return self.time
end


-- The absolute 'msTime' should be in MILLISECONDS.
function srt:setTime(msTime)
	self.time = msTime
    -- Seek until we find the next subtitle node whose end time is bigger than 'time'.
    for index = 1, #self.parsedNodes do
        local node = self.parsedNodes[index]
        if node.endTime > msTime then
            self.currentNode = node
            return
        end
    end
end


function srt:clear()
    -- Note: when on LuaJIT, there's a special method for the fast clearing of tables.
    -- require('table.clear')
    -- (...)
    -- table.clear(self.parsedNodes)
    -- Read more here: https://luajit.org/extensions.html
    for index = 1, #self.parsedNodes do
        self.parsedNodes[index] = nil
    end
    self.currentNode = nil
end



function srt:parse(srtString)
    self:clear()
    local nodeCount = 0
    -- Make sure that the input text finishes with the SRT blank line separator ('\n\n'), so
    -- that the last subtitle piece is definitely read. If the file already ends on that separator
    -- then this won't affect anything.
    srtString = srtString .. '\n\n'
    -- SRT format from: https://en.wikipedia.org/wiki/SubRip#Format
    for srtIndex, hours1, minutes1, seconds1, millis1,
        hours2, minutes2, seconds2, millis2, text in srtString:gmatch(
        '(%d+)\n'..
        '(%d%d):(%d%d):(%d%d),(%d%d%d) %-%-> (%d%d):(%d%d):(%d%d),(%d%d%d)\n'..
        '(.-)\n'..
        '\n') do
        -- Create a new node.
        nodeCount = nodeCount + 1
        local newNode = {
            -- Transform the timecodes into milliseconds integers, easier to compare.
            -- Note: strings are being implicitly coerced into numbers.
            startTime = hours1 * 3600000 + minutes1 * 60000 + seconds1 * 1000 + millis1,
            endTime = hours2 * 3600000 + minutes2 * 60000 + seconds2 * 1000 + millis2,
            index = nodeCount,
            text = text
        }
        table.insert(self.parsedNodes, newNode)
    end
    -- Reset the subtitle scanning to read from the first node.
    self.time = 0.0
    self.currentNode = self.parsedNodes[1]
end


function srt.new(srtString)
    -- Apply 'srt' as the metatable to a new blank table, so all shared functions and
    -- shared variables are available.
    local subs = setmetatable({time=0.0, parsedNodes={}, currentNode=nil}, srt)
    if srtString and type(srtString) == 'string' then
        subs:parse(tostring(srtString))
    end
    return subs
end


return srt