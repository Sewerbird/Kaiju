local BackgroundStar = require('src/background_star')
local Aylon = require('src/planet')()

Aylon.placename = 'Aylon'
Aylon.neighbors = { 'Kyomai', 'Isikur', 'Penteuch' }
for i = 1,100 do
  table.insert(Aylon.background_stars, BackgroundStar(rand(0,WINDOW_PX),rand(0,WINDOW_PX),0,0))
end

return Aylon
