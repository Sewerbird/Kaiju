local Animation = function (animation_group, animation_source, animation_rate)
  return {
    grp = animation_group,
    src = animation_source,
    animation = Animations[animation_group][animation_source],
    animation_frame = 1,
    animation_rate = animation_rate and animation_rate or 0.1,
    animation_timer = 0,
    visible = true,

    change = function(self, animation_source) --shift to other animation in animation_group
      if animation_source == self.src then return end
      self.src = animation_source
      self.animation_frame = 1
      self.animation_timer = 0
      self.animation = Animations[self.grp][self.src]
    end,

    show = function(self)
      self.visible = true
    end,

    hide = function(self)
      self.visible = false
    end,

    update = function(self, dt)
      if animation_rate < 0 then self.animation.loop = false end
      self.animation_timer = self.animation_timer + dt
      if self.animation_timer > self.animation_rate then
        self.animation_timer = self.animation_timer - self.animation_rate
        self.animation_frame = self.animation_frame + 1
        if self.animation_frame > #self.animation.frames then
          if self.animation.loop then
            self.animation_frame = 1
          elseif self.animation.next then
            self.animation = Animations[animation_group][self.animation.next]
            self.animation_frame = 1
          else
            self.animation_frame = self.animation_frame - 1
          end
        end
      end
    end,

    draw = function(self, dt)
      if self.visible then
        love.graphics.draw(self.animation.img, self.animation.frames[self.animation_frame], 0, 0, 0,1,1,8,8)
      end
    end
  }
end

return Animation
