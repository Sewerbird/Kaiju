local music = {
  muted = false,
  theme0 = love.audio.newSource('music/theme0_v1.mp3','stream'),
  theme1 = love.audio.newSource('music/theme1_v1.mp3','stream'),
  theme2 = love.audio.newSource('music/theme2_v1.mp3','stream'),
  play = function(self,track,do_loop)
    if self.muted then return false end
    self[track]:setLooping(do_loop)
    self[track]:play()
  end,
  mute = function(self)
    self.muted = true
  end,
  unmute = function(self)
    self.muted = false
  end,
  stop = function(self)
    self.theme0:stop()
    self.theme1:stop()
    self.theme2:stop()
  end
}

return music
