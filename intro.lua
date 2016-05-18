-----------------------------------------------------------------------------------------
--
-- reset.lua - handles loading between levels
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

-- Called when the scene's view does not exist:
function scene:createScene( event )
	local group = self.view
  local intro

  --purge level
  storyboard.purgeScene( "menu" )

  if string.sub(system.getInfo("model"),1,2) == "iP" and display.pixelHeight > 960 then
    intro = display.newImage( "images/intro-loading-568h.png" )
  else
    intro = display.newImage( "images/intro-loading.png" )
  end
  intro.anchorX, intro.anchorY = 0.5,0.5
  intro.x, intro.y = display.contentCenterX, display.contentCenterY
  group:insert(intro)

  local loadMsg = display.newText("Loading...", display.contentCenterX, display.contentHeight - 25)
  group:insert(loadMsg)
  
end

-- Called immediately after scene has moved onscreen:
function scene:enterScene( event )
	local group = self.view
	
  -- vars passed in from other scene
	local params = event.params
  print("reset level " .. params.currentLevel)
  
	--purge level
  --storyboard.purgeScene( "level" )
  
  --go back to level, by loading it from scratch
  local options =
  {
    effect = "fade",
    time = 500,
    params = params
  }
  --storyboard.gotoScene( "level", options)
	
  local loadNext = function()

    local options =
    {
      effect = "fade",
      time = 500,
      params = params
    }
    storyboard.gotoScene( "level", options )
  end
  timer.performWithDelay(2000, loadNext)
  
end

-- Called when scene is about to move offscreen:
function scene:exitScene( event )
	local group = self.view
	
	-- INSERT code here (e.g. stop timers, remove listenets, unload sounds, etc.)
	
end

-- If scene's view is removed, scene:destroyScene() will be called just prior to:
function scene:destroyScene( event )
	local group = self.view
	
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