-----------------------------------------------------------------------------------------
--
-- death.lua - handles death scene and options...maybe saving player stats?
--
-----------------------------------------------------------------------------------------

local storyboard = require( "storyboard" )
storyboard.purgeOnSceneChange = true
local scene = storyboard.newScene()

-- include Corona's "widget" library
local widget = require "widget"

--------------------------------------------


-----------------------------------------------------------------------------------------
-- BEGINNING OF YOUR IMPLEMENTATION
-- 
-- NOTE: Code outside of listener functions (below) will only be executed once,
--		 unless storyboard.removeScene() is called.
-- 
-----------------------------------------------------------------------------------------

-- forward declarations and other locals
local menuBtn

-- 'onRelease' event listener for playBtn
local function onMenuBtnRelease()
  
  local options =
  {
    effect = "fade",
    time = 500,
  }

	-- go to level1.lua scene
	storyboard.gotoScene( "menu", options )
	
	return true	-- indicates successful touch
end


-- Called when the scene's view does not exist:
function scene:createScene( event )
	local group = self.view
  
  --purge level
  storyboard.removeScene( "level" )

  local bg = display.newImage( "images/bg-gameover.jpg" )
  bg.anchorX, bg.anchorY = 0.5,0.5
  bg.x, bg.y = display.contentCenterX, display.contentCenterY
  group:insert(bg)
  
  
	-- create a widget button (which will loads level1.lua on release)
	menuBtn = widget.newButton{
		label="",
		labelColor = { default={255}, over={128} },
		defaultFile="images/btn-back-to-menu-off.png",
		overFile="images/btn-back-to-menu-on.png",
		width=250, height=37,
		onRelease = onMenuBtnRelease	-- event listener function
	}
	menuBtn.x = display.contentWidth*0.5
	menuBtn.y = display.contentHeight - 75
	
	-- all display objects must be inserted into group
	group:insert( menuBtn )
  
end

-- Called immediately after scene has moved onscreen:
function scene:enterScene( event )
	local group = self.view
	


end

-- Called when scene is about to move offscreen:
function scene:exitScene( event )
	local group = self.view
	
	-- INSERT code here (e.g. stop timers, remove listenets, unload sounds, etc.)
	
end

-- If scene's view is removed, scene:destroyScene() will be called just prior to:
function scene:destroyScene( event )
	local group = self.view
	
  if menuBtn then
		menuBtn:removeSelf()	-- widgets must be manually removed
		menuBtn = nil
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