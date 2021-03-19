local Planet = function()
  me = {
    placename = 'Name Here',
    background_stars = {},
    neighbors = {},
    shop = {
      Chips = { desired_amount = 64, max_amount = 128 },
      Warez = { desired_amount = 64, max_amount = 128 },
      Art = { desired_amount = 64, max_amount = 128 },
      Tools = { desired_amount = 64, max_amount = 128 },
      Guns = { desired_amount = 64, max_amount = 128 },
      Energy = { desired_amount = 64, max_amount = 128 },
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
  me:randomize_shop_supplies()
  return me
end

return Planet
