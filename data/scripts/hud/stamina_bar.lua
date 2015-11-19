-- The stamina bar shown on the game screen.

local stamina_bar = {}

function stamina_bar:new(game)
  local object = {}
  setmetatable(object, self)
  self.__index = self

  object:initialize(game)

  return object
end

function stamina_bar:initialize(game)
  self.game = game
  self.surface = sol.surface.create(88, 8)
  self.stamina_bar_img = sol.surface.create("hud/magic_bar.png")
  self.container_img = sol.surface.create("hud/magic_bar.png")
  self.stamina_displayed = game:get_stamina()
  self.max_stamina_displayed = 0

  self:check()
  self:rebuild_surface()
end

-- Checks whether the view displays the correct info
-- and updates it if necessary.
function stamina_bar:check()
  local need_rebuild = false
  local max_stamina = self.game:get_max_stamina()
  local stamina = self.game:get_stamina()

  -- Maximum stamina.
  if max_stamina ~= self.max_stamina_displayed then
    need_rebuild = true
    if self.stamina_displayed > max_stamina then
      self.stamina_displayed = max_stamina
    end
    self.max_stamina_displayed = max_stamina
  end

  -- Current stamina.
  if stamina ~= self.stamina_displayed then
    need_rebuild = true
    local increment
    if stamina < self.stamina_displayed then
      increment = -1
    elseif stamina > self.stamina_displayed then
      increment = 1
    end
    if increment ~= 0 then
      self.stamina_displayed = self.stamina_displayed + increment

      if (stamina - self.stamina_displayed) % 10 == 1 then
	--sol.audio.play_sound("magic_bar")
      end
    end
  end

  -- Redraw the surface only if something has changed.
  if need_rebuild then
    self:rebuild_surface()
  end

  -- Schedule the next check.
  sol.timer.start(self.game, 20, function()
    self:check()
  end)
end

function stamina_bar:rebuild_surface()
  self.surface:clear()

  -- Max stamina.
  self.container_img:draw_region(46, 8, 2 + self.max_stamina_displayed/12, 8, self.surface)
  self.container_img:draw_region(132, 8, 2, 8, self.surface, self.max_stamina_displayed/12 + 2, 0)

  -- Current stamina (divided so it takes up less space).
  self.stamina_bar_img:draw_region(46, 32, 2 + self.stamina_displayed/12, 8, self.surface)
end

function stamina_bar:set_dst_position(x, y)
  self.dst_x = x
  self.dst_y = y
end

function stamina_bar:on_draw(dst_surface)
  if self.max_stamina_displayed > 0 then
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

return stamina_bar