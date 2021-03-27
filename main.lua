require 'lib/ed_utils'
inspect = require 'lib/inspect'

function love.load()
  -- Pixel game, don't blur in software. Should be played on a CRT amirite?
  love.graphics.setDefaultFilter('nearest', 'nearest', 1)

  -- Asset Singletons
  Music = require('src/music')
  Sfx = require('src/sfx')
  Sprites = require('src/sprites')
  Animations = require('src/animations')
  Font = love.graphics.newFont('sprites/small_pixel.ttf',8,'mono')

  -- Global Gamestate
  current_scene = require('src/title_scene')()
  player = require('src/player')()
  planets = {
    Isikur = require('planets/isikur'),
    Hydromeda = require('planets/hydromeda'),
    Aylon = require('planets/aylon'),
    Penteuch = require('planets/penteuch'),
    Kyomai = require('planets/kyomai'),
  }

  --Start
  if PRINT_ANIMATION_BANK then print(inspect(Animations)) end
  if MUTE_MUSIC then Music:mute() end

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
  love.graphics.scale(PIXEL_SCALE_FACTOR, PIXEL_SCALE_FACTOR)
  local offset = WINDOW_PX * (ASPECT_RATIO - 1)/2
  love.graphics.translate(offset, 0)
  love.graphics.setColor(1, 1, 1)
  current_scene:draw()
  love.graphics.setColor(0.03, 0.03, 0.04)
  love.graphics.rectangle('fill', -offset, 0, offset, WINDOW_PX)
  love.graphics.rectangle('fill', WINDOW_PX, 0, offset, WINDOW_PX)
end

function love.keypressed(key)
  if current_scene.input then
    current_scene:input(key)
  end
end
