local BackgroundStar = require('src/background_star')
local Penteuch = require('src/planet')()

Penteuch.placename = 'Penteuch'
Penteuch.neighbors = { 'Aylon', 'Hydromeda' }
for i = 1,100 do
  table.insert(Penteuch.background_stars, BackgroundStar(rand(0,WINDOW_PX),rand(0,WINDOW_PX),0,0))
end

return Penteuch
