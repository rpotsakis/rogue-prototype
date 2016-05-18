module(..., package.seeall)

local hud = {}
hud.health = 0
hud.healthMax = 3
hud.score = 0
hud.gems = 0
hud.stamina = 0
hud.staminaMax = 27

local healthText, scoreText, gemsText
local healthGauge, healthBar, healthBarX, healthBarH, spinBar
local staminaDisplayArray = {}
local healthDisplayArray = {}
local chip_holders = {}
local chips = {}

-----------------------------------------------------------------------------------------
-- ANIMATIONS
-----------------------------------------------------------------------------------------
local healthSheetData = { width=240, height=32, numFrames=6, sheetContentWidth=240, sheetContentHeight=192 }
local healthSheet = graphics.newImageSheet( "sprites/bar-health.png", healthSheetData )
local healthAnimData = {
  
  { name="0", frames={ 6 }, time=250, loopCount=1 },
  { name="1", frames={ 5 }, time=250, loopCount=1 },
  { name="2", frames={ 4 }, time=250, loopCount=1 },
  { name="3", frames={ 3 }, time=250, loopCount=1 },
  { name="4", frames={ 2 }, time=250, loopCount=1 },
  { name="5", frames={ 1 }, time=250, loopCount=1 }

}


-----------------------------------------------------------------------------------------
-- METHODS
-----------------------------------------------------------------------------------------

function setHealth(healthVal)
  hud.health = math.floor(healthVal)
end

function setScore(scoreVal)
  hud.score = scoreVal
end

function setGems(gemVal)
  hud.gems = gemVal
end

function setStamina(staminaVal)
  hud.stamina = math.floor(staminaVal)
end

function setStaminaMax(staminaVal)
  hud.staminaMax = staminaVal + 2 -- 2 more for start/end bars
end

-- Display HUD - health, loot, score...joystick?
function displayHud()
  
  local hudGroup = display.newGroup()
  local staminaGroup = display.newGroup()
  local chipsGroup = display.newGroup()
  local textOpts = {}

  -- reset
  staminaDisplayArray = {}
  healthDisplayArray = {}
  chip_holders = {}
  chips = {}

  --[[ deprec 
  textOpts = {
    text = "Health: " .. hud.health,
    x = 10,
    y = 10,
    font = native.systemFontBold    
  }
  healthText = display.newText( textOpts )
  healthText.alpha = 0
  --]]


  --[[ deprec
  healthBar = display.newSprite( healthSheet, healthAnimData )
  healthBar.anchorX, healthBar.anchorY = 0,0
  healthBar.x, healthBar.y = 10,10
  healthBar.alpha = 0.75
  --healthBar.xScale, healthBar.yScale = 0.5,0.5 -- temp?
  healthBar:setSequence( "3" )
  healthBar:play()
  --]]

  -- INIT Display Groups
  healthGroup = initHealthDisplay()
  

  staminaGroup = initStaminaDisplay()


  chipsGroup = initChipDisplay()

  --[[ no score needed 
  textOpts = {
    text = "Score: " .. hud.score,
    x = display.contentWidth-100,
    y = 10,
  }
  scoreText = display.newText( textOpts )
  --]]

  --[[
  textOpts = {
    text = "Gems: " .. hud.gems,
    x = healthText.x+300,
    y = 10
  }
  gemsText = display.newText( textOpts )
  --]]

  --hudGroup:insert(healthText)
  --hudGroup:insert(scoreText)
  --hudGroup:insert(gemsText)
  
  hudGroup:insert(healthGroup)
  hudGroup:insert(staminaGroup)
  hudGroup:insert(chipsGroup)

  return hudGroup
end

--[[
function updateHealthDisplay()
  healthText.text = "Health: " .. hud.health
end
--]]

function updateScoreDisplay()
  scoreText.text = "Score: " .. hud.score
end

-- Deprecated - remove eventually
function updateGemsDisplay()
  -- gemsText.text = "Gems: " .. hud.gems
end


function initHealthDisplay()
  local barGroup = display.newGroup()
  local lastBar
  local startX, startY = 10,10
  healthDisplayArray = {}

  for i=1,hud.healthMax do
    
    local barEmpty = display.newImage( "images/health-bar-empty.png" )
    local barFull = display.newImage( "images/health-bar-full.png" )
    barEmpty.anchorX, barEmpty.anchorY, barFull.anchorX, barFull.anchorY = 0,0,0,0
    barEmpty.y, barFull.y = startY, startY
    barEmpty.alpha = 0.1

    if(i == 1) then
      barEmpty.x = startX
      barFull.x = barEmpty.x

      -- set these for positioning stamina gauge
      healthBarX = barEmpty.x
      healthBarH = barEmpty.height
    else 
      barEmpty.x = lastBar.x + lastBar.width
      barFull.x = barEmpty.x
    end

    barGroup:insert( barEmpty )
    barGroup:insert( barFull )
    lastBar = barEmpty
    table.insert( healthDisplayArray, barFull )

  end -- for

  return barGroup
end


function updateHealthDisplay()
  print("health bars", #healthDisplayArray, hud.health)

  if(hud.health > 0) then
    for i=#healthDisplayArray,hud.health,-1 do
      local bar = healthDisplayArray[i]
      if(i <= hud.health) then
        bar.alpha = 1.0
      else
        bar.alpha = 0.0
      end
    end
  end
end


function initStaminaDisplay()
  local barGroup = display.newGroup()
  local lastBar

  spinBar = display.newImage( "images/spin-gauge-1.png" )
  spinBar.anchorX, spinBar.anchorY = 0,0
  spinBar.x, spinBar.y = 10, healthBarX + healthBarH + 5
  --spinBar.xScale, spinBar.yScale = 0.5,0.5 -- temp?
  barGroup:insert( spinBar )
  lastBar = spinBar
  table.insert( staminaDisplayArray, spinBar )

  for i=1,hud.staminaMax do
    
    local spinMid = display.newImage( "images/spin-gauge-2.png" )
    spinMid.anchorX, spinMid.anchorY = 0,0
    spinMid.y = spinBar.y

    if(i == 1) then
      spinMid.x = spinBar.x + spinBar.width
    else 
      spinMid.x = lastBar.x + lastBar.width
    end

    barGroup:insert( spinMid )
    lastBar = spinMid
    table.insert( staminaDisplayArray, spinMid )

  end -- for

  local spinEnd = display.newImage( "images/spin-gauge-3.png" )
  spinEnd.anchorX, spinEnd.anchorY = 0,0
  spinEnd.x, spinEnd.y = lastBar.x+lastBar.width, spinBar.y
  barGroup:insert( spinEnd )
  table.insert( staminaDisplayArray, spinEnd )

  return barGroup
end

function updateStaminaDisplay()
  --print("stamina bars", #staminaDisplayArray, hud.stamina)

  if(hud.stamina > 1) then
    for i=#staminaDisplayArray,hud.stamina,-1 do
      local bar = staminaDisplayArray[i]
      if(i <= hud.stamina) then
        bar.alpha = 1.0
      else
        bar.alpha = 0.1
      end
    end
  end
end


function initChipDisplay()

  local group = display.newGroup()
  

  -- CHIP PLACEHOLDERS  
  table.insert( chip_holders, 1, display.newImage( "images/missing-chip-placeholder.png" ) )
  table.insert( chip_holders, 2, display.newImage( "images/missing-chip-placeholder.png" ) )
  table.insert( chip_holders, 3,  display.newImage( "images/missing-chip-placeholder.png" ) )

  chip_holders[3].anchorX, chip_holders[2].anchorX, chip_holders[1].anchorX = 1,1,1
  chip_holders[3].anchorY, chip_holders[2].anchorY, chip_holders[1].anchorY = 0,0,0
  chip_holders[3].alpha, chip_holders[2].alpha, chip_holders[1].alpha = 0.2,0.2,0.2

  chip_holders[3].y, chip_holders[2].y, chip_holders[1].y = 10,10,10
  chip_holders[3].x = display.contentWidth - 10
  chip_holders[2].x = chip_holders[3].x - chip_holders[3].width - 10
  chip_holders[1].x = chip_holders[2].x - chip_holders[2].width - 10

  group:insert(chip_holders[1])
  group:insert(chip_holders[2])
  group:insert(chip_holders[3])

  -- CHIPS - hidden until collected
  table.insert( chips, 1, display.newImage( "images/missing-chip-found.png" ) )
  table.insert( chips, 2, display.newImage( "images/missing-chip-found.png" ) )
  table.insert( chips, 3,  display.newImage( "images/missing-chip-found.png" ) )

  chips[3].anchorX, chips[2].anchorX, chips[1].anchorX = 1,1,1
  chips[3].anchorY, chips[2].anchorY, chips[1].anchorY = 0,0,0
  chips[3].alpha, chips[2].alpha, chips[1].alpha = 0,0,0

  -- This positioning needs to be the same as the holders!
  chips[3].y, chips[2].y, chips[1].y = 10,10,10
  chips[3].x = display.contentWidth - 10
  chips[2].x = chips[3].x - chips[3].width - 10
  chips[1].x = chips[2].x - chips[2].width - 10

  group:insert(chips[1])
  group:insert(chips[2])
  group:insert(chips[3])

  return group

end

function updateChipDisplay( chipId )
  -- Show specific chip when it's collected
  print( "num chips: ", #chips )
  print( "id: ", chipId )
  local id = tonumber( chipId )
  local chip = chips[id]
  chip.alpha = 1.0
end

function getChipCount()
  local num = 0

  for i=1,#chips,1 do
    if(chips[i].alpha == 1) then
      num = num + 1
    end
  end

  return num
end

