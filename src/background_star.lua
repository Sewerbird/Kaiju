local Animation = require('src/animation')

local BackgroundStar = function (x,y,dx,dy)
  dx = dx or 0
  dy = dy or 0
  return {
    x = x, y = y, r = rand(0.1,0.2),
    dx = 0, dy = rand(70,100),
    twinkle_animation = Animation('star_8px','blue',rand(0.1,0.15)),
    update = function(self, dt)
      self.twinkle_animation:update(dt)
    end,
    draw = function(self)
      love.graphics.push()
      love.graphics.setColor(1,1,1)
      self.twinkle_animation:draw()
      love.graphics.pop()
    end
  }
end

return BackgroundStar
