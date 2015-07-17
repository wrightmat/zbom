-- Pickables view that temporarily appears when a collectible item is obtained.

local pickables = {}
local visible = false

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
  self.jade_text = sol.text_surface.create{
    font = "white_digits",
    horizontal_alignment = "right",
  }
  self.jade_text:set_text(game:get_value("i1849"))
  self.jade_displayed = game:get_value("i1849")

  self.stick_text = sol.text_surface.create{
    font = "white_digits",
    horizontal_alignment = "right",
  }
  self.stick_text:set_text(game:get_value("i1847"))
  self.stick_displayed = game:get_value("i1847")

  self.amber_text = sol.text_surface.create{
    font = "white_digits",
    horizontal_alignment = "right",
  }
  self.amber_text:set_text(game:get_value("i1828"))
  self.amber_displayed = game:get_value("i1828")

  self.alchemy_text = sol.text_surface.create{
    font = "white_digits",
    horizontal_alignment = "right",
  }
  self.alchemy_text:set_text(game:get_value("i1830"))
  self.alchemy_displayed = game:get_value("i1830")

  self.plume_text = sol.text_surface.create{
    font = "white_digits",
    horizontal_alignment = "right",
  }
  self.plume_text:set_text(game:get_value("i1832"))
  self.plume_displayed = game:get_value("i1832")

  self.crystal_text = sol.text_surface.create{
    font = "white_digits",
    horizontal_alignment = "right",
  }
  self.crystal_text:set_text(game:get_value("i1834"))
  self.crystal_displayed = game:get_value("i1834")

  self.ore_text = sol.text_surface.create{
    font = "white_digits",
    horizontal_alignment = "right",
  }
  self.ore_text:set_text(game:get_value("i1836"))
  self.ore_displayed = game:get_value("i1836")

  self:check()
  self:rebuild_surface()
end

function pickables:check()

  local need_rebuild = false
  local jade = self.game:get_value("i1849")
  if jade == nil then jade = 0 end
  local stick = self.game:get_value("i1847")
  if stick == nil then stick = 0 end
  local amber = self.game:get_value("i1828")
  if amber == nil then amber = 0 end
  local alchemy = self.game:get_value("i1830")
  if alchemy == nil then amber = 0 end
  local plume = self.game:get_value("i1832")
  if plume == nil then plume = 0 end
  local crystal = self.game:get_value("i1834")
  if crystal == nil then crystal = 0 end
  local ore = self.game:get_value("i1836")
  if crystal == nil then crystal = 0 end

  -- Current jade.
  if jade ~= self.jade_displayed then
    need_rebuild = true
    local increment
    if jade > self.jade_displayed then
      increment = 1
    else
      increment = -1
    end
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
  if self.jade_displayed == 99 then self.jade_text:set_font("green_digits") else self.jade_text:set_font("white_digits") end
  self.jade_text:set_text(self.jade_displayed)
  self.jade_text:draw(self.surface, 32, 14)

  -- Sticks (counter).
  if self.stick_displayed == 99 then self.stick_text:set_font("green_digits") else self.stick_text:set_font("white_digits") end
  self.stick_text:set_text(self.stick_displayed)
  self.stick_text:draw(self.surface, 66, 14)

  -- Amber (counter).
  if self.amber_displayed == 99 then self.amber_text:set_font("green_digits") else self.amber_text:set_font("white_digits") end
  self.amber_text:set_text(self.amber_displayed)
  self.amber_text:draw(self.surface, 102, 14)

  -- Alchemy (counter).
  if self.alchemy_displayed == 99 then self.alchemy_text:set_font("green_digits") else self.alchemy_text:set_font("white_digits") end
  self.alchemy_text:set_text(self.alchemy_displayed)
  self.alchemy_text:draw(self.surface, 136, 14)

  -- Plume (counter).
  if self.plume_displayed == 99 then self.plume_text:set_font("green_digits") else self.plume_text:set_font("white_digits") end
  self.plume_text:set_text(self.plume_displayed)
  self.plume_text:draw(self.surface, 170, 14)

  -- Crystal (counter).
  if self.crystal_displayed == 99 then self.crystal_text:set_font("green_digits") else self.crystal_text:set_font("white_digits") end
  self.crystal_text:set_text(self.crystal_displayed)
  self.crystal_text:draw(self.surface, 206, 14)

  -- Ore (counter).
  if self.ore_displayed == 99 then self.ore_text:set_font("green_digits") else self.ore_text:set_font("white_digits") end
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