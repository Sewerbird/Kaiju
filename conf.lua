PIXEL_SCALE_FACTOR = 3
WINDOW_PX = 256
function love.conf(t)
  t.window.width = WINDOW_PX * PIXEL_SCALE_FACTOR * 16 / 9
  t.window.height = WINDOW_PX * PIXEL_SCALE_FACTOR
end
