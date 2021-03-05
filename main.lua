--
-- GLOBALS
--
PAUSED = false
PAUSE_ON_HIT = false
SHOW_COLLIDERS = false
MUTE_MUSIC = false
--
-- UTILS
--
require 'lib/ed_utils'
inspect = require 'lib/inspect'
--
-- STATE
--
function load_game()
  player = make_player()
  bullets = {}
  enemies = {}
  background_stars = {}

  for i = 1,100 do
    background_stars[i] = make_background_star(rand(0,window_px),rand(0,window_px))
  end
end
--
-- CLASSES
--
function make_animation_instance(animation_group, animation_source)
  return {
    grp = animation_group,
    src = animation_source,
    animation = animations[animation_group][animation_source],
    animation_frame = 1,
    animation_rate = 0.1,
    animation_timer = 0,
    visible = true,
    change = function(self, animation_source) --shift to other animation in animation_group
      if animation_source == self.src then return end
      self.src = animation_source
      self.animation_frame = 1
      self.animation_timer = 0
      self.animation = animations[self.grp][self.src]
    end,
    show = function(self)
      self.visible = true
    end,
    hide = function(self)
      self.visible = false
    end,
    update = function(self, dt)
      self.animation_timer = self.animation_timer + dt
      if self.animation_timer > self.animation_rate then
        self.animation_timer = self.animation_timer - self.animation_rate
        self.animation_frame = self.animation_frame + 1
        if self.animation_frame > #self.animation.frames then
          if self.animation.loop then
            self.animation_frame = 1
          elseif self.animation.next then
            self.animation = animations[animation_group][self.animation.next]
            self.animation_frame = 1
          else
            self.animation_frame = self.animation_frame - 1
          end
        end
      end
    end,
    draw = function(self, dt)
      love.graphics.draw(self.animation.img, self.animation.frames[self.animation_frame], 0, 0, 0,1,1,8,8)
    end
  }
end

function make_player()
  return {
    x = 3, y = 3, --position, in px, in cartesian coordinates
    dx = 50, dy = 50, --velocity, in px/s, in cartesian coordinates
    refire = 0, refire_max = 0.05, active_gun = 'left', --gun rate meter
    life = 10, life_max = 10, --life meter
    invulnerability = 0, --invulnerability period, in seconds
    direction = 'forward', --direction of movement
    ship_animation = make_animation_instance('kaiju_16px','forward'),
    thrust_animation = make_animation_instance('kaiju_16px_thrust','forward'),
    r = 8, --radius, in px

    update = function(self, dt)
      self.ship_animation:update(dt)
      self.thrust_animation:update(dt)
    end,

    move_left = function(self)
      if self.direction ~= left then
        self.direction = 'left'
        self.ship_animation:change('lean_left')
        self.thrust_animation:change('left')
      end
    end,

    move_right = function(self)
      if self.direction ~= right then
        self.direction = 'right'
        self.ship_animation:change('lean_right')
        self.thrust_animation:change('right')
      end
    end,

    move_forward = function(self)
      if self.direction ~= forward then
        self.direction = 'forward'
        self.ship_animation:change('forward')
        self.thrust_animation:show()
        self.thrust_animation:change('forward')
      else
        self.thrust_animation:hide()
      end
    end,
    
    draw = function(self)
      love.graphics.push()
      love.graphics.translate(self.x,self.y)
      self.ship_animation:draw()
      love.graphics.translate(0,16)
      self.thrust_animation:draw()
      if SHOW_COLLIDERS then love.graphics.circle('line',0,0,self.r) end
      love.graphics.pop()
    end
  }
end

function make_bullet(x,y)
  return {
    x = x, y = y, --position, in px
    dx = 0, dy = 200, --velocity, in px/s
    r = 4, --radius, in px
    draw = function(self)
      love.graphics.push()
      love.graphics.draw(sprites.bullet.img, sprites.bullet.quad, self.x, self.y,0,1,1,4,4)
      if SHOW_COLLIDERS then love.graphics.circle('line',self.x,self.y,self.r) end
      love.graphics.pop()
    end
  }
end

function make_background_star(x,y)
  return {
    x = x, y = y, r = 0.1,
    dx = 0, dy = rand(10,300),
    draw = function(self)
      love.graphics.push()
      love.graphics.circle('line',self.x,self.y,self.r)
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
      if SHOW_COLLIDERS then love.graphics.circle('line',self.x,self.y,self.r) end
      love.graphics.pop()
    end
  }
end

function make_title_scene()
  return {
    load = function(self)
      music:stop()
      music:play('theme0',true)
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
      music:play('theme1',true)
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
      music:play('theme2',true)
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
        player:move_right()
      elseif love.keyboard.isDown("left") then
        player.x = player.x - player.dx * dt
        player:move_left()
      else
        player:move_forward()
      end
      --Keep player in movement area
      player.x = clamp(player.x, 0,window_px)
      player.y = clamp(player.y, 32,window_px)
      --Scale player appropriately
      --player.r = 8 * (player.y/window_px)
      --Handle player gun
      player.refire = max(player.refire - dt, 0)
      if love.keyboard.isDown("z") and player.refire == 0 then
        player.refire = player.refire_max
        sfx.laser1:play()
        local spread = player.direction == 'forward' and 7.5 or 5.5
        if player.active_gun == 'left' then
          player.active_gun = 'right'
          table.insert(bullets, make_bullet(player.x+spread,player.y+2))
        else
          player.active_gun = 'left'
          table.insert(bullets, make_bullet(player.x-spread,player.y+2))
        end
      end
      --Spawn an enemy at top of stream, aimed down
      if love.keyboard.isDown("c") then
        table.insert(enemies, make_enemy(rand(0,window_px), 0, rand(-40,40), rand(0,-80)))
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
        enemy.x = enemy.x + enemy.dx * dt
        if enemy.x <= 0 then
          enemy.dx = abs(enemy.dx)
          enemy.x = 0
        end
        if enemy.x >= window_px then
          enemy.dx = -abs(enemy.dx)
          enemy.x = window_px
        end
        enemy.y = enemy.y - enemy.dy * dt
        --Scale enemy appropriately
        --enemy.r = 8 * (enemy.y/window_px)
      end
      --Animate background stars
      for _, star in ipairs(background_stars) do
        star.x = wrap(star.x + star.dx * dt,0,window_px)
        star.y = wrap(star.y + star.dy * dt,0,window_px)
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
        distance = math.sqrt(math.pow(player.x - enemy.x, 2) + math.pow(player.y - enemy.y, 2))
        if distance < enemy.r + player.r and player.invulnerability == 0 then
          --Collide, causing player life loss and invulnerability
          player.life = player.life - 1
          player.invulnerability = 0.1
          enemy.color = 'red'
          if PAUSE_ON_HIT then PAUSED = true end
          if player.life == 0 then
            --Player death
            sfx.death1:play()
            current_scene = make_gameover_scene()
            current_scene:load()
          else
            --Player hurt
            sfx.hurt1:play()
          end
        end
      end
    end,

    draw = function(self, dt)
      --Draw Background Stars
      for _, star in ipairs(background_stars) do
        star:draw()
      end
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
--
-- LOVE
--
function love.load()
  -- Pixel game, don't blur in software. Should be played on a CRT amirite?
  love.graphics.setDefaultFilter('nearest', 'nearest', 1)

  -- Load Assets
  music = {
    theme0 = love.audio.newSource('music/theme0_v1.mp3','stream'),
    theme1 = love.audio.newSource('music/theme1_v1.mp3','stream'),
    theme2 = love.audio.newSource('music/theme2_v1.mp3','stream'),
    play = function(self,track,do_loop)
      if MUTE_MUSIC then return false end
      music[track]:setLooping(do_loop)
      music[track]:play()
    end,
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
    hurt1 = love.audio.newSource('sfx/hurt1_v1.wav','static'),
  }

  sprites = {
    bullet = {
      img = love.graphics.newImage("sprites/bullet_energy.png"),
      quad = love.graphics.newQuad(0,0,8,8,8,8)
    },
    enemy = {
      img = love.graphics.newImage("sprites/enemy_ship_forward.png"),
      quad = love.graphics.newQuad(0,0,16,16,16,16)
    }
  }

  animations = {
    kaiju_16px = {
      left = {},
      lean_left = {},
      forward = {},
      lean_right = {},
      right = {}
    },
    kaiju_16px_thrust = {
      forward = { loop = true },
      left = { loop = true },
      right = { loop = true }
    }
  }
  for animation_name, legend in pairs(animations) do
    for k, _ in pairs(animations[animation_name]) do
      local metadata = read_lua_from_json("sprites/"..animation_name.."_"..k..".json")
      local animation = {
        name = animation_name.."_"..k,
        img = love.graphics.newImage('sprites/'..metadata.meta.image),
        frames = {},
        next = animations[animation_name][k].next and animations[animation_name][k].next or nil,
        loop = animations[animation_name][k].loop and animations[animation_name][k].loop or nil,
      }
      for k, v in pairs(metadata.frames) do
        local quad = love.graphics.newQuad(
            v.frame.x, v.frame.y,
            v.frame.w, v.frame.h,
            animation.img:getWidth(),animation.img:getHeight()
          )
        animation.frames[tonumber(k)+1] = quad
      end
      animations[animation_name][k] = animation
    end
  end
  print(inspect(animations))

  --Run Game
  load_game()
  current_scene = make_title_scene()
  current_scene:load()
end

function love.update(dt)
  if not PAUSED then
    current_scene:update(dt)
  else
    if love.keyboard.isDown("space") then
      PAUSED = not PAUSED
    end
  end
end

function love.draw()
  --Letterbox
  love.graphics.translate(pixel_scale_factor * (window_px*16/9/2-window_px/2),0)
  --Scale gameview for pixelated look
  love.graphics.scale(pixel_scale_factor, pixel_scale_factor)
  current_scene:draw()
  --Draw Window Border
  love.graphics.rectangle('line',0,0,window_px,window_px)
end
