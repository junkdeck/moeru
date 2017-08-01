local maths = require "maths"

-- collision detection lifted from love2d wiki
function checkCollision(x1,y1,w1,h1, x2,y2,w2,h2)
  return x1 < x2+w2 and
  x2 < x1+w1 and
  y1 < y2+h2 and
  y2 < y1+h1
end

function getRandSound(last,soundTable)
  local randSound = love.math.random(1,table.getn(soundTable))
  if last and last == randSound then
    -- re-roll if the sound is the same as last time, recursive style!!!
    randSound = getRandSound(last,soundTable)
  end
  return randSound
end

function updatePlayerGunCoords(left, right)
  -- updates coords for where bullets spawn
  playerGunCoords.left.x = left.x
  playerGunCoords.left.y = left.y
  playerGunCoords.right.x = right.x
  playerGunCoords.right.y = right.y
end

function shakeScreen(duration,magnitude)
  shakeTimer, shakeDuration, shakeMagnitude = 0, duration or 1, magnitude or 5
  shakeMod = 1
end

function addEnemy(dx,dy)
  -- creates a new enemy object and defines the area where it can spawn
  local newEnemy = { x = dx, y = dy, speed = love.math.random(100,150), img = enemySmallImg, hp = 4, shoot_timer = 0, shoot_delay = love.math.random(.8,1.2)}
  table.insert(enemies, newEnemy)
end

function addEnemyBullet(px,py,vx,vy)
  local newBullet = { pos = {x = px, y = py}, _v = {x = vx, y =vy}, frametime = 0, frame = 1, sheet = bulletPulseFrames, img = bulletPulseImg }
  table.insert(enemy_bullets,newBullet)
end

function addDebris(dx,dy,debrisMin,debrisMax, enemy)
  -- enemy is a boolean which specifies if the debris is from an enemy
  enemy = enemy or false
  for i=1,love.math.random(debrisMin,debrisMax) do
    local newDebris = { pos = {x = dx, y = dy}, _v = {x = love.math.random(-100,100), y = love.math.random(-100,100)},aero = love.math.random(.75,1.5), sizemod = love.math.random(0.98,1.02), frame = love.math.random(1,10), rot_speed = love.math.random(1,5),  rot_damp = love.math.random(1,5), img = nil, frames = nil, timer = 0, duration = love.math.random(.5,2)}
    newDebris.timer = newDebris.duration
    if enemy then
      newDebris.img = enemyDebrisImg
      newDebris.frames = enemyDebrisFrames
    else
      newDebris.img = playerDebrisImg
      newDebris.frames = playerDebrisFrames
    end
    table.insert(debris,newDebris)
  end
end

function addDrop()
  local dx = love.math.random(16,love.graphics.getWidth()/(1*SCALE_FACTOR)-32)
  newDrop = {pos = {x = dx, y = 0}, type = nil, img = nil, rot_time = 0, rot_speed = love.math.random(1,5), rot_dir = love.math.random(-1,1)}

  if rot_dir == 0 then rot_dir = 1 end
  local dropChance = love.math.random(1,100)

  if love.math.random(1,100) >= 50 then   -- 50% chance for drops to occur
    if dropChance <= 60 then
      newDrop.img = batteryImg
      newDrop.type = "battery"
    elseif dropChance <= 75 then
      newDrop.img = wrenchImg
      newDrop.type = "repair"
    else
      newDrop.img = gunImg
      newDrop.type = "gun"
    end
    table.insert(drops, newDrop)
  end
end

function addFx(dx,dy,type,randomize)
  randomize = randomize == nil and true or randomize
  newFx = {pos = {x = dx, y = dy}, type = type, frametime = 0, frame = 1, img = nil, sheet = nil, rot = 0, sizemod = 1}

  if randomize then
    newFx.pos.x = dx+love.math.random(-5,5)
    newFx.pos.y = dy+love.math.random(-5,5)
    newFx.sizemod = love.math.random(.75,1)
    newFx.rot = (math.rad(love.math.random(0,360)))
  end

  if type == "flash" then
    newFx.img = flashImg
    newFx.sheet = flashFrames
  elseif type == "blast" then
    newFx.img = explosionImg
    newFx.sheet = explosionFrames
    newFx.sizemod = 2
  elseif type == "puff" then
    newFx.img = smokepuffImg
    newFx.sheet = smokepuffFrames
    newFx.sizemod = .75
    newFx.pufftime = 0
  elseif type == "muzzle" then
    newFx.img = muzzleImg
    newFx.sheet = muzzleFrames
    newFx.pos.x = newFx.pos.x + 8
  end
  table.insert(fx,newFx)
end

-- constants
SCALE_FACTOR = 3
DEBUG = false
AIR_RESIST = 20
GRAV = 10
DEAD_ZONE = 0.1
START_POS = { x = love.graphics.getWidth()/(2*SCALE_FACTOR), y = love.graphics.getHeight()/(1*SCALE_FACTOR)}

deathPitch = 1 -- used for modifying the pitch on death
globalTimeScale = 1

-- ### TIMER SETUP ###
-- shoot timer
canShoot = true
shootDelay = 0.05
shootTimer = shootDelay
-- enemy spawn timer
enemySpawnDelayMax = 0.55
enemySpawnDelay = enemySpawnDelayMax
enemySpawnTimer = enemySpawnDelay
-- drop spawn timer
dropSpawnDelay = 2.50
dropSpawnTimer = dropSpawnDelay
-- global timer
globalTime = 0

-- object tables
drops = {}
bullets = {}
debris = {}
enemies = {}
enemy_bullets = {}
fx = {}

-- sfx tables ( for randomization )
explosions = {}
playershots = {}
playerdeath = {}
playerhurt = {}
hurt = {}
powerups = {}

-- image storage
bulletOrangeImg = nil
enemySmallImg = nil
bulletPulseImg = nil
playerDebrisImg = nil
enemyDebrisImg = nil
batteryImg = nil
gunImg = nil
wrenchImg = nil
explosionImg = nil
smokepuffImg = nil
flashImg = nil
muzzleImg = nil
bumblerImg = nil

titleKanjiImg = nil
titleBurnImg = nil

-- spritesheet quad storage
bulletPulseFrames = {}
playerDebrisFrames = {}
enemyDebrisFrames = {}
explosionFrames = {}
smokepuffFrames = {}
flashFrames = {}
muzzleFrames = {}
bumblerFrames = {}

-- font storage
upheavalFont = nil

-- some player storage variables
playerGunCoords = { left = {x = nil, y = nil}, right = {x = nil, y = nil} }
playerWhichGun = 0  -- keeps track of which gun to draw bullets from
totalScore = 0
playerShotSound = nil
pickedUpPower = false
playerJustDied = false
canPlayWarning = true

-- gun power vars
gunPower = 1.00 -- percent of gun power left, 0 - 1
gunPowerLose = 0.25 -- amount of gunpower lost every second when firing

-- SCREEN SHAKE FUCK YEAR
shakeTimer, shakeDuration, shakeMagnitude, shakeMod= 0, -1, 0, 1

gameRunning = false

function love.load(arg)
  love.audio.setVolume(0.5)
  love.graphics.setDefaultFilter("nearest", "nearest" )
  love.math.setRandomSeed(os.time())
  control = {left = 'a', right = 'd', up = 'w', down = 's', shoot = 'k', restart = 'j'}

  -- load images
  bumblerImg = love.graphics.newImage('assets/bumbler_sheet.png')
  bulletOrangeImg = love.graphics.newImage('assets/player_shot.png')
  enemySmallImg = love.graphics.newImage('assets/enemyship.png')
  bulletPulseImg = love.graphics.newImage('assets/pulseshot_sheet.png')
  playerDebrisImg = love.graphics.newImage('assets/player_debris_sheet.png')
  enemyDebrisImg = love.graphics.newImage('assets/enemy_debris_sheet.png')
  batteryImg = love.graphics.newImage('assets/battery_pickup.png')
  gunImg = love.graphics.newImage('assets/gun_pickup.png')
  wrenchImg = love.graphics.newImage('assets/wrench_pickup.png')
  explosionImg = love.graphics.newImage('assets/explosion_sheet.png')
  smokepuffImg = love.graphics.newImage('assets/smokepuff_sheet.png')
  flashImg = love.graphics.newImage('assets/rapidflash_sheet.png')
  muzzleImg = love.graphics.newImage('assets/muzzle_sheet.png')

  titleKanjiImg = love.graphics.newImage('assets/moeru_kanji.png')
  titleBurnImg = love.graphics.newImage('assets/moeru_burn.png')

  -- get different player positions
  bumblerFrames[1] = love.graphics.newQuad(0, 0, 16, 16, bumblerImg:getDimensions())
  bumblerFrames[2] = love.graphics.newQuad(0, 16, 16, 16, bumblerImg:getDimensions())
  bumblerFrames[3] = love.graphics.newQuad(0, 32, 16, 16, bumblerImg:getDimensions())

  -- set animation frames from sheets
  -- enemy bullet frames
  bulletPulseFrames[1] = love.graphics.newQuad(0, 0, 8, 8, bulletPulseImg:getDimensions())
  for i=1,5 do
    bulletPulseFrames[i+1] = love.graphics.newQuad(0, 8*i, 8, 8, bulletPulseImg:getDimensions())
  end
  -- debris pieces
  for i=1,10 do
    playerDebrisFrames[i] = love.graphics.newQuad(0, 8*i, 8, 8, playerDebrisImg:getDimensions())
  end
  for i=1,10 do
    enemyDebrisFrames[i] = love.graphics.newQuad(0, 8*i, 8, 8, enemyDebrisImg:getDimensions())
  end
  -- explosion flash frames
  flashFrames[1] = love.graphics.newQuad(0, 0, 32, 32,flashImg:getDimensions())
  for i=1,3 do
    flashFrames[i+1] = love.graphics.newQuad(0, 32*i, 32, 32,flashImg:getDimensions())
  end
  -- explosion blast frames
  explosionFrames[1] = love.graphics.newQuad(0, 0, 32, 32, explosionImg:getDimensions())
  for i=1,7 do
    explosionFrames[i+1] = love.graphics.newQuad(0, 32*i, 32, 32, explosionImg:getDimensions())
  end
  -- smokepuff frames
  smokepuffFrames[1] = love.graphics.newQuad(0, 0, 32, 32, smokepuffImg:getDimensions())
  for i=1,7 do
    smokepuffFrames[i+1] = love.graphics.newQuad(0, 32*i, 32, 32, smokepuffImg:getDimensions())
  end
  -- muzzle flash frames
  muzzleFrames[1] = love.graphics.newQuad(0, 0, 16, 16, muzzleImg:getDimensions())
  for i=1,2 do
    muzzleFrames[i+1] = love.graphics.newQuad(0, 16*i, 16, 16, muzzleImg:getDimensions())
  end

  -- load and play bgm
  bgm = love.audio.newSource('assets/sfx/bgm.ogg', 'stream')
  bgmTitle = love.audio.newSource('assets/sfx/bgm_title.ogg', 'stream')
  bgm:setLooping(true)
  bgmTitle:setLooping(true)
  bgmTitle:play()

  -- low hp warning sound
  warningSound = love.audio.newSource("assets/sfx/warning.wav", "static")
  -- load explosions
  explosions[1] = love.audio.newSource("assets/sfx/explod1.wav", "static")
  explosions[2] = love.audio.newSource("assets/sfx/explod2.wav", "static")
  explosions[3] = love.audio.newSource("assets/sfx/explod3.wav", "static")
  explosions[4] = love.audio.newSource("assets/sfx/explod4.wav", "static")
  explosions[5] = love.audio.newSource("assets/sfx/explod5.wav", "static")
  -- load player explosions
  playerdeath[1] = love.audio.newSource("assets/sfx/playerdeath1.wav", "static")
  playerdeath[2] = love.audio.newSource("assets/sfx/playerdeath1.wav", "static")
  -- load playershots
  playershots[1] = love.audio.newSource("assets/sfx/single1.wav", "static")
  playershots[2] = love.audio.newSource("assets/sfx/single2.wav", "static")
  playershots[3] = love.audio.newSource("assets/sfx/single3.wav", "static")
  playershots[4] = love.audio.newSource("assets/sfx/single4.wav", "static")
  playershots[5] = love.audio.newSource("assets/sfx/single5.wav", "static")
  -- load playerhurt sounds
  playerhurt[1] = love.audio.newSource("assets/sfx/playerhurt1.wav", "static")
  playerhurt[2] = love.audio.newSource("assets/sfx/playerhurt2.wav", "static")
  playerhurt[3] = love.audio.newSource("assets/sfx/playerhurt3.wav", "static")
  -- load hurt sounds
  hurt[1] = love.audio.newSource("assets/sfx/hurt1.wav", "static")
  hurt[2] = love.audio.newSource("assets/sfx/hurt2.wav", "static")
  hurt[3] = love.audio.newSource("assets/sfx/hurt3.wav", "static")
  -- load powerup sounds
  powerups[1] = love.audio.newSource("assets/sfx/powerup1.wav", "static")
  powerups[2] = love.audio.newSource("assets/sfx/powerup2.wav", "static")
  powerups[3] = love.audio.newSource("assets/sfx/powerup3.wav", "static")

  -- fonts
  upheavalFont = love.graphics.newFont("assets/upheaval.ttf", 18)

  -- make player
  player = { pos = {x = 0, y = 0}, _v = {x = 0, y = 0}, accel = 35, termVel = 200, maxhp = 10, hp = 0, pwr = 1, alive = true, frame = 1, sheet = bumblerFrames, img = bumblerImg, smoketimer = 0}
  player.hp = player.maxhp
end

function love.update(dt)

  -- quit game on ESC
  if love.keyboard.isDown('escape') then
    love.event.push('quit')
  end

  -- TITLE SCREEN
  if not gameRunning then
    if love.keyboard.isDown(control.restart) then
      gameRunning = true
      bgmTitle:stop()
      bgm:play()

      -- start position, middle of screen at bottom
      player.pos.x = START_POS.x; player.pos.y = START_POS.y - 8

    end
  elseif gameRunning then
    if player.alive then
      bgm:setPitch(math.normalize(0.4 * gunPower,.1))
    end

    if DEBUG then
      if love.keyboard.isDown('l') then
        addDrop()
      end
    end

    if player.hp == 1 then
      if canPlayWarning then
        warningSound:play()
        canPlayWarning = false
      end
    else
      canPlayWarning = true
    end


    -- ### PLAYER CONTROL AND PHYSICS ###
    if player.alive then
      -- deadzone between -15 <-> 15
      if player._v.x >= -15 and player._v.x <= 15 then
        player._v.x = 0
      end
      if player._v.y >= -15 and player._v.y <= 15 then
        player._v.y = 0
      end

      -- terminal velocity / lateral
      if player._v.x > player.termVel then player._v.x = (player.termVel) end
      if player._v.x < player.termVel * -1 then player._v.x = (player.termVel) * -1 end
      -- terminal velocity / vertical
      if player._v.y > player.termVel then player._v.y = (player.termVel) end
      if player._v.y < player.termVel * -1 then player._v.y = (player.termVel) * -1 end

      -- air resistance / lateral
      if player._v.x > 0 then
        player._v.x = player._v.x - AIR_RESIST
      elseif player._v.x < 0 then
        player._v.x = player._v.x + AIR_RESIST
      end
      -- air resistance / vertical
      if player._v.y > 0 then
        player._v.y = player._v.y - AIR_RESIST
      elseif player._v.y < 0 then
        player._v.y = player._v.y + AIR_RESIST
      end

      -- game bounds / lateral
      if player.pos.x < 8 then player._v.x = 0; player.pos.x = 8 end
      if player.pos.x > love.graphics.getWidth()/(1*SCALE_FACTOR) - 24 then player.pos.x = love.graphics.getWidth()/(1*SCALE_FACTOR) - 24; player._v.x = 0; end
      -- game bounds / vertical
      if player.pos.y < 24 then player._v.y = 0; player.pos.y = 24 end
      if player.pos.y > love.graphics.getHeight()/(1*SCALE_FACTOR) - 8 then player.pos.y = love.graphics.getHeight()/(1*SCALE_FACTOR) - 8; player._v.y = 0; end

      -- lateral movement
      if love.keyboard.isDown(control.left) then
        player._v.x = player._v.x - player.accel
        player.frame = 2
      elseif love.keyboard.isDown(control.right) then
        player._v.x = player._v.x + player.accel
        player.frame = 3
      else
        player.frame = 1
      end

      -- vertical movement
      if love.keyboard.isDown(control.up) then
        player._v.y = player._v.y - player.accel
      elseif love.keyboard.isDown(control.down) then
        player._v.y = player._v.y + player.accel
      end

      -- ### BULLET SPAWNING ###
      if love.keyboard.isDown(control.shoot) and canShoot == true then
        -- update gun placement positions relative to player x origin
        updatePlayerGunCoords({x = player.pos.x-5, y = player.pos.y+7}, {x = player.pos.x+5, y = player.pos.y+7})

        local dx,dy = 0,0

        -- alternate between two different positions for bullet origins
        if playerWhichGun == 0 then
          dx, dy = playerGunCoords.right.x, playerGunCoords.right.y;
          playerWhichGun = 1
        elseif playerWhichGun == 1 then
          dx,dy = playerGunCoords.left.x, playerGunCoords.left.y;
          playerWhichGun = 0
        end
        for i=1,player.pwr do
          newBullet = { pos = {x = dx, y = dy}, _v = {x = love.math.random(-60,60), y = -400}, aero = love.math.random(.95, 1.05), rot = nil, img = bulletOrangeImg}
          -- rotation for spread shots
          local x, y = math.normalize(newBullet._v.x, newBullet._v.y)
          newBullet.rot = math.atan(x, y)
          table.insert(bullets, newBullet)
          -- diminish gunpower for every shot fired
          gunPower = gunPower - (gunPowerLose * dt)
        end
        local playerShotSound = getRandSound(playershots[0], playershots)
        playershots[playerShotSound]:stop()
        playershots[playerShotSound]:play()
        playershots[0] = playerShotSound

        addFx(dx,dy,"muzzle",false)

        canShoot = false
        shootTimer = shootDelay / gunPower
      end

      player.pos.x = player.pos.x + player._v.x * dt
      player.pos.y = player.pos.y + player._v.y * dt

    end

    -- ### PLAYER BULLET PHYSICS ###
    for i, bullet in ipairs(bullets) do
      bullet._v.y = bullet._v.y +  bullet.aero
      -- air resistance / lateral
      if bullet._v.x > 0 then
        bullet._v.x = bullet._v.x - bullet.aero
      elseif bullet._v.x < 0 then
        bullet._v.x = bullet._v.x + bullet.aero
      end

      bullet.pos.y = bullet.pos.y + (bullet._v.y * dt)
      bullet.pos.x = bullet.pos.x + (bullet._v.x * dt)    -- the bullet's x coordinate is randomized, so the bullets spread out like recoil
      if bullet.pos.y < 0 or bullet._v.y > 0 then
        table.remove(bullets, i)
      end
    end

    -- ### ENEMY BULLET PHYSICS ###
    for i,bullet in ipairs(enemy_bullets) do
      bullet.pos.x = bullet.pos.x + bullet._v.x * globalTimeScale * dt
      bullet.pos.y = bullet.pos.y + bullet._v.y * globalTimeScale * dt
    end

    -- ### ENEMY BEHAVIOR ###
    --    is very stupid
    for i, enemy in ipairs(enemies) do
      enemy.y = enemy.y + ((enemy.speed * globalTimeScale) * dt)

      enemy.shoot_timer = enemy.shoot_timer + dt
      if enemy.shoot_timer >= enemy.shoot_delay / globalTimeScale then
        shotAngle = math.angle(enemy.x, enemy.y, player.pos.x, player.pos.y)
        local vx = math.cos(shotAngle)
        local vy = math.sin(shotAngle)
        addEnemyBullet(enemy.x,enemy.y,vx*50,vy*50)

        enemy.shoot_timer = 0
      end

      -- remove when health is 0
      if enemy.hp <= 0 then
        totalScore = totalScore + 10

        -- blow him up
        shakeScreen(0.3,3)
        addFx(enemy.x,enemy.y,"flash")
        addFx(enemy.x,enemy.y,"blast")
        addDebris(enemy.x,enemy.y,10,20,true)

        local randSound = getRandSound(explosions[0],explosions)
        explosions[randSound]:stop()
        explosions[randSound]:play()
        explosions[0] = randSound

        table.remove(enemies,i)
      end

      -- despawn when enemies leave the screen
      if enemy.y > love.graphics.getHeight()/(1*SCALE_FACTOR) + enemy.img:getHeight()/2 then
        table.remove(enemies,i)
      end
    end

    -- ### DEBRIS PHYSICS ###
    for i, d in ipairs(debris) do
      -- d._v.y = d._v.y + GRAV/2
      -- air resistance / lateral
      if d._v.x > 0 then
        d._v.x = d._v.x - d.aero
      elseif d._v.x < 0 then
        d._v.x = d._v.x + d.aero
      end
      -- air resistance / vertical
      if d._v.y > 0 then
        d._v.y = d._v.y - d.aero
      elseif d._v.y < 0 then
        d._v.y = d._v.y + d.aero
      end

      d.pos.y = d.pos.y + d._v.y * globalTimeScale * dt
      d.pos.x = d.pos.x + d._v.x * globalTimeScale * dt

      d.timer = d.timer - dt * globalTimeScale

      if d.timer <= 0 then
        if d._v.x >= -2 and d._v.x <= 2 and d._v.y >= -2 and d._v.y <= 2 then
          table.remove(debris,i)
        end
      end

      if d.pos.y > love.graphics.getHeight()/(1*SCALE_FACTOR) + 32 then
        table.remove(debris,i)
      end
    end

    -- ### DROP PHYSICS ###
    for i, drop in ipairs(drops) do
      drop.pos.y = drop.pos.y + 64 * globalTimeScale * dt

      drop.rot_time = drop.rot_time + dt * globalTimeScale

      if drop.pos.y > love.graphics.getHeight()/(1*SCALE_FACTOR) + 64 then
        table.remove(drops,i)
      end
    end

    -- ### FX PHYSICS ###
    for i, f in ipairs(fx) do
      if f.type == "puff" then
        f.pufftime = f.pufftime + dt
        f.pos.y = f.pos.y - 1 * math.cos(1*f.pufftime)
      end
    end

    -- ### PLAYER DEATH ###
    if player.hp <= 0 then
      if player.alive then
        shakeScreen(2, 4)
        addDebris(player.pos.x,player.pos.y, 50,50)

        addFx(player.pos.x,player.pos.y,"flash")
        addFx(player.pos.x,player.pos.y,"blast")

        local deathSound = getRandSound(playerdeath[0], playerdeath)
        playerdeath[deathSound]:play()
        playerdeath[0] = deathSound

        player.alive = false
      end

      if bgm:getPitch() > 0.01 then
        deathPitch = deathPitch - .01 * dt
        if globalTimeScale > 0.01 then
          globalTimeScale = globalTimeScale - 0.3 * dt
        end
        bgm:setPitch(bgm:getPitch()*deathPitch)
      end

      if love.keyboard.isDown(control.restart) then
        -- reset tables
        bullets = {}
        enemy_bullets = {}
        enemies = {}
        drops = {}
        debris = {}
        -- reset timers
        shootTimer = shootDelay
        enemySpawnDelay = enemySpawnDelayMax
        enemySpawnTimer = enemySpawnDelay
        dropSpawnTimer = dropSpawnDelay
        -- reset player
        player.pos.x = START_POS.x ; player.pos.y = START_POS.y - 8
        player._v.x = 0; player._v.y = 0
        player.alive = true
        player.hp = player.maxhp
        player.pwr = 1
        -- restart bgm
        bgm:stop()
        bgm:setPitch(1)
        bgm:play()
        -- uhhhh
        deathPitch = 1
        globalTimeScale = 1
        playerJustDied = false
        -- reset gunpower and score
        gunPower = 1
        totalScore = 0
      end
    end

    -- ### COLLISION DETECTION ###
    for i, drop in ipairs(drops) do
      -- collision with drops
      if checkCollision(drop.pos.x-16, drop.pos.y-16, 32, 32, player.pos.x - 4, player.pos.y - 4, 8, 8) and player.alive then
        oldPow = gunPower
        pickedUpPower = drop.type

        totalScore = totalScore + 5
        local powSound = getRandSound(powerups[0],powerups)
        powerups[powSound]:play()
        powerups[0] = powSound
        table.remove(drops,i)
      end
    end

    if pickedUpPower == "battery" then
      if gunPower - oldPow <= 0.15 and gunPower <= 1 then
        gunPower = gunPower + 1 * dt
      else
        pickedUpPower = false
        oldPow = nil
      end
    elseif pickedUpPower == "gun" then
      player.pwr = player.pwr + 1
      pickedUpPower = false
    elseif pickedUpPower == "repair" then
      player.hp = player.hp + 1
      pickedUpPower = false
    end

    -- enemy collisions
    for i, enemy in ipairs(enemies) do
      -- bullet collision
      for j, bullet in ipairs(bullets) do
        if checkCollision(enemy.x - enemy.img:getWidth()/2, enemy.y - enemy.img:getHeight()/2, enemy.img:getWidth(), enemy.img:getHeight()/2, bullet.pos.x - bullet.img:getWidth()/2, bullet.pos.y - bullet.img:getHeight()/2, bullet.img:getWidth(), bullet.img:getHeight()) then
          table.remove(bullets,j)
          enemy.hp = enemy.hp - 1
          shakeScreen(.1,.05)
          addDebris(bullet.pos.x,bullet.pos.y,1,4,true)
          addFx(enemy.x,enemy.y,"puff")

          local hurtSound = getRandSound(hurt[0], hurt)
          hurt[hurtSound]:stop()
          hurt[hurtSound]:play()
          hurt[0] = hurtSound
        end
      end
      -- player collision
      if checkCollision(enemy.x - enemy.img:getWidth()/2, enemy.y - enemy.img:getHeight()/2, enemy.img:getWidth(), enemy.img:getHeight()/2, player.pos.x - 4, player.pos.y - 4, 8, 8) and player.alive then
        enemy.hp = enemy.hp - 10
        player.hp = player.hp - 1
      end
    end

    -- player collision with enemy projectiles
    for i, bullet in ipairs(enemy_bullets) do
      if checkCollision(bullet.pos.x - 4, bullet.pos.y - 4, 8, 8, player.pos.x - 4, player.pos.y - 4, 8, 8) and player.alive then
        player.hp = player.hp - 1
        addDebris(bullet.pos.x,bullet.pos.y,1,4)
        addFx(bullet.pos.x,bullet.pos.y,"puff")
        shakeScreen(.25,2)

        local hurtSound = getRandSound(playerhurt[0], playerhurt)
        playerhurt[hurtSound]:stop()
        playerhurt[hurtSound]:play()
        playerhurt[0] = hurtSound

        table.remove(enemy_bullets,i)
      end
    end


    -- ### TIMERS ###
    -- shoot delay timer
    shootTimer = shootTimer - (1 * dt)
    if shootTimer <= 0 then
      canShoot = true
    end
    -- enemy spawn delay timer
    enemySpawnTimer = enemySpawnTimer - (1 * dt)
    if enemySpawnTimer <= 0 then
      enemySpawnTimer = enemySpawnDelay / globalTimeScale
      local dx = love.math.random(enemySmallImg:getWidth()/2, love.graphics.getWidth()/(1*SCALE_FACTOR) - enemySmallImg:getWidth()/2 - 24 )
      addEnemy(dx,-40)
    end
    -- increase enemy spawning the longer you play
    if player.alive then
      enemySpawnDelay = enemySpawnDelay - 0.0025 * dt
    end
    -- drop spawn timer
    dropSpawnTimer = dropSpawnTimer - (1 * dt)
    if dropSpawnTimer <= 0 then
      dropSpawnTimer = dropSpawnDelay / globalTimeScale
      addDrop()
    end
    -- screen shake timer
    if shakeTimer < shakeDuration then
      shakeTimer = shakeTimer + dt
    end
    -- fx animations
    for i, e in ipairs(fx) do
      e.frametime = e.frametime + dt * globalTimeScale
      if e.frametime >= 0.04 then
        if e.frame < #e.sheet then
          e.frame = e.frame + 1
        else
          table.remove(fx,i)
          -- e.frame = 1
        end
        e.frametime = 0
      end
    end
    -- player smoke on warning
    if player.hp == 1 then
      player.smoketimer = player.smoketimer + dt
      if player.smoketimer >= 0.2 then
        addFx(player.pos.x,player.pos.y,"puff")
        player.smoketimer = 0
      end
    end
    -- bullet animation frame update timer
    for i, bullet in ipairs(enemy_bullets) do
      bullet.frametime = bullet.frametime + dt * globalTimeScale
      if bullet.frametime >= 0.08 then
        if bullet.frame < #bullet.sheet then
          bullet.frame = bullet.frame + 1
        else
          bullet.frame = 1
        end
        bullet.frametime = 0
      end
    end

  end
  -- global timer
  globalTime = globalTime + dt
end

function love.draw()
  love.graphics.scale(SCALE_FACTOR,SCALE_FACTOR)
  love.graphics.setFont(upheavalFont)

  -- screenshake!!
  if shakeTimer < shakeDuration then
    shakeMod = shakeMod * 0.98
    local dx = love.math.random(-shakeMagnitude, shakeMagnitude) * shakeMod
    local dy = love.math.random(-shakeMagnitude, shakeMagnitude) * shakeMod
    love.graphics.translate(dx,dy)
  end

  -- draw debris
  for i, d in ipairs(debris) do
    love.graphics.setColor(164, 164, 164, 255*d.timer)
    love.graphics.draw(d.img,d.frames[d.frame], d.pos.x, d.pos.y, ((d.rot_speed * d.timer)), sx, sy, 4, 4, kx, ky)
    love.graphics.setColor(255, 255, 255, alpha)
  end

  -- draw drops table
  for i, drop in ipairs(drops) do
    love.graphics.draw(drop.img, drop.pos.x, drop.pos.y, math.rad(drop.rot_speed * drop.rot_time), sx, sy, 8, 8, kx, ky)
  end

  -- draw bullets table
  for i, bullet in ipairs(bullets) do
    love.graphics.draw(bullet.img, bullet.pos.x, bullet.pos.y, bullet.rot, sx,sy, bullet.img:getWidth()/2, bullet.img:getHeight()/2, kx, ky)
  end

  -- draw player
  if player.alive and gameRunning then
    love.graphics.draw(player.img, player.sheet[player.frame], player.pos.x, player.pos.y, r, sx, sy, 8, 8 , kx, ky)
  end

  -- draw enemy bullets
  for i, bullet in ipairs(enemy_bullets) do
    love.graphics.draw(bullet.img,bullet.sheet[bullet.frame], bullet.pos.x, bullet.pos.y,r,sx,sy,4,4)
  end

  -- draw enemies table
  for i, enemy in ipairs(enemies) do
    love.graphics.draw(enemy.img, enemy.x, enemy.y, 3.14159, sx, sy, enemy.img:getWidth()/2, enemy.img:getHeight()/2, kx, ky)
  end

  -- draw fx
  for i, f in ipairs(fx) do
    love.graphics.draw(f.img,f.sheet[f.frame], f.pos.x, f.pos.y, f.rot, f.sizemod,f.sizemod, 16, 16, kx, ky)
  end

  if not player.alive then
    local r = math.rad( math.sin( 3 * globalTime) * 2 )
    local sx = .5 + 0.1 * math.sin( 4 * globalTime )
    local sy = .75 + 0.1 * math.cos( 4 * globalTime )
    local you_suck = "YOU WIPED OUT // HIT J"
    love.graphics.print(you_suck, love.graphics.getWidth()/(2*SCALE_FACTOR), love.graphics.getHeight()/(2*SCALE_FACTOR), r, sx, sy, upheavalFont:getWidth(you_suck)/2, upheavalFont:getHeight(you_suck), kx, ky)
  end

  -- draw title
  if not gameRunning then
    -- kanji
    love.graphics.draw(titleKanjiImg, love.graphics.getWidth()/(2*SCALE_FACTOR), love.graphics.getHeight()/(2*SCALE_FACTOR),  math.rad(2 * math.sin(2*globalTime))*1, .125 + .005 * math.sin(4*globalTime), .125 + .005 * math.cos(4*globalTime), titleKanjiImg:getWidth()/2, titleKanjiImg:getHeight()/2, kx, ky)
    -- burn
    love.graphics.draw(titleBurnImg, love.graphics.getWidth()/(2*SCALE_FACTOR) + love.math.random(-1,1), love.graphics.getHeight()/(2*SCALE_FACTOR) + love.math.random(-1,1), r, .125,.125, titleBurnImg:getWidth()/2, titleBurnImg:getHeight()/2, kx, ky)

    local title = "- press j to start -"
    love.graphics.print(title, love.graphics.getWidth()/(2*SCALE_FACTOR), love.graphics.getHeight()/(2*SCALE_FACTOR)+48 + (2 * math.sin(4*globalTime)), r, sx, sy, upheavalFont:getWidth(title)/2, upheavalFont:getHeight(title)/2)
    local instruct = {"wasd - moves","k - shoots"}
    for i=1,#instruct do
      love.graphics.print(instruct[i], love.graphics.getWidth()/(2*SCALE_FACTOR), love.graphics.getHeight()/(2*SCALE_FACTOR)+56+(16*i),r, 1 + 0.025 * math.sin(math.random(1,4)*globalTime), sy, upheavalFont:getWidth(instruct[i])/2, upheavalFont:getHeight(instruct[i])/2)
    end

  else
    -- HUD
    love.graphics.origin()
    love.graphics.setColor(0,0,0,alpha)
    love.graphics.rectangle("fill",love.graphics.getWidth()-48,0,64,love.graphics.getHeight())
    love.graphics.setColor(255,255,255,alpha)
    love.graphics.print("SCORE // "..totalScore, love.graphics.getWidth() - 5, 5, math.pi/2, 2,2)

    -- gunpower meter container
    local absPower = math.floor(gunPower*100)
    love.graphics.setColor(192,192,192,alpha)
    love.graphics.rectangle("line", 0, 24, (love.graphics.getWidth() - 48), 24)
    love.graphics.setColor(255, 255, 255, alpha)
    love.graphics.print(absPower, (love.graphics.getWidth())-64, 36, r, 1,1,upheavalFont:getWidth(absPower)/2, upheavalFont:getHeight(absPower)/2)
    love.graphics.rectangle("fill", 0, 24, (love.graphics.getWidth() - 48)*gunPower, 25)
    -- 'lagging behind' health bar - shows how much damage you've taken
    love.graphics.setColor(255, 182 , 57, alpha)
    love.graphics.rectangle("fill", 0, 0, (love.graphics.getWidth() - 48), 24)
    -- main filler, red
    love.graphics.setColor(192, 0, 0, alpha)
    love.graphics.rectangle("fill", 0, 0, ((love.graphics.getWidth()-48)/player.maxhp)*player.hp, 24)
    love.graphics.setColor(255, 255, 255, alpha)
  end

  if DEBUG == true then
    love.graphics.origin()
    love.graphics.print("_v.x: "..player._v.x, 0, 0)
    love.graphics.print("_v.y: "..player._v.y, 0, 12)
    love.graphics.print("pos.x: "..player.pos.x, 0, 24)
    love.graphics.print("pos.y: "..player.pos.y, 0, 36)
    love.graphics.print("enemies: "..table.getn(enemies), 0, 48)
    love.graphics.print("bullets: "..table.getn(bullets), 0, 60)
    love.graphics.print("debris: "..table.getn(debris),0,72)
    love.graphics.print("gunpower: "..gunPower, 0, 86)
    love.graphics.print("enemy spawn delay (in s): "..(enemySpawnDelay/globalTimeScale),0,98)
    love.graphics.print("next enemy in "..enemySpawnTimer, 0, 110)
    love.graphics.print("next drop in "..dropSpawnTimer, 0, 122)
    love.graphics.print("bgmpitch "..bgm:getPitch(), 0, 134)
    love.graphics.print("timescale "..globalTimeScale, 0, 146)
  end
end
