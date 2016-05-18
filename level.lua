-----------------------------------------------------------------------------------------
--
-- level1.lua
--
-----------------------------------------------------------------------------------------
system.activate("multitouch")

local storyboard = require( "storyboard" )
--storyboard.purgeOnSceneChange = true
local scene = storyboard.newScene()

-- include Corona's "physics" library
local physics = require "physics"
physics.start()
physics.setScale(140)
physics.setGravity(0, 0)
--physics.setDrawMode("hybrid")
physics.pause()

display.setDefault("minTextureFilter", "nearest")
display.setDefault("magTextureFilter", "nearest")

local joystickClass = require( "joystick" )
local ceramic = require("Ceramic")
local hud = require("hud")
local enemySentryClass = require("enemySentry")
local enemyDroneClass = require("enemyDrone")
local enemyShooterClass = require("enemyShooter")
local enemyObstacleClass = require("enemyObstacle")
--------------------------------------------

-- forward declarations and other locals
local runtime = 0
local screenW, screenH, halfW = display.contentWidth, display.contentHeight, display.contentWidth*0.5

local hero, heroHalo, map, joystick, currentLevel, playerStats, myTransitions, myTimers, mySounds
local heroAttackDamage = 1 -- maybe increase this with rank or new weapon?

-----------------------------------------------------------------------------------------
-- ANIMATIONS
-----------------------------------------------------------------------------------------
local playerSheetData = { width=64, height=64, numFrames=28, sheetContentWidth=256, sheetContentHeight=448 }
local playerSheet = graphics.newImageSheet( "sprites/player-sprite.png", playerSheetData )
local playerAnimData = {
  
  { name="standing", frames={ 1 }, time=250, loopCount=1 },
  { name="upRun", frames={ 1,2 }, time=250, loopCount=0 },
  { name="downRun", frames={ 3,4 }, time=250, loopCount=0 },
  { name="rightRun", frames={ 5,6,7 }, time=250, loopCount=0 },
  { name="leftRun", frames={ 9,10,11 }, time=250, loopCount=0 },
  { name="attack", frames={ 13,14,15 }, time=350, loopCount=2 },
  { name="teleport", frames={ 21,22,23,24,25,26,27 }, time=2000, loopCount=1 }

}


local btnAttackSheetData = { width=88, height=88, numFrames=2, sheetContentWidth=176, sheetContentHeight=88 }
local btnAttackSheet = graphics.newImageSheet( "sprites/btn-attack.png", btnAttackSheetData )
local btnAttackAnimData = {
  { name="off", frames={ 1 }, time=250, loopCount=1 },
  { name="on", frames={ 2 }, time=250, loopCount=1 }
}

local enemyDeathSheetData = { width=64, height=64, numFrames=5, sheetContentWidth=192, sheetContentHeight=128 }
local enemyDeathSheet = graphics.newImageSheet( "sprites/explosion.png", enemyDeathSheetData )
local enemyDeathAnimData = {
  { name="explode", frames={ 1,2,3,4,5 }, time=350, loopCount=1 }
}


local monoSheetData = { width=64, height=96, numFrames=9, sheetContentWidth=192, sheetContentHeight=288 }
local monoSheet = graphics.newImageSheet( "sprites/monolith.png", monoSheetData )
local monoAnimData = {
  
  { name="empty", frames={ 1 }, time=250, loopCount=0 },
  { name="chargeup", frames={ 1,2,3,4,5,6,7,8,9 }, time=2000, loopCount=1 }

}

-----------------------------------------------------------------------------------------
-- BEGINNING OF YOUR IMPLEMENTATION
-----------------------------------------------------------------------------------------

-- Called when the scene's view does not exist:
function scene:createScene( event )
	local group = self.view
  
  physics.start()
  myTransitions = {}
  myTimers = {}
  mySounds = {}
  runtime = 0
  
  -- test for passing data between scenes, ie health, loot, score, etc
  local params = event.params
  
  print(" CREATE scene ")
  print( "param " .. params.var1 ) -- "custom data"
  print( "level " .. params.currentLevel ) -- 123
  currentLevel = 2 --params.currentLevel
  playerStats = params.playerStats
  
  -- Init HUD with stats
  hud.setHealth(playerStats.health)
  hud.setScore(playerStats.score)
  hud.setStamina(playerStats.stamina)
  local hudDisplay = hud.displayHud()
  group:insert(hudDisplay)

	-- JSON Encoding --
  map = ceramic.buildMap("maps/map-" .. currentLevel .. ".json")
  map.setCameraDamping(1) -- fast to start
  group:insert(map)
  map.layer['Physics'].isVisible = false;
  
  ------------------------------------------------------------------------------
	-- Create Player
	------------------------------------------------------------------------------
  hero = display.newSprite( playerSheet, playerAnimData ) --.newImage("assets/player-1.png")
  hero.x = display.contentWidth / 2
  hero.y = display.contentHeight - 50
  hero.isAttacking = false
  hero.isDead = false
  hero.stamina = playerStats.stamina
  hud.setStaminaMax(playerStats.staminaMax)

  heroHalo = display.newCircle(hero.x, hero.y, display.contentWidth)
  heroHalo:setFillColor(1, 0.2, 0.2)
  heroHalo.alpha = 0.0
  heroHalo.collisionType = "halo"
  
  --[[
  print("------------------------------")
  for key,value in pairs(map.layer["Player"].object[1]) do
      print( key, value )
  end
  --]]
  
  --spawnPoint = ceramic:findObject("playerSpawnPosition",map.data)
  local spawnPoint = map.layer["Player"].object[1]
  
  --print(map.layer["Player"].object[1])
  --print ("Spawn at ", spawnPoint.x )
  
  map.layer['meta']:insert(hero)
  map.layer['meta']:insert(heroHalo)
  
	physics.addBody(hero, "fixed",
		{bounce=0, friction=0.5, radius = 25}, -- The collisions body
		{isSensor=true, shape={-12,32, 12,32, 12,33, -12,33}} -- The grounding body
	)
	hero.isFixedRotation=true
  hero.gravityScale = 0.0
  
  physics.addBody(heroHalo, "fixed",
		{bounce=0, friction=0.0, radius=display.contentWidth, isSensor=true, name = "heroHalo" } -- The grounding body
	)
  heroHalo.isFixedRotation=true
  heroHalo.gravityScale = 0.0
  
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
  map.setCameraBounds( {
      xMin = display.contentCenterX, xMax = map("mapWidth")*map("tileWidth")-display.contentCenterX,
      yMin = display.contentCenterY, yMax = map("mapHeight")*map("tileHeight")-display.contentCenterY
    }
	)
  --]]
    

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
  joystick = joystickClass.newJoystick{ 
    position_x = 75,
    position_y = display.contentHeight - 75,
    outerImage="images/joystick-outer.png", 
    innerImage="images/joystick-center.png"
  }
  joystick.alpha = 0.5
  group:insert(joystick)
  
  
  local function joystickMove()
    --print( joystick.joyX , joystick.joyY , joystick.joyAngle , joystick.joyVector )
    local stepX = 5
    local stepY = 5
    local newX, newY = 0,0
    local animToPlay = "standing"
    local animX = 0
    
    -- Handle Horizontal movement
    if(joystick.joyX ~= false and joystick.joyX ~= nil) then
      --map.viewX = map.viewX + (stepX * joystick.joyX)
      

      if(joystick.joyX > 0) then
        animToPlay = "rightRun"
      elseif(joystick.joyX < 0) then
        animToPlay = "leftRun"
      end
      animX = joystick.joyX
      
      newX = hero.x + (stepX * joystick.joyX)
      hero.x = newX
      heroHalo.x = hero.x
        
    end
    
    if(joystick.joyY ~= false and joystick.joyY ~= nil) then
      --map.viewY = map.viewY + (stepY * joystick.joyY)
      
      if(joystick.joyY > 0 and joystick.joyY > animX) then
        animToPlay = "downRun"
      elseif(joystick.joyX < 0 and joystick.joyY < animX) then
        animToPlay = "upRun"
      end
      
      newY = hero.y + (stepY * joystick.joyY)
      hero.y = newY
      heroHalo.y = hero.y
       
    end
    
    if(joystick.joyY ~= false and joystick.joyX ~= false) then
      -- map.render() /update calls render
      map.updateCamera()
    end

    if(hero ~= nil and hero.isDead == false and hero.isAttacking == false and hero.sequence ~= animToPlay) then 
      hero:setSequence( animToPlay )
      hero:play()
    end
  end
  Runtime:addEventListener( "enterFrame" , joystickMove )
  
  -- ATTACK BUTTON
		local attackButton = display.newSprite( btnAttackSheet, btnAttackAnimData ) --display.newCircle( display.contentWidth - 50 , display.contentHeight - 50 , 25 )
    attackButton.x, attackButton.y = display.contentWidth - 75 , display.contentHeight - 60
    attackButton.alpha = 0.5
		group:insert( attackButton )
		
    local function attackCompleted(obj)
      print("attackCompleted")
      hero.rotation = 0
      canAttack = true
      isAttacking = false
    end
    
    local function enemyAttackCompleted(obj)
      print("enemyAttackCompleted")
      obj.xScale = 1
      obj.yScale = 1
      --obj:removeSelf()
      obj.isVisible = false
      timer.cancel(obj)
      
      local function removeObj()
        obj:removeSelf()
      end
      timer.performWithDelay( 1, removeObj, 1)
    end
  
    local function attackButtonPressed (event)
      print("button pressed")
      
      if(event.phase == "began" or event.phase == "down") then

        if(event.target ~= nil) then
          event.target:setSequence( "on" )
          event.target:play()
        end

        --transition.to( hero, { time=1000, rotation=360, onComplete=attackCompleted } )
        canAttack = false

        if(hero.isAttacking == false and hero.stamina > 5) then
          hero.isAttacking = true
          hero.stamina = hero.stamina - 5
          if(hero.stamina < 0) then hero.stamina = 0 end
          --hud.setStamina(hero.stamina)
          --hud.updateStaminaDisplay()

          -- Juicyness
          audio.play(mySounds["spinAttack"])

          hero:setSequence( "attack" )
          hero:play()
        end
      elseif(event.phase == "ended") then
        print("button ended")

        -- target is nil if key pressed
        if(event.target ~= nil) then
          event.target:setSequence( "off" )
          event.target:play()
        end
      end
    end
    attackButton:addEventListener( "touch" , attackButtonPressed )
    
    
    -- Called when a key event has been received.
    local function onKeyEvent( event )
        -- Print which key was pressed down/up to the log.
        local message = "Key '" .. event.keyName .. "' was pressed " .. event.phase
        --print( message )
        
        local stepX = 10
        
        if(event.phase == "down") then
          if(event.keyName == "w") then
            newY = hero.y - (stepX)
          elseif(event.keyName == "s") then
            newY = hero.y + (stepX)
          else
            newY = hero.y
          end
          
          if(event.keyName == "a") then
            newX = hero.x - (stepX)
          elseif(event.keyName == "d") then
            newX = hero.x + (stepX)
          else 
            newX = hero.x
          end
          
          if(event.keyName == "p") then 
            attackButtonPressed(event)
          end
        end
        
        hero.x, heroHalo.x = newX, newX
        hero.y, heroHalo.y = newY, newY
        
        map.updateCamera()
        

        -- If the "back" key was pressed on Android, then prevent it from backing out of your app.
        if (event.keyName == "back") and (system.getInfo("platformName") == "Android") then
            return true
        end

        -- Return false to indicate that this app is *not* overriding the received key.
        -- This lets the operating system execute its default handling of this key.
        return false
    end

    -- Add the key event listener.
    Runtime:addEventListener( "key", onKeyEvent );
    

    -------------------------------------------------------------------------------------
    -- SPRITE ANIM LISTENERS
    local function heroSpriteListener( event )
      if ( event.phase == "ended" ) then

        local thisSprite = event.target  --"event.target" references the sprite

        if(thisSprite == hero and hero.isAttacking) then
          hero.isAttacking = false
          canAttack = true
        end

      end
    end
    hero:addEventListener( "sprite", heroSpriteListener )  --add a sprite listener to your sprite
    



  -- Local Collision
  -- hero.collision = onLocalCollision
  function hero:collision(event) 
    --print('hercollision: ' .. event.phase)
    
    if ( event.phase == "began" ) then
      --print( "hero coll began: " .. event.name )
     
      if(event.other.collisionType ~= nil) then
        --print( "began: " .. event.name .. " type: " .. event.other.collisionType)
        
          
        if(event.other.collisionType == 'monolith') then 
          -- MONOLITH
          local chipCount = hud.getChipCount()
          print( "monolith 3 of " .. chipCount)

          if(chipCount == 3) then

            local runLevelComplete = function()
              event.other.isBodyActive = false
              heroWon()
              event.other:setSequence( "chargeup" )
              event.other:play()
            end
            timer.performWithDelay( 1, runLevelComplete, 1)
            
          else
            --msg
          end
          
        elseif(event.other.collisionType == 'portal') then 
          -- PORTAL 
          --create function to hide object
          local hideObject = function()
              event.other.isBodyActive = false
              --event.other.isVisible = false
              joystick.joystickStop()
              Runtime:removeEventListener( "enterFrame" , joystickMove )
          end
          timer.performWithDelay( 1, hideObject, 1 )
          
        elseif(event.other.collisionType == 'enemy') then 
          -- ENEMY 
          --print("began ENEMY " .. event.other.x)
          local enemyGotHit = true
          local heroGotHit = true
           
          if(event.other.enemyType ~= nil) then 
               
              if(event.other.enemyType == "sentry") then
                enemyGotHit = enemySentryClass.checkCollision(event.other, hero.x, hero.y)
              elseif(event.other.enemyType == "drone") then
                enemyGotHit = enemyDroneClass.checkCollision(event.other, hero.x, hero.y)
              elseif(event.other.enemyType == "obstacle" and event.other.spawnType == "spike") then
                enemyGotHit = false
                print("== SPIKE ==", event.other.frame)

                -- check if the spikes are out
                if(event.other.sequence == "safe") then
                  heroGotHit = false
                end
              elseif(event.other.enemyType == "projectile") then
                enemyGotHit = false
              end
               
          end
           
          print("-------------------------------")
          print("enemyGotHit ", enemyGotHit)
          print("isAttacking ", hero.isAttacking)
          print("EnemyType ", event.other.enemyType)
          print("-------------------------------")
           
           
          if(hero.isAttacking and enemyGotHit) then
            local enemyHealth = 0

            -- manage enemy health
            --[[ enemies are 1 hit for now
            if(event.other.enemyType ~= nil) then 
              if(event.other.enemyType == "sentry") then
                enemySentryClass.enemyHit(heroAttackDamage)
                enemyHealth = enemySentryClass.getEnemyHealth()
              elseif(event.other.enemyType == "drone") then
                enemyDroneClass.enemyHit(heroAttackDamage)
                enemyHealth = enemyDroneClass.getEnemyHealth()
              end
            else
              -- don't expect this to happen, but ...
              enemyHealth = 0
            end
            --]]

            local disableEnemy = function()

              local thisDeath = runEnemyDeath(event.other)
              map.layer['meta']:insert(thisDeath)

              event.other.isBodyActive = false
              event.other:removeSelf()
              --transition.to(event.other, { time = 500, yScale = 1.25, xScale = .75, onComplete=enemyAttackCompleted } )
              print("> enemy timer id", event.other.timerId)
              -- remove object's timer, if it has one
              if(event.other.timerId ~= nil) then
                timer.cancel( event.other.timerId )
              end

            end

            -- enemy is dead, run death routine
            if(enemyHealth == 0) then
              timer.performWithDelay( 1, disableEnemy, 1 )
            end
-- GOD MODE
          elseif(heroGotHit) then
            -- knock back hero
            local knockBack = function()

              if (event.other.y < hero.y) then
                -- object collided with was on bottom of hero
                hero.y = hero.y + 50
              elseif (event.other.y > hero.y) then
                -- object collided with was on top of hero
                hero.y = hero.y - 50
              end
              heroDamage()

            end
            timer.performWithDelay(1, knockBack)

            if(event.other.enemyType == "projectile") then
              -- remove projectile
              local disableProjectile = function()
                event.other.isBodyActive = false
                event.other.isVisible = false
                --  removed oncomplete: event.other:removeSelf()
              end
              timer.performWithDelay( 1, disableProjectile, 1 )
            end
          end
        elseif(event.other.collisionType == 'gem') then 
           -- GEM
           local disableGem = function()
            event.other.isBodyActive = false
           end
           timer.performWithDelay( 1, disableGem, 1 )
            
           transition.to(event.other, { time = 250, yScale = .5, xScale = .5, onComplete=gemCollectCompleted } )
        elseif(event.other.collisionType == 'chip') then 
          -- CHIPPP!
          --print( "chip: ", event.other.chipId )
          local collectChip = function()
            event.other.isBodyActive = false
            event.other.isVisible = false

            hud.updateChipDisplay(event.other.chipId)
            audio.play( mySounds["chipAcquired"] )
          end
          timer.performWithDelay( 1, collectChip, 1 )

          -- transition.to(event.other, { time = 250, yScale = .5, xScale = .5, onComplete=gemCollectCompleted } )
        end
      end
       
    elseif ( event.phase == "ended" ) then

       --print( "hero coll ended: " .. event.name )
       
       if(event.other.collisionType ~= nil) then
        --print( "ended: " .. event.name .. " type: " .. event.other.collisionType)
        
        if(event.other.collisionType == 'portal') then 
          -- go to level2.lua scene
          --print('portal ended')
          local loadNext = function()
            currentLevel = currentLevel + 1
            params.currentLevel = currentLevel
            
            local options =
            {
              effect = "fade",
              time = 500,
              params = params
            }
            storyboard.gotoScene( "reset", options )
          end
          timer.performWithDelay(100, loadNext)
          
         elseif(event.other.collisionType == 'enemy') then 
           -- ENEMY 
           --print("ended ENEMY")
           
           if(hero.isAttacking) then
            
           else
            -- moved
             --heroDamage()
           end
         elseif(event.other.collisionType == 'gem') then 
           -- GEM
           
         end
       end
    end
  end
  hero:addEventListener("collision", hero)
  
  -----------------------------------------------------------
  --  EVENT TO SPAWN ENEMIES and any other map triggers
  -----------------------------------------------------------
  function heroHalo:collision(event) 
    
    if ( event.phase == "began" ) then
      --print( "hero halo began: " .. event.name )
      
      if(event.other ~= nil and event.other.collisionType ~= nil) then
        --print( "halo begin: " .. event.name .. " type: " .. event.other.collisionType)
        
        if(event.other.collisionType == 'halo') then 

        elseif(event.other.collisionType == "monolithSpawn") then
          print("spawn monolith")

          local spawnMonolith = function()
            event.other.isBodyActive = false
            event.other.isVisible = false

            local monolith = display.newSprite( monoSheet, monoAnimData )
            monolith.x, monolith.y = event.other.x + (monolith.width/2), event.other.y - (event.other.height/4)
            monolith.collisionType = "monolith"

            physics.addBody(monolith, "static",
              {bounce=0, friction=0.2, isSensor=false, name = "monolith" }
            )
            monolith.isFixedRotation=true

            map.layer['meta']:insert(monolith)
          end
          timer.performWithDelay(1, spawnMonolith, 1)
        elseif(event.other.collisionType == 'enemy') then

        elseif(event.other.collisionType == 'enemySpawn') then 
          if(event.other.enemyType ~= nil) then
            --print("spawn baddy", event.other.enemyType)
            
            if(event.other.enemyType == "sentry") then
              -- spawn a new SENTRY --
              local spawnEnemy =  function()
                
                local subType = nil
                if(event.other.subType ~= nil and event.other.subType ~= "") then 
                  subType = event.other.subType
                end

                local baddy = enemySentryClass.newEnemy(event.other.x, event.other.y, event.other.spawnType, subType)
                map.layer['meta']:insert(baddy)
                baddy.x, baddy.y = event.other.x, event.other.y
                
                if(event.other.wayPoints) then 
                  baddy.wayPoints = event.other.wayPoints
                end
                
                --print(baddy.myParam .. " " .. baddy.pathIndex)
                event.other.isBodyActive = false
                
                if(baddy.wayPoints) then
                  enemyPathStart(baddy)
                end
                
                physics.addBody(baddy, "fixed", {bounce=0, friction=0.5, shape=baddy.shape, isSensor=true})
                baddy.gravityScale = 0.0
              end
              timer.performWithDelay(1, spawnEnemy, 1)
            elseif(event.other.enemyType == "drone") then
              -- spawn a new DRONE --
              local spawnDrone =  function()
                
                local baddy = enemyDroneClass.newEnemy(event.other.x, event.other.y)
                map.layer['meta']:insert(baddy)
                baddy.x, baddy.y = event.other.x, event.other.y
                --group:insert(baddy)
                
                event.other.isBodyActive = false
                
                if(#baddy.wayPoints > 0) then
                  enemyPathStart(baddy)
                else
                  -- set attack mode
                  local enemyTrack =  function()
                    if(hero.x ~= nil and baddy.x ~= nil) then
                      baddy.x = baddy.x - ((baddy.x - hero.x) * 0.01)
                      baddy.y = baddy.y - ((baddy.y - hero.y) * 0.01)
                    end
                  end
                  local enemyTimerId = timer.performWithDelay(1, enemyTrack, 0)
                  event.other.timerId = enemyTimerId
                end
                
                physics.addBody(baddy, "fixed", {bounce=0, friction=0.5, shape=baddy.shape, isSensor=true})
                baddy.gravityScale = 0.0
              end
              timer.performWithDelay(1, spawnDrone, 1)
            elseif(event.other.enemyType == "shooter") then
            
              -- spawn a new SHOOTER --
              local spawnShooter =  function()
                
                local baddy = enemyShooterClass.newEnemy(event.other.x, event.other.y, event.other.spawnType)
                map.layer['meta']:insert(baddy)
                baddy.x, baddy.y = event.other.x, event.other.y
                --group:insert(baddy)
                
                event.other.isBodyActive = false
                
                if(#baddy.wayPoints > 0) then
                  enemyPathStart(baddy)
                else
                  -- start shooting
                  local shooterLoop = function ()
                    --print("-- TRIGGER --", hero.x, hero.y)
                    local proj = enemyFireProjectile(baddy)
                    if(proj ~= nil) then 
                      map.layer['meta']:insert(proj)
                    end
                  end
                  local enemyTimerId = timer.performWithDelay(5000, shooterLoop, 0)
                  baddy.timerId = enemyTimerId
                  table.insert(myTimers, enemyTimerId)
                end
                
                physics.addBody(baddy, "fixed", {bounce=0, friction=0.5, shape=baddy.shape, isSensor=true})
                baddy.gravityScale = 0.0

              end -- /spawn shooter
              timer.performWithDelay(1, spawnShooter, 1)
            
            elseif(event.other.enemyType == "obstacle") then
              -- spawn a new OBSTACLE --

              local spawnObstacle =  function()
                
                local baddy = enemyObstacleClass.newEnemy(event.other.x, event.other.y, event.other.spawnType)
                map.layer['meta']:insert(baddy)
                baddy.x, baddy.y = event.other.x + (baddy.width/2), event.other.y + (baddy.height/2)
                --group:insert(baddy)
                
                -- disable spawn point
                event.other.isBodyActive = false
                
                physics.addBody(baddy, "fixed", {bounce=0, friction=0.5, shape=baddy.shape, isSensor=true})
                baddy.gravityScale = 0.0

                -- this function cycles spike animation
                local runSpikes = function()
                  if(baddy) then
                    if(baddy.sequence == "safe") then
                      baddy:setSequence( "moving" )
                    elseif(baddy.sequence == "moving") then
                      baddy:setSequence( "movingIn" )
                    else 
                      baddy:setSequence( "safe" )
                    end
                    baddy:play()
                  end
                  --print("== RUN runSpikes ==")
                end
                local t = timer.performWithDelay( 2500, runSpikes, 0)
                table.insert(myTimers, t)
              end
              timer.performWithDelay(1, spawnObstacle, 1)

            end -- if enemyType
          end -- if 
        end -- if collisionType
         
      end
       
    elseif ( event.phase == "ended" ) then

       --print( "hero halo ended: " .. event.name )
       
       if(event.other.collisionType ~= nil) then
        --print( "halo ended: " .. event.name .. " type: " .. event.other.collisionType)
        
        if(event.other.collisionType == 'halo') then 
         
          
         elseif(event.other.collisionType == 'enemy') then 
          
         end
       end
    end
  end
  heroHalo:addEventListener("collision", heroHalo)


  -- any collision? do i need/care?
  local function onCollision( event )
    if ( event.phase == "began" ) then
      
      
        --print( "began: " .. event.name )
      
    elseif ( event.phase == "ended" ) then
   
      --print( "ended: " .. event.name )
    end
  end
   
  Runtime:addEventListener( "collision", onCollision )
  
  
  -- reorg view
  hudDisplay:toFront()
  hero.x, hero.y = spawnPoint.x, spawnPoint.y
  heroHalo.x, heroHalo.y = spawnPoint.x, spawnPoint.y
  map.updateCamera()

  -- Music Setup START
  local bgMusic = audio.loadStream("audio/bg-battle-long.aifc")
  local bgMusicChannel = audio.play( bgMusic, { channel=1, loops=-1, fadein=5000 }  )
  audio.setVolume( 0.5, {channel=1} )

  local soundHandle = audio.loadSound( "audio/enemy-explosion.caf" )
  mySounds["enemyExplosion"] = soundHandle

  soundHandle = audio.loadSound( "audio/chip-acquired.caf" )
  mySounds["chipAcquired"] = soundHandle

  soundHandle = audio.loadSound( "audio/spin-attack.caf" )
  mySounds["spinAttack"] = soundHandle

  soundHandle = audio.loadSound( "audio/teleport.caf" )
  mySounds["teleport"] = soundHandle
  -- Music Setup END

  
  print("hero pos ", hero.x, hero.y)
  print("map pos ", map.viewX, map.viewY)
end 
-----------------------------------------------------------------------------------------
-- END createScene...one big mofo
-----------------------------------------------------------------------------------------



-- Called immediately after scene has moved onscreen:
function scene:enterScene( event )
	local group = self.view
  print("entered scene")
  
	--physics.start()
  
  map.setCameraDamping(10) -- Give a bit of fluidity to the movement
end

-- Called when scene is about to move offscreen:
function scene:exitScene( event )
	local group = self.view
	
	physics.stop()
	
  --on scene clear
  if(myTransitions ~= nil) then 
    for i = 1, #myTransitions do 
      transition.cancel(myTransitions[i])
      table.remove(myTransitions, i)
    end
  end
  myTransitions = nil

  print("> Cancel timers:", #myTimers)
  if(myTimers ~= nil) then 
    for i = 1, #myTimers do 
      print("> Timer:", myTimers[i])

      timer.cancel(myTimers[i])
    end
  end
  myTimers = nil
  
  print('exiting scene')
end

-- If scene's view is removed, scene:destroyScene() will be called just prior to:
function scene:destroyScene( event )
	local group = self.view
	
	--package.loaded[physics] = nil
--	physics = nil
--  
  group:removeSelf()
  
  Runtime:removeEventListener( "enterFrame" , joystickMove )
  Runtime:removeEventListener( "enterFrame" , gameLoop )
--  hero:addEventListener("collision", hero)
--  Runtime:addEventListener( "collision", onCollision )

  
  
  print('destroying scene')
end


-- collision

local function onLocalCollision(self, event)
    -- print("collision")
    if event.phase == "began" then
        -- print("Collision began")
    elseif event.phase == "ended" then
        -- print("Collision ended")
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
    -- print("postCollision")
end


-- Global Collision
Runtime:addEventListener("collision", onGlobalCollision)
Runtime:addEventListener("postCollision", onPostCollision)


-----------------------------------------------------------------------------------------
-- HERO METHODS
-----------------------------------------------------------------------------------------
function heroDamage()
  print("hero damage")
  
  playerStats.health = playerStats.health - 1
  
  hud.setHealth(playerStats.health)
  hud.updateHealthDisplay()
  
  if(playerStats.health == 0) then
    hero.isDead = true
    local function gotoDeath()
      joystick.joystickStop()
      Runtime:removeEventListener( "enterFrame" , joystickMove )
      storyboard.gotoScene( "death", "fade", 500)
    end
    timer.performWithDelay(1, gotoDeath, 1)
  end
end

function heroWon()
  print("hero won")

  local function teleportPlayer()
    hero:setSequence( "teleport" )
    hero:play()
    audio.play(mySounds["teleport"])
  end
  timer.performWithDelay(1500, teleportPlayer, 1)

  hero.isDead = true -- prevents race condition
  hero.isBodyActive = false
  joystick.joystickStop()

  hero:setSequence( "standing" )
  hero:play()

  --Runtime:removeEventListener( "enterFrame" , joystickMove )
    
    local function gotoLevelComplete()
      storyboard.gotoScene( "levelcomplete", "fade", 2000)
    end
    timer.performWithDelay(5000, gotoLevelComplete, 1)
  
end

-----------------------------------------------------------------------------------------
-- GAME LOOP
-----------------------------------------------------------------------------------------
function getDeltaTime()
   local temp = system.getTimer()  --Get current game time in ms
   local dt = (temp-runtime) / (1000/30)  --60fps or 30fps as base
   runtime = temp  --Store game time
   return dt
end

function gameLoop()
  --Delta Time value
  local dt = getDeltaTime()
  
  -- Replenish STAMINA based on time
  if(hero.stamina < playerStats.staminaMax) then
    hero.stamina = hero.stamina + (0.05 * dt)
    hud.setStamina(hero.stamina)
    hud.updateStaminaDisplay()
  end
end
Runtime:addEventListener( "enterFrame" , gameLoop )


-----------------------------------------------------------------------------------------
-- ENEMY ACTIONS
-----------------------------------------------------------------------------------------
function enemyPathStart(target)
  enemyPathCompleted(target)
end
function enemyPathCompleted(target)
  
  target.pathIndex = target.pathIndex + 1
  -- print(target.pathIndex)
  
  -- reset index
  if(target.wayPoints[target.pathIndex] == nil) then 
    target.pathIndex = 1
  end
  
  local tw, th = map("tileWidth"), map("tileHeight")
  local wx, wy = target.wayPoints[target.pathIndex][1]*tw, target.wayPoints[target.pathIndex][2]*th
  local newX, newY = target.x+wx, target.y+wy
  
  -- set direction
  if(newX < target.x and wx ~= 0) then
    target.direction = "left"
  elseif(newX > target.x and wx ~= 0) then
    target.direction = "right"
  elseif(newY < target.y and wy ~= 0) then 
    target.direction = "up"
    target.rotation = 180
  elseif(newY > target.y and wy ~= 0) then 
    target.direction = "down"
    target.rotation = 0
  end
  -- print(target.direction)
  
  local t = transition.to( target, { time=target.speed, x=(target.x+wx), y=(target.y+wy), onComplete=enemyPathCompleted } )
  table.insert(myTransitions, t)
end

function runEnemyDeath(target)
  local explode = display.newSprite( enemyDeathSheet, enemyDeathAnimData )
  print("== Enemy Death ==")
  target.isVisible =false
  explode.x, explode.y = target.x, target.y

  explode:setSequence( "explode" )
  explode:play()
  audio.play(mySounds["enemyExplosion"])

  -- cleanup after anim finishes
  local function explodeSpriteListener( event )
   
    if ( event.phase == "ended" ) then
      local thisSprite = event.target  --"event.target" references the sprite
      event.target:removeEventListener( "sprite", explodeSpriteListener )
      thisSprite:removeSelf()
    end
   
  end
  explode:addEventListener( "sprite", explodeSpriteListener )

  return explode
end


-- Fire projectile on timer
-- TODO: finish targeting of projectile
function enemyFireProjectile(target)

  -- fire projectile towards hero
  local offsetX = hero.x - target.x
  local offsetY = hero.y - target.y
  local range = display.contentWidth

  if(math.abs(offsetX) <= range and math.abs(offsetY) <= range) then
    target:setSequence( "shooting" )
    target:play()

    -- rotate to hero and fire
    local projectile = display.newImage( "images/laserblast-large.png" )
    projectile.x, projectile.y = target.x, target.y
    projectile.collisionType = "enemy"
    projectile.enemyType = "projectile"

    
    local ratio = offsetY/offsetX

    local destX = range
    if(hero.x < target.x) then
      destX = -range
    end

    local realX = hero.x+destX
    local realY = hero.y+(destX*ratio)
    local offRealX = math.abs(realX - projectile.x)
    local offRealY = math.abs(realY - projectile.y)
    local dist = math.sqrt( (offRealX*offRealX) + (offRealY*offRealY) )
    local dt = (dist/220) * 1000 -- milliseconds

    physics.addBody(projectile, "kinematic", {bounce=0.2, friction=0.5, radius=10, isSensor=false })
    --projectile.isBullet = true

    --print("-- SHOOT --", realX, realY, dist)
    local t = transition.to( projectile, { x=realX, y=realY, time=dt, onComplete=enemyFireProjectileCompleted } )
    projectile.transitionId = t
    table.insert(myTransitions, t)

    return projectile
  else
    return nil
  end
end

function enemyFireProjectileCompleted(obj)
  -- do some cleanup
  print( "! projectile completed", obj )
  if(obj ~= nil) then
    obj.isBodyActive = false
    -- not needed?: transition.cancel( obj.transitionId )
    obj:removeSelf( )
  end
end


-- GEM FUNCTIONS
function gemCollectCompleted(obj)
  print("gem pickup completed")
  
  obj.isVisible = false
  obj.isBodyActive = false
  
  
  playerStats.gems = playerStats.gems + 1
  
  hud.setGems(playerStats.gems)
  hud.updateGemsDisplay()
  
end

-- Called when a key event has been received.
local function onKeyEvent( event )
    -- Print the key's unique descriptor to the log.
    print( event.descriptor )

    -- Return false to indicate that this app is *not* overriding the received key.
    -- This lets the operating system execute its default handling of this key.
    return false
end

-- Add the key event listener.
Runtime:addEventListener( "key", onKeyEvent );
    

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