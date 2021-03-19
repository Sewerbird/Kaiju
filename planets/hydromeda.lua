local BackgroundStar = require('src/background_star')
local Hydromeda = require('src/planet')()

Hydromeda.placename = 'Hydromeda'
Hydromeda.neighbors = { 'Isikur', 'Penteuch' }
for i = 1,100 do
  table.insert(Hydromeda.background_stars, BackgroundStar(rand(0,WINDOW_PX),rand(0,WINDOW_PX),0,0))
end

return Hydromeda
