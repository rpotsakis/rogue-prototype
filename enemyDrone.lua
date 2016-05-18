-----------------------------------------------------------------------------------------
--
-- enemyDrone.lua - enemy class for drone
--
-----------------------------------------------------------------------------------------

module(..., package.seeall)

local enemy = {}
enemy.health = 1 -- # hits to kill
enemy.direction = "up" -- current direction the dude is walking (up|down|left|right)


-----------------------------------------------------------------------------------------
-- ANIMATIONS
-----------------------------------------------------------------------------------------

local orbSheetData = { width=64, height=64, numFrames=3, sheetContentWidth=192, sheetContentHeight=64 }
local orbSheet = graphics.newImageSheet( "sprites/enemy-orb.png", orbSheetData )
local orbAnimData = {
  { name="moving", frames={ 1,2,3 }, time=300, loopCount=0 }
}

local enemySheets = {
  orb = orbSheet
}

local enemyAnims = {
  orb = orbAnimData
}

local enemyShapes = {
  orb = { -25,-22, 25,-22, 25,8, -25,8 }
}



-----------------------------------------------------------------------------------------
-- METHODS
-----------------------------------------------------------------------------------------

function enemyHit(hitVal)
  enemy.health = enemy.health - hitVal
end

function getEnemyHealth()
  return enemy.health
end

function newEnemy()
  
  --local sprite = display.newImage("assets/orb-1.png")
  local sprite = display.newSprite( enemySheets["orb"], enemyAnims["orb"] )

  -- Custom Params
  sprite.myParam = "RIIIICKKK"
  sprite.collisionType = "enemy"
  sprite.enemyType = "drone"
  sprite.spawnType = "orb"
  sprite.speed = 6000 -- time for now...prolly should be pixels/sec
  sprite.pathIndex = 0 -- the path function should incr this first
  sprite.wayPoints = {} -- no set path, chases hero
  sprite.shape = enemyShapes[sprite.spawnType]

  sprite:setSequence( "moving" )
  sprite:play()
  
  return sprite
end


-- Checks for collision; return true|false
-- this enemy class has no defenses
function checkCollision(target, heroX, heroY)
  
  local didHit = true
  
  return didHit
  
end