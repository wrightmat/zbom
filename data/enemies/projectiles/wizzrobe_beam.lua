local enemy = ...
local type

-- A magic beam thrown by another enemy (Wizzrobe).

function enemy:on_created()
  self:set_life(1); self:set_damage(6)
  self:create_sprite("enemies/wizzrobe_beam")
  self:set_size(16, 16); self:set_origin(8, 8)
  self:set_invincible()
  self:set_minimum_shield_needed(2)
  self:set_can_hurt_hero_running(true)
  self:set_obstacle_behavior("flying")
  type = self.type
end

function enemy:on_obstacle_reached()
  self:remove()
end

function enemy:on_restarted()
  if type == "fire" then
    self:get_sprite():set_animation("fire")
  elseif type == "ice" then
    self:get_sprite():set_animation("ice")
  else
    self:get_sprite():set_animation("magic")
  end
  local dir4 = self:get_sprite():get_direction()
  local m = sol.movement.create("straight")
  if dir4 == 0 then angle = 0 end
  if dir4 == 1 then angle = math.pi / 2 end
  if dir4 == 2 then angle = math.pi end
  if dir4 == 3 then angle = 3 * math.pi / 2 end
  m:set_speed(92)
  m:set_angle(angle)
  m:start(self)
end