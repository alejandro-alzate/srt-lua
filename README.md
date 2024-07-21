# *srt.lua*
A pure lua library to for SubRip (SRT) file parsing

## To do:
- [ ] Improve performance
- [ ] Extended formatting
	- [ ] Position flags
	- [ ] HTML Color and format like *italic*, **bold**, _Underlined_ ***and*** *everything* **in** ***between***
	- [ ] Other formats like ~~strikethrough~~

## Features
- Simple API
- Easy to work with

## Flaws
- Janky parsing routine
- Inefficient
- Probably will break if the time reaches over 99 hours

## Getting started
1. 📡 Get a copy of srt.lua from the [Official Repository](https://github.com/alejandro-alzate/srt-lua) or [From Luarocks](https://luarocks.org/modules/alejandro-alzate/srt)
2. 💾 Copy `srt.lua` where you like to use it, or just on the root directory of the project
3. ⚙ Add it to your project like this
	```lua
	local srt = require("path/to/srt")
	```
4. 📃 Pass a plain text representation of the file
	```lua
	local captionsData = read("path/to/captions")
	local captionsObject = srt.new(captionsData)
	```
5. 🎬 Tell in what part of the media we are right now, since this is a generic pure lua function a better example is done with the [LÖVE2D framework](love2d.org), so we can get a real world example
	```lua
	local coolVideo = love.graphics.newVideo("path/to/cool/video.ogg")

	function love.update(dt)
		--A media source on love returns a number in seconds when the method :tell() is called
		--srt.lua takes the elapsed time in seconds so be aware of passing seconds as an integer
		local tellTime = coolVideo:tell()

		--We pass the time elapsed in seconds
		captionsObject:setTime(tellTime)

		--We tell srt.lua to apply changes, an optional argument is the delta so we account the lag
		--This method has been deprecated since setTime calls it internally but has not been removed
		--For the lag compesation feature that has. Beware of not using it alone since you could get
		--out of sync with the media being played with.
		captionsObject:update(dt)
	end
	```
6. 💎 Profit.
	(jokes aside once changes are applied we can ask for the text and use it,
	⚠ But take note that the result is raw from the file,
	so any gibberish has to be cleaned mannually r/NotMyJob)
	```lua
	function love.draw()
		--We draw the video
		love.graphics.draw(coolVideo)

		--We draw the subs
		love.graphics.setFont(48)
		local captionsText = captionsObject:getText()
		local windowWidth, windowHeight = love.graphics.getDimensions()
		love.graphics.print(captionsText, 0, windowHeight - 48)
	end

	```

 Here's an example:
 	![imagen](https://github.com/alejandro-alzate/srt-lua/assets/57909935/6f5318d8-b724-4e70-998a-e6330f870f5d)
