local TitleScene = function ()
  return {
    load = function(self)
      Music:stop()
      Music:play('theme0',true)
    end,

    update = function(self, dt)
      if love.keyboard.isDown("return") then
        local CorridorScene = require('src/corridor_scene')
        current_scene = CorridorScene({entry = 'Aylon', exit = 'Isikur'})
        current_scene:load()
      end
    end,

    draw = function(self)
      love.graphics.print("XENOLOVE",30,48)
    end
  }
end

return TitleScene
