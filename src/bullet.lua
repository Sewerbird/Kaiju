local Bullet = function (x,y)
  return {
    x = x, y = y, --position, in px
    dx = 0, dy = 200, --velocity, in px/s
    r = 4, --radius, in px

    draw = function(self)
      love.graphics.push()
      love.graphics.draw(Sprites.bullet.img, Sprites.bullet.quad, self.x, self.y,0,1,1,4,4)
      if SHOW_COLLIDERS then love.graphics.circle('line',self.x,self.y,self.r) end
      love.graphics.pop()
    end
  }
end

return Bullet
