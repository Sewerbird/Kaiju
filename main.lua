--
-- UTILS
--
function max(a,b)
  return math.max(a,b)
end
function min(a,b)
  return math.min(a,b)
end
function clamp(a,min,max)
  return math.max(min,math.min(a,max))
end
function wrap(a,min,max)
  if a > max then
    return a - max
  elseif a < min then
    return max + a
  else
    return a
  end
end
function rand(min,max)
  return love.math.random() * (max - min) + min
end
function read_hash_from_json(filename)
  chunk, err = love.filesystem.load(filename)
  return chunk()
end
--
-- STATE
--
function load_game()
  player = make_player()
  bullets = {}
  enemies = {}
end
--
-- CLASSES
--
function make_player()
  return {
    x = 3, y = 3, --position, in px, in cartesian coordinates
    dx = 50, dy = 50, --velocity, in px/s, in cartesian coordinates
    refire = 0, refire_max = 0.05, --gun rate meter
    life = 10, life_max = 10, --life meter
    invulnerability = 0, --invulnerability period, in seconds
    animation = animations.player, animation_frame = 1, animation_rate = 0.1, animation_timer = 0, --current animation info
    r = 8, --radius, in px
    update = function(self, dt)
      self.animation_timer = self.animation_timer + dt
      if self.animation_timer > self.animation_rate then
        self.animation_timer = self.animation_timer - self.animation_rate
        self.animation_frame = self.animation_frame + 1
        if self.animation_frame > #self.animation then
          self.animation_frame = 1
        end
      end
    end,
    draw = function(self)
      love.graphics.push()
      love.graphics.draw(sheets.main, animations.player[self.animation_frame], self.x, self.y, 0, 1, 1, 8, 8)
      love.graphics.pop()
    end
  }
end

function make_bullet(x,y)
  return {
    x = x, y = y, --position, in px
    dx = 0, dy = 200, --velocity, in px/s
    r = 8, --radius, in px
    draw = function(self)
      love.graphics.push()
      love.graphics.draw(sprites.bullet.img, sprites.bullet.quad, self.x, self.y,0,1,1,8,8)
      love.graphics.pop()
    end
  }
end

function make_enemy(x,y,dx,dy)
  return {
    x = x, y = y, --position, in px
    dx = dx, dy = dy,
    life = 1, life_max = 1, --life meter
    r = 8, --radius, in px
    draw = function(self)
      love.graphics.push()
      love.graphics.draw(sprites.enemy.img, sprites.enemy.quad, self.x, self.y,0,1,1,8,8)
      love.graphics.pop()
    end
  }
end

function make_title_scene()
  return {
    load = function(self)
      music:stop()
      music.theme0:setLooping(true)
      music.theme0:play()
    end,

    update = function(self, dt)
      if love.keyboard.isDown("return") then
        current_scene = make_corridor_scene()
        current_scene:load()
      end
    end,

    draw = function(self)
      love.graphics.print("XENOLOVE",30,48)
    end
  }
end

function make_gameover_scene()
  return {
    load = function(self)
      music:stop()
      music.theme1:setLooping(true)
      music.theme1:play()
    end,

    update = function(self, dt)
      if love.keyboard.isDown("return") then
        love.event.quit()
      end
      if love.keyboard.isDown("space") then
        --Reset
        load_game()
        --Reload
        current_scene = make_title_scene()
        current_scene:load()
      end
    end,

    draw = function(self)
      love.graphics.print("GAME OVER",30,48)
    end
  }
end

function make_corridor_scene()
  return {
    load = function(self)
      music:stop()
      music.theme2:setLooping(true)
      music.theme2:play()
    end,

    update = function(self, dt)
      player:update(dt)
      -- Update player invulnerability timer
      player.invulnerability = max(player.invulnerability - dt, 0)
      -- Move player around
      if love.keyboard.isDown("down") then
        player.y = player.y + player.dy * dt
      end
      if love.keyboard.isDown("up") then
        player.y = player.y - player.dy * dt
      end
      if love.keyboard.isDown("right") then
        player.x = player.x + player.dx * dt
      end
      if love.keyboard.isDown("left") then
        player.x = player.x - player.dx * dt
      end
      --Keep player in movement area
      if CARTESIAN then
        player.x = clamp(player.x, 0,window_px)
      else
        player.x = wrap(player.x, 0,window_px)
      end
      player.y = clamp(player.y, 32,window_px)
      --Scale player appropriately
      --player.r = 8 * (player.y/window_px)
      --Handle player gun
      player.refire = max(player.refire - dt, 0)
      if love.keyboard.isDown("z") and player.refire == 0 then
        player.refire = player.refire_max
        sfx.laser1:play()
        table.insert(bullets, make_bullet(player.x,player.y-8))
      end
      --Spawn a line of enemies in the center of thes creen
      if love.keyboard.isDown("s") then
        local x0 = love.math.random()*window_px
        local w = love.math.random()*32
        for i = 1, 10 do
          table.insert(enemies, make_enemy(x0 + (i / 10 *  w), 0,0,-30))
        end
      end
      --Spawn an enemy in center of screen
      if love.keyboard.isDown("c") then
        table.insert(enemies, make_enemy(64, 0, rand(-40,40), rand(-20,40)))
      end
      --Cleanup offscreen things
      for i, bullet in ipairs(bullets) do
        if bullet.x > window_px or bullet.x < 0 or bullet.y > window_px or bullet.y < 0 then
          table.remove(bullets, i)
        end
      end
      for i, enemy in ipairs(enemies) do
        if enemy.x > window_px or enemy.x < 0 or enemy.y > window_px or enemy.y < 0 then
          table.remove(enemies, i)
        end
      end
      --Animate bullets
      for _, bullet in ipairs(bullets) do
        bullet.x = bullet.x + bullet.dx * dt
        bullet.y = bullet.y - bullet.dy * dt
      end
      --Animate enemies
      for _, enemy in ipairs(enemies) do
        enemy.x = clamp(enemy.x + enemy.dx * dt,0,window_px)
        if enemy.x == 0 then
          enemy.dx = -enemy.dx
        end
        if enemy.x == window_px then
          enemy.dx = -enemy.dx
        end
        enemy.y = enemy.y - enemy.dy * dt
        --Scale enemy appropriately
        --enemy.r = 8 * (enemy.y/window_px)
      end
      --See if bullets are touching enemies
      for b_idx, bullet in ipairs(bullets) do
        for e_idx, enemy in ipairs(enemies) do
          dx = math.sqrt(bullet.x*bullet.x - enemy.x*enemy.x)
          dy = math.sqrt(bullet.y*bullet.y - enemy.y*enemy.y)
          distance = math.sqrt(math.pow(bullet.x - enemy.x, 2) + math.pow(bullet.y - enemy.y, 2))
          if distance < bullet.r + enemy.r then
            --Damage the enemy and use up the bullet
            enemy.life = enemy.life - 1
            table.remove(bullets, b_idx)
            if enemy.life <= 0 then
              --Kill enemy and use up the bullet
              table.remove(enemies, e_idx)
              sfx.explosion1:play()
            end
            break
          end
        end
      end
      --See if enemies are touching player
      for e_idx, enemy in ipairs(enemies) do
        dx = math.sqrt(player.x*player.x - enemy.x*enemy.x)
        dy = math.sqrt(player.y*player.y - enemy.y*enemy.y)
        local er = enemy.r
        local pr = player.r
        if CARTESIAN == false then
          er = er/2
          pr = pr/2
        end
        distance = math.sqrt(math.pow(player.x - enemy.x, 2) + math.pow(player.y - enemy.y, 2))
        if distance < er + pr and player.invulnerability == 0 then
          --Collide, causing player life loss and invulnerability
          player.life = player.life - 1
          player.invulnerability = 0.1
          enemy.color = 'red'
          if PAUSE_ON_HIT then
            PAUSED = true
          end
          if player.life == 0 then
            --Player death
            sfx.death1:play()
            current_scene = make_gameover_scene()
            current_scene:load()
          end
        end
      end
    end,

    draw = function(self, dt)
      --Draw Map
      love.graphics.print('Hello World!', 32, 32)
      --Draw Player
      player:draw()
      --Draw Bullets
      for _, bullet in ipairs(bullets) do
        bullet:draw()
      end
      --Draw enemies
      for _, enemy in ipairs(enemies) do
        if enemy.color == 'red' then
          love.graphics.setColor(1,0,0)
        else
          love.graphics.setColor(1,1,1)
        end
        enemy:draw()
        love.graphics.setColor(1,1,1)
      end
      --Draw player life meter
      love.graphics.print("Life: " .. player.life, 80,100)
    end
  }
end

CARTESIAN = true
PAUSED = false
PAUSE_ON_HIT = false
function project_circle(x,y,r)
  local angle = math.pi * 2 * (x / window_px)
  love.graphics.push()
  love.graphics.translate(math.floor(x),0)
  love.graphics.translate(0,math.floor(y))
  love.graphics.draw(sheets.main, animations.player[2], 0, 0, 0, 1, 1, 8, 8)
  love.graphics.circle('fill',0,0,1)
  love.graphics.circle('line',0,0,r)
  love.graphics.pop()
end
--
-- LOVE
--
function love.load()
  -- Pixel game, don't blur
  love.graphics.setDefaultFilter('nearest', 'nearest', 1)
  -- Load Assets
  music = {
    theme0 = love.audio.newSource('music/theme0_v1.mp3','stream'),
    theme1 = love.audio.newSource('music/theme1_v1.mp3','stream'),
    theme2 = love.audio.newSource('music/theme2_v1.mp3','stream'),
    stop = function(self)
      self.theme0:stop()
      self.theme1:stop()
      self.theme2:stop()
    end
  }
  sfx = {
    laser1 = love.audio.newSource('sfx/laser1_v1.wav','static'),
    explosion1 = love.audio.newSource('sfx/explosion1_v1.wav','static'),
    death1 = love.audio.newSource('sfx/death1_v1.wav','static'),
  }
  --TODO Really Really Dumb temporary spritesheet code. Plz maek gud.
  sheets = {}
  animations = {}
  sprites = {}
  local spritesheet_info = read_hash_from_json("sprites/player_ship_forward.json")
  sheets.main = love.graphics.newImage(spritesheet_info.meta.image)
  animations.player = {}
  for k, v in ipairs(spritesheet_info.frames) do
    table.insert(animations.player, love.graphics.newQuad(v.frame.x,v.frame.y,v.frame.w,v.frame.h,sheets.main:getWidth(),sheets.main:getHeight()))
  end
  sprites.bullet = {
    img = love.graphics.newImage("sprites/bullet_energy.png"),
    quad = love.graphics.newQuad(0,0,16,16,16,16)
  }
  sprites.enemy = {
    img = love.graphics.newImage("sprites/enemy_ship_forward.png"),
    quad = love.graphics.newQuad(0,0,16,16,16,16)
  }
  --Run Game
  load_game()
  current_scene = make_title_scene()
  current_scene:load()
end

function love.update(dt)
  if love.keyboard.isDown("r") then
    CARTESIAN = not CARTESIAN
  end
  if not PAUSED then
    current_scene:update(dt)
  else
    if love.keyboard.isDown("space") then
      PAUSED = not PAUSED
    end
  end
end

function love.draw()
  --Scale gameview for pixelated look
  love.graphics.scale(pixel_scale_factor, pixel_scale_factor)
  current_scene:draw()
  --Draw Window Border
  love.graphics.rectangle('line',0,0,window_px,window_px)
end
