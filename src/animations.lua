local animations = {
  kaiju_16px = {
    left = {},
    lean_left = {},
    forward = {},
    lean_right = {},
    right = {}
  },
  kaiju_16px_thrust = {
    forward = { loop = true },
    left = { loop = true },
    right = { loop = true }
  }
}
for animation_name, legend in pairs(animations) do
  for k, _ in pairs(animations[animation_name]) do
    local metadata = read_lua_from_json("sprites/"..animation_name.."_"..k..".json")
    local animation = {
      name = animation_name.."_"..k,
      img = love.graphics.newImage('sprites/'..metadata.meta.image),
      frames = {},
      next = animations[animation_name][k].next and animations[animation_name][k].next or nil,
      loop = animations[animation_name][k].loop and animations[animation_name][k].loop or nil,
    }
    for k, v in pairs(metadata.frames) do
      local quad = love.graphics.newQuad(
          v.frame.x, v.frame.y,
          v.frame.w, v.frame.h,
          animation.img:getWidth(),animation.img:getHeight()
        )
      animation.frames[tonumber(k)+1] = quad
    end
    animations[animation_name][k] = animation
  end
end

return animations
