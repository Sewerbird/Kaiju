sprites = {
  bullet = {
    img = love.graphics.newImage("sprites/bullet_energy.png"),
    quad = love.graphics.newQuad(0,0,8,8,8,8)
  },
  enemy = {
    img = love.graphics.newImage("sprites/enemy_ship_forward.png"),
    quad = love.graphics.newQuad(0,0,16,16,16,16)
  },
  asteroid1 = {
    img = love.graphics.newImage("sprites/asteroid1_16px_forward.png"),
    quad = love.graphics.newQuad(0,0,16,16,16,16)
  },
  left_arrow_8px = {
    img = love.graphics.newImage("sprites/left_arrow_8px.png"),
    quad = love.graphics.newQuad(0,0,8,8,8,8)
  },
  right_arrow_8px = {
    img = love.graphics.newImage("sprites/right_arrow_8px.png"),
    quad = love.graphics.newQuad(0,0,8,8,8,8)
  },
}

return sprites
