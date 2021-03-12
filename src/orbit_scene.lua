local DealMenuOption = function(trade_good, planet)
  return {
    name = trade_good, action = function(self, cmd)
      local tgt_amount = love.keyboard.isDown('z') and 5 or 1
      for i = 1,tgt_amount do
        if cmd == 'left' then
          if planets[planet].shop[trade_good].amount > 0 then
            if player.ledger.cash.balance >= planets[planet].shop[trade_good].sell_price then
              print("Buying "..trade_good)
              player.shop[trade_good].amount = player.shop[trade_good].amount + 1
              player.ledger.cash.balance = player.ledger.cash.balance - planets[planet].shop[trade_good].sell_price
              planets[planet].shop[trade_good].amount = planets[planet].shop[trade_good].amount - 1
              self.notification = "What a deal!"
              planets[planet]:recalculate_shop()
            else
              print("Oops, can't afford "..trade_good)
              self.notification = "Oops, can't afford "..trade_good
            end
          else
            print("They don't have any "..trade_good.." to sell")
            self.notification = "They don't have any "..trade_good.." to sell"
          end
        elseif cmd == 'right' then
          if planets[planet].shop[trade_good].max_amount > planets[planet].shop[trade_good].amount then
            if player.shop[trade_good].amount > 0 then
              print("Selling "..trade_good)
              player.shop[trade_good].amount = player.shop[trade_good].amount - 1
              player.ledger.cash.balance = player.ledger.cash.balance + planets[planet].shop[trade_good].buy_price
              planets[planet].shop[trade_good].amount = planets[planet].shop[trade_good].amount + 1
              planets[planet]:recalculate_shop()
              self.notification = "Glad I sold that!"
            else
              print("I don't have any "..trade_good.." to sell")
              self.notification = "I don't have any "..trade_good.." to sell"
            end
          else
            print("They don't want any more "..trade_good)
            self.notification = "They don't want any more "..trade_good
          end
        end
      end
    end
  }
end

local DealMenu = function(planet)
  return {
    planet = planet,
    title = "Ship  Buy   Good   Sell  Dock",
    cursor = {index = 1, rate = 0.2, timer = 0},
    options = {
      DealMenuOption('Chips', planet),
      DealMenuOption('Warez', planet),
      DealMenuOption('Art', planet),
      DealMenuOption('Tools', planet),
      DealMenuOption('Guns', planet),
      DealMenuOption('Energy', planet)
    },
    draw = function(self)
      love.graphics.setFont(Font)
      love.graphics.push()
      love.graphics.translate(0,32)
      local center_offset = (WINDOW_PX/2)-(Font:getWidth(self.title)/2)
      love.graphics.translate(center_offset,16)
      love.graphics.print(self.title)
      love.graphics.translate(-center_offset,0)
      for idx, option in ipairs(self.options) do
        local center_offset = (WINDOW_PX/2)
        love.graphics.translate(center_offset,16)
        --Draw Resource
        if self.cursor.index == idx then
          love.graphics.setColor(0.9,0.9,0.6)
        else
          love.graphics.setColor(0.7,0.7,0.7)
        end
        love.graphics.push()
        love.graphics.translate(-(Font:getWidth(option.name)/2),0)
        love.graphics.print(option.name, 0, 0)
        --Draw Cursor
        if self.cursor.index == idx then
          love.graphics.setColor(0.9,0.9,0.3)
          love.graphics.rectangle('line',-2,0,2+Font:getWidth(option.name),Font:getHeight())
          love.graphics.setColor(1,1,1)
          love.graphics.draw(sprites.left_arrow_8px.img, sprites.left_arrow_8px.quad, -2-9,2)
          love.graphics.draw(sprites.right_arrow_8px.img, sprites.right_arrow_8px.quad, Font:getWidth(option.name)+1,2)
        end
        love.graphics.pop()
        local buy_string = "$"..flr(planets[planet].shop[option.name].buy_price)
        local sell_string = "$"..flr(planets[planet].shop[option.name].sell_price)
        --Draw Sell Price
        love.graphics.push()
        love.graphics.translate(-30-Font:getWidth(sell_string),0)
        love.graphics.print(sell_string)
        love.graphics.pop()
        --Draw Buy Price
        love.graphics.push()
        love.graphics.translate(30,0)
        love.graphics.print(buy_string)
        love.graphics.pop()
        --Draw Ship Stock
        local ship_stock_string = player.shop[option.name].amount
        love.graphics.push()
        love.graphics.translate(-70-Font:getWidth(ship_stock_string),0)
        love.graphics.print(ship_stock_string)
        love.graphics.pop()
        --Draw Dock Stock
        local dock_stock_string = planets[planet].shop[option.name].amount
        love.graphics.push()
        love.graphics.translate(70,0)
        love.graphics.print(dock_stock_string)
        love.graphics.pop()
        love.graphics.translate(-center_offset,0)
      end
      love.graphics.pop()
      if self.notification ~= nil then
        love.graphics.setColor(1,1,1)
        love.graphics.print(self.notification,WINDOW_PX/2-Font:getWidth(self.notification)/2,WINDOW_PX-16)
      end
    end
  }
end

local ActionMenu = function(title)
  return {
    title = title,
    cursor = {index = 1, rate = 0.2, timer = 0},
    options = {
      {
        name = 'Deal', action = function(self, cmd)
          current_scene.active_menu = 'deal_menu'
        end
      },
      {
        name = 'Dock', action = function(self, cmd)
          self.notification = 'Dock temporarily closed'
        end
      },
      {
        name = 'Talk', action = function(self, cmd)
          self.notification = 'No one is answering...'
        end
      },
      {
        name = 'Scan', action = function(self, cmd)
          self.notification = 'No targets found...'
        end
      },
      {
        name = 'Info', action = function(self, cmd)
          self.notification = "Welcome to "..self.title
        end
      },
      {
        name = 'Exit', action = function(self, cmd)
          local CorridorScene = require('src/corridor_scene')
          current_scene = CorridorScene()
          current_scene:load()
        end
      },
    },
    draw = function(self)
      love.graphics.setFont(Font)
      love.graphics.push()
      love.graphics.translate(8,0)
      love.graphics.setColor(1,1,1)
      love.graphics.print(self.title)
      for idx, option in ipairs(self.options) do
        love.graphics.translate(0,16)
        if self.cursor.index == idx then
          love.graphics.setColor(0.9,0.9,0.6)
        else
          love.graphics.setColor(0.7,0.7,0.7)
        end
        love.graphics.print(option.name)
      end
      love.graphics.pop()
      if self.notification ~= nil then
        love.graphics.setColor(1,1,1)
        love.graphics.print(self.notification,WINDOW_PX/2-Font:getWidth(self.notification)/2,WINDOW_PX-16)
      end
    end
  }
end

local OrbitScene = function ()
  return {
    load = function(self, planet)
      self.placename = planets[planet].placename
      self.background_stars = planets[planet].background_stars
      self.deal_menu = DealMenu(self.placename)
      self.action_menu = ActionMenu(self.placename)

      self.active_menu = 'action_menu'
      Music:stop()
      Music:play('theme0',true)
    end,

    update = function(self, dt)
      local menu = self[self.active_menu]
      menu.cursor.timer = max(menu.cursor.timer - dt, 0)
      local can_nav = menu.cursor.timer == 0
      --Navigate menu
      if can_nav and love.keyboard.isDown('down') then
        menu.notification = nil
        menu.cursor.timer = menu.cursor.rate
        menu.cursor.index = clamp(menu.cursor.index + 1, 1, #menu.options)
      end
      if can_nav and love.keyboard.isDown('up') then
        menu.notification = nil
        menu.cursor.timer = menu.cursor.rate
        menu.cursor.index = clamp(menu.cursor.index - 1, 1, #menu.options)
      end
      if can_nav and (love.keyboard.isDown('z') or love.keyboard.isDown('left') or love.keyboard.isDown('right')) then
        menu.cursor.timer = menu.cursor.rate
        if menu.options[menu.cursor.index].action then
          if love.keyboard.isDown('left') then
            menu.options[menu.cursor.index].action(menu,'left')
          elseif love.keyboard.isDown('right') then
            menu.options[menu.cursor.index].action(menu,'right')
          elseif love.keyboard.isDown('z') then
            menu.options[menu.cursor.index].action(menu,'z')
          end
        end
      end
      if can_nav and (love.keyboard.isDown('x')) then
        self.active_menu = 'action_menu'
      end
      for _, star in ipairs(self.background_stars) do
        star:update(dt)
      end
    end,

    draw = function(self)
      love.graphics.push()
      love.graphics.translate(0,0)
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
      --Draw Menu
      self[self.active_menu]:draw()
      love.graphics.pop()
    end,
  }
end

return OrbitScene
