local Player = require('src/player')
local Bullet = require('src/bullet')
local BackgroundStar = require('src/background_star')
local Enemy = require('src/enemy')

local CorridorScene = function (configuration)
  return {
    load = function(self)
      self.bullets = {}
      self.enemies = {}
      self.background_stars = {}
      self.exit_system = configuration.exit --System name this corridor exits into
      self.entry_system = configuration.entry --System name this corridor began with
      player.x = WINDOW_PX/2
      player.y = WINDOW_PX*3/4
      for i = 1,100 do
        self.background_stars[i] = BackgroundStar(rand(0,WINDOW_PX),rand(0,WINDOW_PX))
      end
      Music:stop()
      Music:play('theme2',true)
    end,

    update = function(self, dt)
      player:update(dt)
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
      player.x = clamp(player.x, 0,WINDOW_PX)
      player.y = clamp(player.y, 32,WINDOW_PX-16)
      --Handle player gun
      if love.keyboard.isDown("z") then
        local bullet = player:shoot()
        if bullet then
          bullet.x = bullet.x + player.x
          bullet.y = bullet.y + player.y
          Sfx.laser1:play()
          player.ledger.cash.balance = player.ledger.cash.balance - 1
          table.insert(self.bullets, bullet)
        end
      end
      --Spawn an enemy at top of stream, aimed down
      if love.keyboard.isDown("c") then
        table.insert(self.enemies, Enemy(rand(0,WINDOW_PX), 0, rand(-40,40), rand(0,-80)))
      end
      --Force finish stage
      if love.keyboard.isDown('n') then
        planets[self.exit_system]:randomize_shop_supplies()
        local OrbitScene = require('src/orbit_scene')
        current_scene = OrbitScene(self.exit_system)
      end
      --Cleanup offscreen things
      for i, bullet in ipairs(self.bullets) do
        if bullet.x > WINDOW_PX or bullet.x < 0 or bullet.y > WINDOW_PX or bullet.y < 0 then
          table.remove(self.bullets, i)
        end
      end
      for i, enemy in ipairs(self.enemies) do
        if enemy.x > WINDOW_PX or enemy.x < 0 or enemy.y > WINDOW_PX or enemy.y < 0 then
          table.remove(self.enemies, i)
        end
      end
      --Animate bullets
      for _, bullet in ipairs(self.bullets) do
        bullet.x = bullet.x + bullet.dx * dt
        bullet.y = bullet.y - bullet.dy * dt
      end
      --Animate enemies
      for _, enemy in ipairs(self.enemies) do
        enemy.x = enemy.x + enemy.dx * dt
        if enemy.x <= 0 then
          enemy.dx = abs(enemy.dx)
          enemy.x = 0
        end
        if enemy.x >= WINDOW_PX then
          enemy.dx = -abs(enemy.dx)
          enemy.x = WINDOW_PX
        end
        enemy.y = enemy.y - enemy.dy * dt
      end
      --Animate background stars
      for _, star in ipairs(self.background_stars) do
        star.x = wrap(star.x + star.dx * dt,0,WINDOW_PX)
        star.y = wrap(star.y + star.dy * dt,0,WINDOW_PX)
        star:update(dt)
      end
      --See if bullets are touching enemies
      for b_idx, bullet in ipairs(self.bullets) do
        for e_idx, enemy in ipairs(self.enemies) do
          dx = math.sqrt(bullet.x*bullet.x - enemy.x*enemy.x)
          dy = math.sqrt(bullet.y*bullet.y - enemy.y*enemy.y)
          distance = math.sqrt(math.pow(bullet.x - enemy.x, 2) + math.pow(bullet.y - enemy.y, 2))
          if distance < bullet.r + enemy.r then
            --Damage the enemy and use up the bullet
            enemy.life = enemy.life - 1
            table.remove(self.bullets, b_idx)
            if enemy.life <= 0 then
              --Kill enemy and use up the bullet
              table.remove(self.enemies, e_idx)
              Sfx.explosion1:play()
            end
            break
          end
        end
      end
      --See if enemies are touching player
      for e_idx, enemy in ipairs(self.enemies) do
        distance = math.sqrt(math.pow(player.x - enemy.x, 2) + math.pow(player.y - enemy.y, 2))
        if distance < enemy.r + player.r and player.invulnerability == 0 then
          --Collide, causing player life loss and invulnerability
          player.life = player.life - 1
          player.invulnerability = 0.5
          enemy.color = 'red'
          if PAUSE_ON_HIT then PAUSED = true end
          if player.life == 0 then
            --Player death
            Sfx.death1:play()
            local GameoverScene = require('src/gameover_scene')
            current_scene = GameoverScene()
            current_scene:load()
          else
            --Player hurt
            Sfx.hurt1:play()
          end
        end
      end
    end,

    draw = function(self, dt)
      --Draw Background Stars
      for _, star in ipairs(self.background_stars) do
        love.graphics.push()
        love.graphics.translate(star.x, star.y)
        star:draw()
        love.graphics.pop()
      end
      --Draw Player
      player:draw()
      --Draw Bullets
      for _, bullet in ipairs(self.bullets) do
        bullet:draw()
      end
      --Draw enemies
      for _, enemy in ipairs(self.enemies) do
        if enemy.color == 'red' then
          love.graphics.setColor(1,0,0)
        else
          love.graphics.setColor(1,1,1)
        end
        enemy:draw()
        love.graphics.setColor(1,1,1)
      end
      --Draw player life meter
      love.graphics.setFont(Font)
      love.graphics.print("Life: " .. player.life, 80,100)
      --Draw Wallet
      love.graphics.setFont(Font)
      love.graphics.push()
      local money_string = "$"..flr(player.ledger.cash.balance)
      love.graphics.setColor(0.3,0.9,0.2)
      love.graphics.translate(WINDOW_PX - Font:getWidth(money_string),0)
      love.graphics.print(money_string)
      love.graphics.pop()
    end
  }
end

return CorridorScene
