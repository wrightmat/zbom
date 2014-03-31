local enemy = ...

-- Lanmola: segmented enemy who appears from underground- this defines the body segments.

function enemy:on_created()
  self:set_life(1)
  self:set_damage(1)
  self:create_sprite("enemies/lanmola_body")
  self:set_size(16, 16)
  self:set_origin(8, 8)
  self:go(32)
  self:set_invincible(true)
end

function enemy:go(speed)
  -- Keep body segments attached to the head
  if self:get_name() == "lanmola_body_1" then target = "miniboss_lanmola" end
  if self:get_name() == "lanmola_body_2" then target = "lanmola_body_1" end
  if self:get_name() == "lanmola_body_3" then target = "lanmola_body_2" end
  if self:get_name() == "lanmola_body_4" then target = "lanmola_body_3" end
  if self:get_name() == "lanmola_body_5" then target = "lanmola_body_4" end
  if self:get_name() == "lanmola_body_6" then target = "lanmola_body_5" end
  local target_entity = self:get_map():get_entity(target)
  local mb = sol.movement.create("target")
  mb:set_target(target_entity)
  mb:set_ignore_obstacles(true)
  mb:set_speed(speed)
  mb:start(self)
end

function enemy:on_restarted()
  self:go(32)
end

function enemy:on_obstacle_reached()
  self:go(32)
end
