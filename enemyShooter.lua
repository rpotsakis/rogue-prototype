-----------------------------------------------------------------------------------------
--
-- enemyShooter.lua - enemy class for enemy that has projectile
--
-----------------------------------------------------------------------------------------

module(..., package.seeall)

local enemy = {}
enemy.health = 1 -- # hits to kill
enemy.direction = "up" -- current direction the dude is walking (up|down|left|right)


-----------------------------------------------------------------------------------------
-- ANIMATIONS
-----------------------------------------------------------------------------------------

local laserSheetData = { width=64, height=64, numFrames=4, sheetContentWidth=256, sheetContentHeight=64 }
local laserSheet = graphics.newImageSheet( "sprites/enemy-laser.png", laserSheetData )
local laserAnimData = {
  { name="safe", frames={ 4 }, time=1000, loopCount=0 },
  { name="shooting", frames={ 4,3,2,1 }, time=500, loopCount=1 }
}

local enemySheets = {
  laser = laserSheet
}

local enemyAnims = {
  laser = laserAnimData
}

local enemyShapes = {
  laser = { -16,-32, 16,-32, 16,32, -16,32 } -- 
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

  local sprite = display.newSprite( enemySheets[spawnType], enemyAnims[spawnType] )

  -- Custom Params
  sprite.myParam = "RIIIICKKK"
  sprite.collisionType = "enemy"
  sprite.enemyType = "shooter"
  sprite.spawnType = spawnType
  sprite.speed = 6000 -- time for now...prolly should be pixels/sec
  sprite.pathIndex = 0 -- the path function should incr this first
  sprite.wayPoints = {} -- no set path, chases hero
  sprite.shape = enemyShapes[spawnType]
  
  return sprite
end


-- Checks for collision; return true|false
-- this enemy class has no defenses
function checkCollision(target, heroX, heroY)
  
  local didHit = true
  
  return didHit
  
end
