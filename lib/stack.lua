local Stack = function()
  local me = {
    elements = {},
    peek = function(self)
      return self.elements[#self.elements]
    end,
    pop = function(self)
      return table.remove(self.elements, #self.elements)
    end,
    push = function(self, element)
      table.insert(self.elements, element)
    end
  }
  return me
end

return Stack
