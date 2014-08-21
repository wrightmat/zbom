local enemy = ...

-- Stalfos: An undead soldier boss. PLACEHOLDER!


-- Possible positions where he lands.
-- TODO: correct positions based on room.
local positions = {
  {x = 1312, y = 384 },
  {x = 1256, y = 400 },
  {x = 1184, y = 384 },
  {x = 1208, y = 424 },
  {x = 1240, y = 448 },
  {x = 1320, y = 456 }
}

function enemy:on_created()
  self:set_life(10)
  self:set_damage(4)
  self:create_sprite("enemies/stalfos_knight")
  self:set_hurt_style("boss")
  self:set_pushed_back_when_hurt(false)
  self:set_push_hero_on_sword(false)
  self:set_size(32, 40)
  self:set_origin(16, 36)
end

function enemy:on_movement_changed(movement)
  local direction4 = movement:get_direction4()
  local sprite = self:get_sprite()
  sprite:set_direction(direction4)
end

function enemy:on_obstacle_reached(movement)
  enemy:restart()
end

function enemy:on_restarted()
  --Main action
end
function enemy:on_hurt()
  enemy:restart()
end

function enemy:go_hero()
  firing = false
  self:get_sprite():set_animation("walking")
  local m = sol.movement.create("target")
  m:set_speed(64)
  m:start(self)
  sol.timer.start(enemy, math.random(10)*1000, function() enemy:fly() end)
end
