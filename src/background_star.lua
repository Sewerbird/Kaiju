local BackgroundStar = function (x,y)
  return {
    x = x, y = y, r = rand(0.1,0.2),
    dx = 0, dy = rand(10,300),
    draw = function(self)
      love.graphics.push()
      love.graphics.circle('line',self.x,self.y,self.r)
      love.graphics.pop()
    end
  }
end

return BackgroundStar
