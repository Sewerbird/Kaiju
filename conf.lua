pixel_scale_factor = 3
window_px = 256
function love.conf(t)
  t.window.width = window_px * pixel_scale_factor * 16 / 9
  t.window.height = window_px * pixel_scale_factor
end
