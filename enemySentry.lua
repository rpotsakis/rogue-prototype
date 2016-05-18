-----------------------------------------------------------------------------------------
--
-- enemySentry.lua - enemy class for sentry
--
-----------------------------------------------------------------------------------------

module(..., package.seeall)

local enemy = {}
enemy.health = 1 -- takes 3 hits to kill
enemy.direction = "up" -- current direction the dude is walking (up|down|left|right)


-----------------------------------------------------------------------------------------
-- ANIMATIONS by type
-----------------------------------------------------------------------------------------

local blobSheetData = { width=64, height=64, numFrames=3, sheetContentWidth=192, sheetContentHeight=64 }
local blobSheet = graphics.newImageSheet( "sprites/enemy-blob.png", blobSheetData )
local blobAnimData = {
  { name="moving", frames={ 1,2,3 }, time=500, loopCount=0 }
}


local blobBlueSheet = graphics.newImageSheet( "sprites/enemy-blob-blue.png", blobSheetData )
local blobGreenSheet = graphics.newImageSheet( "sprites/enemy-blob-green.png", blobSheetData )

local catSheetData = { width=64, height=64, numFrames=2, sheetContentWidth=128, sheetContentHeight=64 }
local catSheet = graphics.newImageSheet( "sprites/enemy-caterpillar.png", catSheetData )
local catAnimData = {
  { name="moving", frames={ 1,2 }, time=250, loopCount=0 }
}

local enemySheets = {
  blob = blobSheet,
  blobblue = blobBlueSheet,
  blobgreen = blobGreenSheet,
  cat = catSheet
}

local enemyAnims = {
  blob = blobAnimData,
  blobblue = blobAnimData,
  blobgreen = blobAnimData,
  cat = catAnimData
}

local enemyShapes = {
  blob = { -25,-15, 25,-15, 25,15, -25,15 },
  cat = { -14,-24, 14,-24, 14,24, -14,24 }
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

function newEnemy(spawnX, spawnY, spawnType, subType)
  if(spawnType == nil) then
    spawnType = "blob"
  end

  if(subType == nil) then
    subType = ""
  end

  print( "spanwnType, subType", spawnType, subType )

  local sheetId = spawnType .. string.lower(subType)

  --local sprite = display.newImage("assets/player-1.png")
  --sprite:setFillColor(0, 0, 0)
  local sprite = display.newSprite( enemySheets[sheetId], enemyAnims[spawnType] )
  
  -- Custom Params
  sprite.myParam = "RIIIICKKK"
  sprite.collisionType = "enemy"
  sprite.enemyType = "sentry"
  sprite.spawnType = spawnType
  sprite.speed = 6000 -- time for now...prolly should be pixels/sec
  sprite.pathIndex = 0 -- the path function should incr this first
  sprite.wayPoints = {
    { -3, 0 },
    { 0, 2 },
    { 3, 0 },
    { 0, -2 }
  }
  sprite.shape = enemyShapes[spawnType]
  
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


--[[ disabled due to problems

-- Checks for collision; return true|false
-- this enemy class can only be hit from behind
function checkCollision(target, heroX, heroY)
  
  local didHit = false
  didHit = true -- allowing any hits for now; was suppose to enemy with sheild
  
  -- check if the hero is behind the sentry
  if(target.direction == "up") then
    
    if(heroY > target.y) then 
      didHit = true
    end
    
  elseif(target.direction == "down") then
    
    if(heroY < target.y) then 
      didHit = true
    end
    
  elseif(target.direction == "left") then
    
    if(heroX > target.x) then 
      didHit = true
    end
    
  elseif(target.direction == "right") then
    
    if(heroX < target.x) then 
      didHit = true
    end
    
  end
  
  
  return didHit
  
end

--]]