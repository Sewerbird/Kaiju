Enemy = function (x,y,dx,dy)
  return {
    x = x, y = y, --position, in px
    dx = dx, dy = dy,
    life = 1, life_max = 1, --life meter
    r = 8, --radius, in px
    draw = function(self)
      love.graphics.push()
      love.graphics.draw(Sprites.asteroid1.img, Sprites.asteroid1.quad, self.x, self.y,0,1,1,8,8)
      if SHOW_COLLIDERS then love.graphics.circle('line',self.x,self.y,self.r) end
      love.graphics.pop()
    end
  }
end

return Enemy
