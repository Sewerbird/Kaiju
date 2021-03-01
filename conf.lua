pixel_scale_factor = 1
window_px = 256
function love.conf(t)
  t.window.width = window_px * pixel_scale_factor
  t.window.height = window_px * pixel_scale_factor
end
