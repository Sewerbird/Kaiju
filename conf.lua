--
-- DEBUG FLAGS
--
PAUSED = false
PAUSE_ON_HIT = false
SHOW_COLLIDERS = false
MUTE_MUSIC = true
PRINT_ANIMATION_BANK = true
--
-- DISPLAY CONSTANTS
--
PIXEL_SCALE_FACTOR = 3
ASPECT_RATIO = 16/9
WINDOW_PX = 256
function love.conf(t)
  t.window.width = WINDOW_PX * PIXEL_SCALE_FACTOR * ASPECT_RATIO
  t.window.height = WINDOW_PX * PIXEL_SCALE_FACTOR
  t.window.title = "Xenolove"
end
