-- The time counter shown in the game screen.

local clock = {}

function clock:new(game)
  local object = {}
  setmetatable(object, self)
  self.__index = self

  object:initialize(game)

  return object
end

function clock:initialize(game)
  self.game = game
  self.surface = sol.surface.create(32, 32)
  self.clock_img = sol.sprite.create("hud/clock")

  self:check()
  self:rebuild_surface()
end

function clock:check()
  local need_rebuild = false
  if self.game:get_value("hour_of_day") == nil then self.game:set_value("hour_of_day", 12) end
  local hour = tonumber(string.format("%." .. (idp or 0) .. "f", self.game:get_value("hour_of_day")))
  
  -- Current hour.
  if hour ~= self.hour_displayed then
    need_rebuild = true
    self.hour_displayed = hour
    self.clock_img:set_direction(self.hour_displayed)
  end
  
  -- Redraw the surface only if something has changed.
  if need_rebuild then
    self:rebuild_surface()
  end
  
  -- Schedule the next check.
  sol.timer.start(self.game, 100, function()
    self:check()
  end)
end

function clock:rebuild_surface()
  self.surface:clear()

  -- Clock icon.
  self.clock_img:draw(self.surface, 16, 16)
end

function clock:set_dst_position(x, y)
  self.dst_x = x
  self.dst_y = y
end

function clock:on_draw(dst_surface)
  local x, y = self.dst_x, self.dst_y
  local width, height = dst_surface:get_size()
  if x < 0 then
    x = width + x
  end
  if y < 0 then
    y = height + y
  end

  self.surface:draw(dst_surface, x, y)
end

return clock