local ActionMenu = function(title)
  return {
    title = title,
    cursor = {index = 1, rate = 0.2, timer = 0},
    options = {
      {
        name = 'Deal', action = function(self, cmd)
          current_scene.interfaces:push(current_scene.deal_menu)
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
          current_scene.interfaces:push(current_scene.exit_menu)
        end
      },
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
        self.interfaces:pop()
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

return ActionMenu
