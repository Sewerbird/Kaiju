local BackgroundStar = require('src/background_star')

local Isikur = {
  placename = 'Isikur',
  background_stars = {},
  shop = {
    Chips = { buy_price = 1, sell_price = 10, amount = 100, desired_amount = 64, max_amount = 128 },
    Warez = { buy_price = 10, sell_price = 1, amount = 100, desired_amount = 64, max_amount = 128 },
    Art = { buy_price = 1, sell_price = 90, amount = 100, desired_amount = 64, max_amount = 128 },
    Tools = { buy_price = 90, sell_price = 1, amount = 100, desired_amount = 64, max_amount = 128 },
    Guns = { buy_price = 100, sell_price = 1, amount = 100, desired_amount = 64, max_amount = 128 },
    Energy = { buy_price = 1, sell_price = 100, amount = 100, desired_amount = 64, max_amount = 128 },
  },
  recalculate_shop = function(self)
    for key, ware in pairs(self.shop) do
      local base_price = 10
      local margin = 0.1
      local tax = 0.1
      ware.buy_price = base_price * 4 * math.exp(ware.amount/ware.desired_amount*-math.log(4))
      ware.sell_price = (1+margin+tax) * ware.buy_price
    end
  end,
  randomize_shop_supplies = function(self)
    for key, ware in pairs(self.shop) do
      ware.amount = flr(rand(10,100))
    end
    self:recalculate_shop()
  end
}
for i = 1,100 do
  table.insert(Isikur.background_stars, BackgroundStar(rand(0,WINDOW_PX),rand(0,WINDOW_PX),0,0))
end

return Isikur
