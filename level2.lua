-----------------------------------------------------------------------------------------
--
-- level2.lua
--
-----------------------------------------------------------------------------------------

local storyboard = require( "storyboard" )
storyboard.purgeOnSceneChange = true
local scene = storyboard.newScene()

-- include Corona's "physics" library
local physics = require "physics"
physics.start(); physics.pause()

local joystickClass = require( "joystick" )
local ceramic = require("Ceramic")
local hud = require("hud")

--------------------------------------------

-- forward declarations and other locals
local screenW, screenH, halfW = display.contentWidth, display.contentHeight, display.contentWidth*0.5

local hero, map

-----------------------------------------------------------------------------------------
-- BEGINNING OF YOUR IMPLEMENTATION
-----------------------------------------------------------------------------------------

-- Called when the scene's view does not exist:
function scene:createScene( event )
	local group = self.view
  
  local hudDisplay = hud.displayHud()
  
  
	-- JSON Encoding --
  map = ceramic.buildMap("maps/map-1.json")
  map.setCameraDamping(10) -- Give a bit of fluidity to the movement
  
  map.layer['Physics'].isVisible = false;
  
  ------------------------------------------------------------------------------
	-- Create Player
	------------------------------------------------------------------------------
  hero = display.newImage("assets/player-1.png")
  hero.x = (display.contentWidth / 2) + 100
  hero.y = 250
  --print(map.layer["Physics"])
  --hero.x, hero.y=map.tilesToPixels(map.layer["Physics"].playerSpawnPosition)
  map.layer['meta']:insert(hero)
  
	physics.addBody(hero, "fixed",
		{bounce=0, friction=0.5}, -- The collisions body
		{isSensor=true, shape={-12,32, 12,32, 12,33, -12,33}} -- The grounding body
	)
	hero.isFixedRotation=true
  hero.gravityScale = 0.0
  
  heroMaxX = display.contentWidth - 50
  heroMinX = 50
  heroMaxY = display.contentHeight - 50
  heroMinY = 50
  
  map.setCameraFocus(hero)
    map.setCameraBounds(
		display.contentCenterX, map("mapWidth")*map("tileWidth")-display.contentCenterX,
		display.contentCenterY, map("mapHeight")*map("tileHeight")-display.contentCenterY
	)
  
  --[[
  local function dragMap(event)
          if "began"==event.phase then
                  map._x, map._y=event.x/map.xScale-map.viewX, event.y/map.yScale-map.viewY
          elseif "moved"==event.phase then
                  map.viewX, map.viewY=event.x/map.xScale-map._x, event.y/map.yScale-map._y
                  map.render()
          end
  end

  Runtime:addEventListener("touch", dragMap)
  --]]
        
  -- JOYSTICK IMPLEMENTATION
  joystick = joystickClass.newJoystick{}
  joystick.z = 99
  
  local function joystickMove()
    --print( joystick.joyX , joystick.joyY , joystick.joyAngle , joystick.joyVector )
    local stepX = 5
    local stepY = 5
    local newX, newY
    
    -- Handle Horizontal movement
    if(joystick.joyX ~= false) then
      --map.viewX = map.viewX + (stepX * joystick.joyX)
      if(hero.x <= heroMaxX and hero.x >= heroMinX) then
        newX = hero.x + (stepX * joystick.joyX);
        --[[
        if(newX < heroMinX) then
          newX = heroMinX
        elseif(newX > heroMaxX) then
          newX = heroMaxX
        end
         --]]
        hero.x = newX
       end
       
       
        hero.x = hero.x + (stepX * joystick.joyX);
       
       if(hero.x == heroMinX or hero.x == heroMaxX) then
         --map.viewX = map.viewX - (stepX * joystick.joyX)
       end
    end
    
    if(joystick.joyY ~= false) then
      --map.viewY = map.viewY + (stepY * joystick.joyY)
      if(hero.y <= heroMaxY and hero.y >= heroMinY) then
        newY = hero.y + (stepY * joystick.joyY)
        --[[
        if(newY < heroMinY) then
          newY = heroMinY
        elseif(newY > heroMaxY) then
          newY = heroMaxY
        end
        --]]
        hero.y = newY
       end
       
       hero.y = hero.y + (stepY * joystick.joyY)
       
       if(hero.y == heroMinY or hero.y == heroMaxY) then
         -- map.viewY = map.viewY - (stepY * joystick.joyY)
       end
    end
    
    map.render()
    map.updateCamera()
  end
  Runtime:addEventListener( "enterFrame" , joystickMove )
  
  
  -- Local Collision
  --hero.collision = onLocalCollision
  function hero:collision(event) 
    print('collision')
    
    if(event.other.collisionType ~= nil) then
      print( "began: " .. event.name .. " type: " .. event.other.collisionType)
      
      if(event.other.collisionType == 'portal') then 
        
       end
     end
  end
  hero:addEventListener("collision", hero)

   
  local function onCollision( event )
          if ( event.phase == "began" ) then
   
                  print( "began: " .. event.name )
   
          elseif ( event.phase == "ended" ) then
   
                  print( "ended: " .. event.name )
   
          end
  end
   
  Runtime:addEventListener( "collision", onCollision )
  
  hudDisplay:toFront()
end

-- Called immediately after scene has moved onscreen:
function scene:enterScene( event )
	local group = self.view

  -- remove previous scene's view
	--storyboard.purgeScene( "level1" )
  
	physics.start()
	
end

-- Called when scene is about to move offscreen:
function scene:exitScene( event )
	local group = self.view
	
	physics.stop()
	
  
end

-- If scene's view is removed, scene:destroyScene() will be called just prior to:
function scene:destroyScene( event )
	local group = self.view
	
	package.loaded[physics] = nil
	physics = nil
  
  --storyboard.purgeScene( "level2" )
end


-- collision

local function onLocalCollision(self, event)
    print("collision")
    if event.phase == "began" then
        print("Collision began")
    elseif event.phase == "ended" then
        print("Collision ended")
    end
end

function onGlobalCollision(event)
    if(event.phase == "began") then
        --print( "Global report: " .. event .. " & " .. event .. " collision began" )
    elseif(event.phase == "ended") then
        --print( "Global report: " .. event .. " & " .. event .. " collision ended" )
    end
    --print( "**** " .. event.element1 .. " -- " .. event.element2 )
end

function onPostCollision(event)
    print("postCollision")
end


-- Global Collision
Runtime:addEventListener("collision", onGlobalCollision)
Runtime:addEventListener("postCollision", onPostCollision)

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