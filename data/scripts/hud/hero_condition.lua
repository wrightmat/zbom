-- Handles icons on the HUD when conditions are applied to the hero.

local hero_condition = {}

function hero_condition:new(game)
  local object = {}
  setmetatable(object, self)
  self.__index = self

  object:initialize(game)
  return object
end

function hero_condition:initialize(game)
  self.game = game
  self.surface = sol.surface.create(24, 24)
  self.condition_icons_img = sol.surface.create("hud/condition_icon.png")

  self:rebuild_surface()
end

function hero_condition:rebuild_surface()
  self.surface:clear()

  -- Any condition icon that needs display
  if self.game:get_hero():is_condition_active('exhausted') then
    self.condition_icons_img:draw_region(96, 0, 24, 24, self.surface, 0, 0)
  elseif self.game:get_hero():is_condition_active('poison') then
    self.condition_icons_img:draw_region(24, 0, 24, 24, self.surface, 0, 0)
  elseif self.game:get_hero():is_condition_active('cursed') then
    self.condition_icons_img:draw_region(0, 0, 24, 24, self.surface, 0, 0)
  elseif self.game:get_hero():is_condition_active('confusion') then
    self.condition_icons_img:draw_region(48, 0, 24, 24, self.surface, 0, 0)
  end

  -- Redraw periodically
  sol.timer.start(self.game, 200, function()
    self:rebuild_surface()
  end)
end

function hero_condition:set_dst_position(x, y)
  self.dst_x = x
  self.dst_y = y
end

function hero_condition:on_draw(dst_surface)
  local x, y = self.dst_x, self.dst_y
  local width, height = dst_surface:get_size()
  if x < 0 then x = width + x end
  if y < 0 then y = height + y end

  self.surface:draw(dst_surface, x, y)
end

return hero_condition