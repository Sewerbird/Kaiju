local Scene = require('src/scene')
local DealInterface = require('src/orbit_deal_interface')
local ExitInterface = require('src/orbit_exit_interface')
local ActionInterface = require('src/orbit_action_interface')

local OrbitScene = function(planet)
  local me = Scene(
    {
      draw = function(self)
        --Draw Stars
        for _, star in ipairs(self.background_stars) do
          love.graphics.push()
          love.graphics.translate(star.x,star.y)
          star:draw(dt)
          love.graphics.pop()
        end
        --Draw Wallet
        love.graphics.setFont(Font)
        love.graphics.push()
        local money_string = "$"..flr(player.ledger.cash.balance)
        love.graphics.setColor(0.3,0.9,0.2)
        love.graphics.translate(WINDOW_PX - Font:getWidth(money_string),0)
        love.graphics.print(money_string)
        love.graphics.pop()
      end,

      update = function(self, dt)
        for _,star in ipairs(self.background_stars) do
          star:update(dt)
        end
      end
    }
  )

  me.placename = planets[planet].placename
  me.background_stars = planets[planet].background_stars
  me.deal_menu = DealInterface(me.placename)
  me.exit_menu = ExitInterface(me.placename)
  me.action_menu = ActionInterface(me.placename)
  me.interfaces:push(me.action_menu)

  Music:stop()
  Music:play('theme0',true)

  return me
end

return OrbitScene
