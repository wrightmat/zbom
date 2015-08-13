local enemy = ...

-- A small seed thrown by another enemy (Floria Baba).

function enemy:on_created()
  self:set_life(1); self:set_damage(2)
  self:create_sprite("enemies/baba_seed")
  self:set_size(16, 16); self:set_origin(8, 8)
  self:set_can_hurt_hero_running(true)
  self:set_invincible()
  self:set_minimum_shield_needed(1)
  self:set_obstacle_behavior("flying")
end

function enemy:on_restarted()
  local dir4 = self:get_sprite():get_direction()
  local m = sol.movement.create("straight")
  if dir4 == 0 then angle = 0 end
  if dir4 == 1 then angle = math.pi / 2 end
  if dir4 == 2 then angle = math.pi end
  if dir4 == 3 then angle = 3 * math.pi / 2 end
  m:set_smooth(false)
  m:set_speed(92)
  m:set_angle(angle)
  m:start(self)
end

function enemy:on_obstacle_reached()
  self:remove()
end