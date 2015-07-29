local enemy = ...

-- Beamos

local timers = {}
local beam_going = false

function enemy:on_created()
  self:set_life(1)
  self:set_damage(1)
  self:create_sprite("enemies/beamos")
  self:set_size(16, 32)
  self:set_origin(8, 27)
  self:set_invincible(true)
  self:set_attack_consequence("explosion", 1)
end

function enemy:on_movement_changed(movement)
  local direction8 = self:get_direction8_to(self:get_map():get_hero())
  self:get_sprite():set_direction(direction8)
end

function enemy:on_restarted()
  for _, t in ipairs(timers) do t:stop() end
  if ex == nil or ey == nil then ex, ey, el = self:get_position() end
  timers[#timers + 1] = sol.timer.start(self, 700, function() self:start_beam() end)
end

function enemy:start_beam()

end

function enemy:on_update()
  if self:get_distance(self:get_map():get_hero()) < 60 and not beam_going then
    self:start_beam()
  end
end