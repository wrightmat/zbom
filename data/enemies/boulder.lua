local enemy = ...

-- Boulder: Large rock that rolls and can hit the hero.

function enemy:on_created()
  self:set_life(1); self:set_damage(4)
  self:create_sprite("enemies/boulder")
  self:set_size(32, 32); self:set_origin(16, 26)
  self:set_can_hurt_hero_running(true)
  self:set_invincible()
end

function enemy:on_restarted()
  local sprite = self:get_sprite()
  local direction4 = sprite:get_direction()
  local m = sol.movement.create("path")
  m:set_path{direction4 * 2}
  m:set_speed(164)
  m:set_loop(true)
  m:start(self)
end

function enemy:on_obstacle_reached(movement)
  sol.audio.play_sound("stone")
  self:remove()
end