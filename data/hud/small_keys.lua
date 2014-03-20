-- Allows small keys to be displayed on maps with small keys enabled.
-- Done in ALBW style, a key icon is shown for each key obtained (no counter or icon)

local small_keys = {}
local icon_img = sol.surface.create("hud/small_key.png")

function small_keys:new(game)
  local object = {}
  setmetatable(object, self)
  self.__index = self

  object:initialize(game)
  return object
end

function small_keys:initialize(game)
  local nb_keys_displayed = 0

  self.game = game
  self.visible = false
  self.surface = sol.surface.create(80, 16)

  self:check()
  self:rebuild_surface()
end

function small_keys:check()
  local need_rebuild = false

  -- Check the number of small keys.
  if self.game:are_small_keys_enabled() then
    local nb_keys = self.game:get_num_small_keys()
    if nb_keys_displayed ~= nb_keys then
      need_rebuild = true
    end
  end

  local visible = self.game:are_small_keys_enabled()
  if visible ~= self.visible then
    self.visible = visible
    need_rebuild = true
  end

  -- Redraw the surface is something has changed.
  if need_rebuild then
    self:rebuild_surface()
  end

  -- Schedule the next check.
  sol.timer.start(self.game, 40, function()
    self:check()
  end)
end

function small_keys:rebuild_surface()
  self.surface:clear()
  if self.game:are_small_keys_enabled() then
    for i=0,self.game:get_num_small_keys()-1 do
      icon_img:draw(self.surface,i*14)
      if nb_keys_displayed ~= nil then
        nb_keys_displayed = nb_keys_displayed + 1
      else
        nb_keys_displayed = 1
      end
    end
  end
end

function small_keys:set_dst_position(x, y)
  self.dst_x = x
  self.dst_y = y
end

function small_keys:on_draw(dst_surface)
  if self.visible then
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
end

return small_keys
