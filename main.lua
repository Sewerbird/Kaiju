--
-- DEBUG FLAGS
--
PAUSED = false
PAUSE_ON_HIT = false
SHOW_COLLIDERS = false
MUTE_MUSIC = false
PRINT_ANIMATION_BANK = true
--
-- UTILS
--
require 'lib/ed_utils'
inspect = require 'lib/inspect'
--
-- LOVE
--
function love.load()
  -- Pixel game, don't blur in software. Should be played on a CRT amirite?
  love.graphics.setDefaultFilter('nearest', 'nearest', 1)

  -- Load Asset Singletons
  Music = require('src/music')
  Sfx = require('src/sfx')
  Sprites = require('src/sprites')
  Animations = require('src/animations')

  --Debug Flags
  if PRINT_ANIMATION_BANK then print(inspect(Animations)) end
  if MUTE_MUSIC then Music:mute() end

  --Startup
  local TitleScene = require('src/title_scene')
  local Player = require('src/player')
  player = Player()
  current_scene = TitleScene()
  current_scene:load()
end

function love.update(dt)
  if not PAUSED then
    current_scene:update(dt)
  else
    if love.keyboard.isDown("space") then
      PAUSED = not PAUSED
    end
  end
end

function love.draw()
  --Letterbox
  love.graphics.translate(PIXEL_SCALE_FACTOR * (WINDOW_PX*16/9/2-WINDOW_PX/2),0)
  --Scale gameview for pixelated look
  love.graphics.scale(PIXEL_SCALE_FACTOR, PIXEL_SCALE_FACTOR)
  current_scene:draw()
  --Draw Window Border
  love.graphics.rectangle('line',0,0,WINDOW_PX,WINDOW_PX)
end
