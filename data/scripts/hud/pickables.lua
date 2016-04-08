-- Pickables view that temporarily appears when a collectible item is obtained.

local pickables = {}
local visible = false
local jade, stick, amber, alchemy, plume, crystal, plume, ore = 0

function pickables:new(game)
  local object = {}
  setmetatable(object, self)
  self.__index = self

  object:initialize(game)

  return object
end

function pickables:initialize(game)
  self.game = game
  self.surface = sol.surface.create(250, 25)
  self.background_img = sol.surface.create("hud/pickables.png")
  self.jade_text = sol.text_surface.create{ font = "white_digits", horizontal_alignment = "right" }
  if not game:get_value("i1849") then self.jade_displayed = 0 else self.jade_displayed = game:get_value("i1849") end
  self.jade_text:set_text(self.jade_displayed)

  self.stick_text = sol.text_surface.create{ font = "white_digits", horizontal_alignment = "right" }
  if not game:get_value("i1847") then self.stick_displayed = 0 else self.stick_displayed = game:get_value("i1847") end
  self.stick_text:set_text(self.stick_displayed)

  self.amber_text = sol.text_surface.create{ font = "white_digits", horizontal_alignment = "right" }
  if not game:get_value("i1828") then self.amber_displayed = 0 else self.amber_displayed = game:get_value("i1828") end
  self.amber_text:set_text(self.amber_displayed)

  self.alchemy_text = sol.text_surface.create{ font = "white_digits", horizontal_alignment = "right" }
  if not game:get_value("i1830") then self.alchemy_displayed = 0 else self.alchemy_displayed = game:get_value("i1830") end
  self.alchemy_text:set_text(self.alchemy_displayed)

  self.plume_text = sol.text_surface.create{ font = "white_digits", horizontal_alignment = "right" }
  if not game:get_value("i1832") then self.plume_displayed = 0 else self.plume_displayed = game:get_value("i1832") end
  self.plume_text:set_text(self.plume_displayed)

  self.crystal_text = sol.text_surface.create{ font = "white_digits", horizontal_alignment = "right" }
  if not game:get_value("i1834") then self.crystal_displayed = 0 else self.crystal_displayed = game:get_value("i1834") end
  self.crystal_text:set_text(self.crystal_displayed)

  self.ore_text = sol.text_surface.create{ font = "white_digits",  horizontal_alignment = "right" }
  if not game:get_value("i1836") then self.ore_displayed = 0 else self.ore_displayed = game:get_value("i1836") end
  self.ore_text:set_text(self.ore_displayed)

  self:check()
  self:rebuild_surface()
end

function pickables:check()

  local need_rebuild = false
  if not self.game:get_value("i1849") then jade = 0 else jade = self.game:get_value("i1849") end
  if not self.game:get_value("i1847") then stick = 0 else stick = self.game:get_value("i1847") end
  if not self.game:get_value("i1828") then amber = 0 else amber = self.game:get_value("i1828") end
  if not self.game:get_value("i1830") then alchemy = 0 else alchemy = self.game:get_value("i1830") end
  if not self.game:get_value("i1832") then plume = 0 else plume = self.game:get_value("i1832") end
  if not self.game:get_value("i1834") then crystal = 0 else crystal = self.game:get_value("i1834") end
  if not self.game:get_value("i1836") then ore = 0 else ore = self.game:get_value("i1836") end

  -- Current jade.
  if jade ~= self.jade_displayed then
    need_rebuild = true
    local increment
    if jade > self.jade_displayed then
      increment = 1
    else
      increment = -1
    end
    self.jade_text:set_font("blue_digits")
    self.jade_displayed = self.jade_displayed + increment
  end

  -- Current deku sticks.
  if stick ~= self.stick_displayed then
    need_rebuild = true
    local increment
    if stick > self.stick_displayed then
      increment = 1
    else
      increment = -1
    end
    self.stick_text:set_font("blue_digits")
    self.stick_displayed = self.stick_displayed + increment
  end

  -- Current goron amber.
  if amber ~= self.amber_displayed then
    need_rebuild = true
    local increment
    if amber > self.amber_displayed then
      increment = 1
    else
      increment = -1
    end
    self.amber_text:set_font("blue_digits")
    self.amber_displayed = self.amber_displayed + increment
  end

  -- Current alchemy stones.
  if alchemy ~= self.alchemy_displayed then
    need_rebuild = true
    local increment
    if alchemy > self.alchemy_displayed then
      increment = 1
    else
      increment = -1
    end
    self.alchemy_text:set_font("blue_digits")
    self.alchemy_displayed = self.alchemy_displayed + increment
  end

  -- Current goddess plumes.
  if plume ~= self.plume_displayed then
    need_rebuild = true
    local increment
    if plume > self.plume_displayed then
      increment = 1
    else
      increment = -1
    end
    self.plume_text:set_font("blue_digits")
    self.plume_displayed = self.plume_displayed + increment
  end

  -- Current magic crystals.
  if crystal ~= self.crystal_displayed then
    need_rebuild = true
    local increment
    if crystal > self.crystal_displayed then
      increment = 1
    else
      increment = -1
    end
    self.crystal_text:set_font("blue_digits")
    self.crystal_displayed = self.crystal_displayed + increment
  end

  -- Current subrosian ore.
  if ore ~= self.ore_displayed then
    need_rebuild = true
    local increment
    if ore > self.ore_displayed then
      increment = 1
    else
      increment = -1
    end
    self.ore_text:set_font("blue_digits")
    self.ore_displayed = self.ore_displayed + increment
  end

  -- Redraw the surface only if something has changed.
  if need_rebuild then
    self:rebuild_surface()
  end

  -- Schedule the next check.
  sol.timer.start(self, 50, function()
    self:check()
  end)
end

function pickables:rebuild_surface()

  self.surface:clear()

  -- Background
  self.background_img:draw_region(0, 0, 250, 25, self.surface)

  -- Jade (counter).
  if self.jade_displayed == 20 or self.jade_displayed == 50 or self.jade_displayed == 99 then
    self.jade_text:set_font("green_digits")
  else
    if self.jade_text:get_font() ~= "blue_digits" then self.jade_text:set_font("white_digits") end
  end
  self.jade_text:set_text(self.jade_displayed)
  self.jade_text:draw(self.surface, 32, 14)

  -- Sticks (counter).
  if self.stick_displayed == 10 or self.stick_displayed == 25 or self.stick_displayed == 99 then
    self.stick_text:set_font("green_digits")
  else
    if self.stick_text:get_font() ~= "blue_digits" then self.stick_text:set_font("white_digits") end
  end
  self.stick_text:set_text(self.stick_displayed)
  self.stick_text:draw(self.surface, 66, 14)

  -- Amber (counter).
  if self.amber_displayed == 20 or self.amber_displayed == 50 or self.amber_displayed == 99 then
    self.amber_text:set_font("green_digits")
  else
    if self.amber_text:get_font() ~= "blue_digits" then self.amber_text:set_font("white_digits") end
  end
  self.amber_text:set_text(self.amber_displayed)
  self.amber_text:draw(self.surface, 102, 14)

  -- Alchemy (counter).
  if self.alchemy_displayed == 50 or self.alchemy_displayed == 99 then
    self.alchemy_text:set_font("green_digits")
  else
    if self.alchemy_text:get_font() ~= "blue_digits" then self.alchemy_text:set_font("white_digits") end
  end
  self.alchemy_text:set_text(self.alchemy_displayed)
  self.alchemy_text:draw(self.surface, 136, 14)

  -- Plume (counter).
  if self.plume_displayed == 50 or self.plume_displayed == 99 then
    self.plume_text:set_font("green_digits")
  else
    if self.plume_text:get_font() ~= "blue_digits" then self.plume_text:set_font("white_digits") end
  end
  self.plume_text:set_text(self.plume_displayed)
  self.plume_text:draw(self.surface, 170, 14)

  -- Crystal (counter).
  if self.crystal_displayed == 50 or self.crystal_displayed == 99 then
    self.crystal_text:set_font("green_digits")
  else
    if self.crystal_text:get_font() ~= "blue_digits" then self.crystal_text:set_font("white_digits") end
  end
  self.crystal_text:set_text(self.crystal_displayed)
  self.crystal_text:draw(self.surface, 206, 14)

  -- Ore (counter).
  if self.ore_displayed == 50 or self.ore_displayed == 99 then
    self.ore_text:set_font("green_digits")
  else
    if self.ore_text:get_font() ~= "blue_digits" then self.ore_text:set_font("white_digits") end
  end
  self.ore_text:set_text(self.ore_displayed)
  self.ore_text:draw(self.surface, 242, 14)

  visible = true
  sol.timer.start(self.game, 3000, function()
    self.surface:fade_out(20, function() visible = false end)
  end)

end

function pickables:set_dst_position(x, y)
  self.dst_x = x
  self.dst_y = y
end

function pickables:on_draw(dst_surface)

  if visible then
    local x, y = self.dst_x, self.dst_y
    local width, height = dst_surface:get_size()
    if x < 0 then
      x = width + x
    end
    if y < 0 then
      y = height + y
    end

    self.surface:set_opacity(168)
    self.surface:draw(dst_surface, x, y)

  end

end

return pickables