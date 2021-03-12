local Animation = require('src/animation')
local Bullet = require('src/bullet')

local Player = function ()
  return {
    x = 3, y = 3, --position, in px, in cartesian coordinates
    dx = 50, dy = 50, --velocity, in px/s, in cartesian coordinates
    refire = 0, refire_max = 0.05, active_gun = 'left', --gun rate meter
    heat = 0, heat_max = 1.0, cool_rate = 2.0,
    life = 10, life_max = 10, --life meter
    invulnerability = 1.5, --invulnerability period, in seconds
    direction = 'forward', --direction of movement
    ship_animation = Animation('kaiju_16px','forward',0.1),
    thrust_animation = Animation('kaiju_16px_thrust','forward',0.03),
    r = 8, --radius, in px
    ledger = {
      cash = { balance = 0 },
      stocks = {
        { location = 'Isikur', company = 'Hydrocorp', avg_buy_cost = 100, shares = 0 }
      },
    },
    shop = {
      Chips = { buy_price = 1, sell_price = 10, amount = 100, max_amount = 128 },
      Warez = { buy_price = 10, sell_price = 1, amount = 100, max_amount = 128 },
      Art = { buy_price = 1, sell_price = 90, amount = 100, max_amount = 128 },
      Tools = { buy_price = 90, sell_price = 1, amount = 100, max_amount = 128 },
      Guns = { buy_price = 100, sell_price = 1, amount = 100, max_amount = 128 },
      Energy = { buy_price = 1, sell_price = 100, amount = 100, max_amount = 128 },
    },

    update = function(self, dt)
      -- Update gun cooloff
      self.refire = max(self.refire - dt, 0)
      -- Update self heat
      self.heat = max(self.heat - (dt * self.cool_rate), 0)
      -- Update self invulnerability timer
      self.invulnerability = max(self.invulnerability - dt, 0)
      -- Update player animations
      self.ship_animation:update(dt)
      self.thrust_animation:update(dt)
    end,

    shoot = function(self)
      if self.refire > 0 then
        return false
      else
        self.heat = self.heat + 0.5
        self.refire = self.refire_max
        if self.active_gun == 'left' then
          self.active_gun = 'right'
        else
          self.active_gun = 'left'
        end
        local spread = self.direction == 'forward' and 7.5 or 5.5
        if self.active_gun == 'left' then spread = -spread end
        return Bullet(spread, 2)
      end
    end,

    move_left = function(self)
      if self.direction ~= 'left' then
        self.direction = 'left'
        self.ship_animation:change('lean_left')
        self.thrust_animation:change('left')
      end
    end,

    move_right = function(self)
      if self.direction ~= 'right' then
        self.direction = 'right'
        self.ship_animation:change('lean_right')
        self.thrust_animation:change('right')
      end
    end,

    move_forward = function(self)
      if self.direction ~= 'forward' then
        self.direction = 'forward'
        self.ship_animation:change('forward')
        self.thrust_animation:change('forward')
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

return Player
