local DealMenuOption = function(trade_good, planet)
  return {
    name = trade_good, 
    action = function(self, cmd)
      local tgt_amount = love.keyboard.isDown('z') and 5 or 1
      for i = 1,tgt_amount do
        if cmd == 'left' then
          if planets[planet].shop[trade_good].amount > 0 then
            if player.ledger.cash.balance >= planets[planet].shop[trade_good].sell_price then
              player.shop[trade_good].amount = player.shop[trade_good].amount + 1
              player.ledger.cash.balance = player.ledger.cash.balance - planets[planet].shop[trade_good].sell_price
              planets[planet].shop[trade_good].amount = planets[planet].shop[trade_good].amount - 1
              self.notification = "What a deal!"
              planets[planet]:recalculate_shop()
            else
              self.notification = "Oops, can't afford "..trade_good
            end
          else
            self.notification = "They don't have any "..trade_good.." to sell"
          end
        elseif cmd == 'right' then
          if planets[planet].shop[trade_good].max_amount > planets[planet].shop[trade_good].amount then
            if player.shop[trade_good].amount > 0 then
              player.shop[trade_good].amount = player.shop[trade_good].amount - 1
              player.ledger.cash.balance = player.ledger.cash.balance + planets[planet].shop[trade_good].buy_price
              planets[planet].shop[trade_good].amount = planets[planet].shop[trade_good].amount + 1
              planets[planet]:recalculate_shop()
              self.notification = "Glad I sold that!"
            else
              self.notification = "I don't have any "..trade_good.." to sell"
            end
          else
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
    input = function(self, cmd)
      local menu = self
      if cmd == 'down' then
        menu.notification = nil
        menu.cursor.index = clamp(menu.cursor.index + 1, 1, #menu.options)
      end
      if cmd == 'up' then
        menu.notification = nil
        menu.cursor.index = clamp(menu.cursor.index - 1, 1, #menu.options)
      end
      if cmd == 'x' then
        current_scene.interfaces:pop()
      end
      if menu.options[menu.cursor.index].action then
        if cmd == 'left' then
          menu.options[menu.cursor.index].action(menu,'left')
        elseif cmd == 'right' then
          menu.options[menu.cursor.index].action(menu,'right')
        elseif cmd == 'z' then
          menu.options[menu.cursor.index].action(menu,'z')
        end
      end
    end,
    draw_new = function(self)
      love.graphics.setFont(Font)
      --Draw main select header in the middle
      love.graphics.push()
      local x_offset = WINDOW_PX/2
      love.graphics.translate(x_offset, 0)
      love.graphics.setColor(1,0,0)
      love.graphics.print("Goods", -Font:getWidth("Goods")/2)
      love.graphics.pop()
      --Draw main select column in the middle
      for idx, option in ipairs(self.options) do
        love.graphics.push()
        local x_offset = WINDOW_PX/2
        local y_offset = idx * 16
        local name_width = Font:getWidth(option.name)
        local name_height = Font:getHeight()
        love.graphics.translate(x_offset, y_offset)
        --Draw centered text
        if self.cursor.index == idx then
          love.graphics.setColor(0.9,0.9,0.6)
        else
          love.graphics.setColor(0.7,0.7,0.7)
        end
        love.graphics.print(option.name, -name_width/2,0)
        --Draw selector
        if self.cursor.index == idx then
          love.graphics.setColor(1,1,1)
          love.graphics.draw(sprites.left_arrow_8px.img, sprites.left_arrow_8px.quad, -name_width/2-8-1,0)
          love.graphics.draw(sprites.right_arrow_8px.img, sprites.right_arrow_8px.quad, name_width/2,0)
        end
        love.graphics.pop()
      end
    end,
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

return DealMenu
