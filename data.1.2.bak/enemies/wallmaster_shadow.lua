local enemy = ...

-- Wallmaster shadow

function enemy:on_created()
  self:create_sprite("enemies/wallmaster")
  self:get_sprite():set_animation("shadow")
  self:set_size(32, 32)
  self:set_origin(16, 13)
  self:set_invincible(true)
end

function enemy:on_restarted()
  self:get_sprite():set_animation("shadow")

  -- shadow continually follows hero
  local hero = self:get_map():get_entity("hero")
  local m = sol.movement.create("target")
  m:set_speed(64)
  m:set_target(hero)
  m:set_ignore_obstacles(true)
  m:start(self)
end
