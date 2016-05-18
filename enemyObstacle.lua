-----------------------------------------------------------------------------------------
--
-- enemyObstacle.lua - enemy class for environment obstacles
--
-----------------------------------------------------------------------------------------

module(..., package.seeall)

local enemy = {}
enemy.health = 1 -- # hits to kill
enemy.direction = "up" -- current direction the dude is walking (up|down|left|right)


-----------------------------------------------------------------------------------------
-- ANIMATIONS
-----------------------------------------------------------------------------------------

local spikeSheetData = { width=64, height=64, numFrames=3, sheetContentWidth=192, sheetContentHeight=64 }
local spikeSheet = graphics.newImageSheet( "sprites/enemy-spike.png", spikeSheetData )
local spikeAnimData = {
  { name="safe", frames={ 1 }, time=1000, loopCount=0 },
  { name="moving", frames={ 1,2,3 }, time=500, loopCount=1 },
  { name="movingIn", frames={ 3,2,1 }, time=500, loopCount=1 }
}

local enemySheets = {
  spike = spikeSheet
}

local enemyAnims = {
  spike = spikeAnimData
}

local enemyShapes = {
  spike = { -32,-32, 32,-32, 32,32, -32,32 } -- square
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

function newEnemy(spawnX, spawnY, spawnType)
  
  --local sprite = display.newImage("assets/orb-1.png")
  local sprite = display.newSprite( enemySheets[spawnType], enemyAnims[spawnType] )

  -- Custom Params
  sprite.myParam = "RIIIICKKK"
  sprite.collisionType = "enemy"
  sprite.enemyType = "obstacle"
  sprite.spawnType = spawnType
  sprite.speed = 6000 -- time for now...prolly should be pixels/sec
  sprite.pathIndex = 0 -- the path function should incr this first
  sprite.wayPoints = {} -- no set path, chases hero
  sprite.shape = enemyShapes[spawnType]
  
  sprite:setSequence( "safe" )
  sprite:play()
  
  return sprite
end


-- Checks for collision; return true|false
-- can not destroy this enemy type
function checkCollision(target, heroX, heroY)
  
  local didHit = false
  
  return didHit
  
end