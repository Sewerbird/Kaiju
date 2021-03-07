local GameoverScene = function ()
  return {
    load = function(self)
      Music:stop()
      Music:play('theme1',true)
    end,

    update = function(self, dt)
      if love.keyboard.isDown("return") then
        love.event.quit()
      end
      if love.keyboard.isDown("space") then
        --Reset
        love.load()
        --Reload
        local TitleScene = require('src/title_scene')
        current_scene = TitleScene()
        current_scene:load()
      end
    end,

    draw = function(self)
      love.graphics.print("GAME OVER",30,48)
    end
  }
end

return GameoverScene
