PIXEL_SCALE_FACTOR = 3
WINDOW_PX = 256
LETTERBOX = true
SCALED = true
function love.conf(t)
  if LETTERBOX then
    t.window.width = WINDOW_PX * PIXEL_SCALE_FACTOR * 16 / 9
  else
    t.window.width = WINDOW_PX * PIXEL_SCALE_FACTOR
  end
  t.window.height = WINDOW_PX * PIXEL_SCALE_FACTOR

end
