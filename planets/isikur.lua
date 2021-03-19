local BackgroundStar = require('src/background_star')
local Isikur = require('src/planet')()

Isikur.placename = 'Isikur'
Isikur.neighbors = { 'Hydromeda', 'Aylon' }
for i = 1,100 do
  table.insert(Isikur.background_stars, BackgroundStar(rand(0,WINDOW_PX),rand(0,WINDOW_PX),0,0))
end

return Isikur
