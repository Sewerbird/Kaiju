local Stack = require('lib/stack')

local Scene = function(overrides)
  local me = {
    interfaces = Stack(),

    draw = function(self)
      if overrides and overrides.draw then
        overrides.draw(self)
      end
      self.interfaces:peek():draw()
    end,

    update = function(self, dt)
      if overrides and overrides.update then
        overrides.update(self, dt)
      end
      for _, interface in ipairs(self.interfaces.elements) do
        if interface.update then
          interface:update(dt)
        end
      end
    end,

    input = function(self, cmd)
      self.interfaces:peek():input(cmd)
    end,
  }
  return me
end

return Scene
