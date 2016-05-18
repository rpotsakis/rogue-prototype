-----------------------------------------------------------------------------------------
--
-- menu.lua
--
-----------------------------------------------------------------------------------------

local storyboard = require( "storyboard" )
local scene = storyboard.newScene()

-- include Corona's "widget" library
local widget = require "widget"

--------------------------------------------

-- forward declarations and other locals
local playBtn

-- 'onRelease' event listener for playBtn
local function onPlayBtnRelease()
	
	local savedPlayerStats = {
		health = 3,
		score = 1337,
		gems = 0,
		stamina = 27,
		staminaMax = 27
	}

	local options =
	{
		effect = "fade",
		time = 100,
		params =
		{
			var1 = "custom data",
			sample_var = 123,
			currentLevel = 0,
			playerStats = savedPlayerStats
		}
	}

	-- go to level1.lua scene
	storyboard.gotoScene( "intro", options )

	return true	-- indicates successful touch
end

-----------------------------------------------------------------------------------------
-- BEGINNING OF YOUR IMPLEMENTATION
-- 
-- NOTE: Code outside of listener functions (below) will only be executed once,
--		 unless storyboard.removeScene() is called.
-- 
-----------------------------------------------------------------------------------------

-- Called when the scene's view does not exist:
function scene:createScene( event )
	local group = self.view

	display.setDefault( "background", 0.078, 0.086, 0.075 )

	print( "dim: " .. display.contentWidth .. "  x " .. display.contentHeight )
	print( "pixels: " .. display.pixelWidth .. "  x " .. display.pixelHeight )

	-- display a background image
	local background = display.newImage( "images/bg-menu.jpg" )
	background.anchorX, background.anchorY = 0.5,0.5
	background.x, background.y = display.contentWidth/2, display.contentHeight/2
	
	-- create/position logo/title image on upper-half of the screen
	--local titleLogo = display.newImageRect( "logo.png", 264, 42 )
	--v1 titleLogo:setReferencePoint( display.CenterReferencePoint )
	--titleLogo.x = display.contentWidth * 0.5
	--titleLogo.y = 100
	
	-- create a widget button (which will loads level1.lua on release)
	playBtn = widget.newButton{
		label="",
		labelColor = { default={255}, over={128} },
		defaultFile="images/btn-play-off.png",
		overFile="images/btn-play-on.png",
		width=225, height=37,
		onRelease = onPlayBtnRelease	-- event listener function
	}
	-- v1 playBtn:setReferencePoint( display.CenterReferencePoint )
	playBtn.x = display.contentWidth*0.5
	playBtn.y = display.contentHeight - 50
	
	-- all display objects must be inserted into group
	group:insert( background )
	group:insert( playBtn )
end

-- Called immediately after scene has moved onscreen:
function scene:enterScene( event )
	local group = self.view
	
	-- INSERT code here (e.g. start timers, load audio, start listeners, etc.)
	
end

-- Called when scene is about to move offscreen:
function scene:exitScene( event )
	local group = self.view
	
	-- INSERT code here (e.g. stop timers, remove listenets, unload sounds, etc.)
	
end

-- If scene's view is removed, scene:destroyScene() will be called just prior to:
function scene:destroyScene( event )
	local group = self.view
	
	if playBtn then
		playBtn:removeSelf()	-- widgets must be manually removed
		playBtn = nil
	end
end

-----------------------------------------------------------------------------------------
-- END OF YOUR IMPLEMENTATION
-----------------------------------------------------------------------------------------

-- "createScene" event is dispatched if scene's view does not exist
scene:addEventListener( "createScene", scene )

-- "enterScene" event is dispatched whenever scene transition has finished
scene:addEventListener( "enterScene", scene )

-- "exitScene" event is dispatched whenever before next scene's transition begins
scene:addEventListener( "exitScene", scene )

-- "destroyScene" event is dispatched before view is unloaded, which can be
-- automatically unloaded in low memory situations, or explicitly via a call to
-- storyboard.purgeScene() or storyboard.removeScene().
scene:addEventListener( "destroyScene", scene )

-----------------------------------------------------------------------------------------

return scene