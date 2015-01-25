local enemy = ...

-- Stalfos: An undead soldier boss. PLACEHOLDER!

-- Possible positions where he lands.
local positions = {
  {x = 224, y = 288 },
  {x = 232, y = 192 },
  {x = 360, y = 304 },
  {x = 336, y = 184 },
  {x = 288, y = 256 }
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
  self:get_sprite():set_animation("walking")
  local m = sol.movement.create("target")
  m:set_speed(64)
  m:start(self)
  sol.timer.start(enemy, math.random(10)*1000, function() enemy:restart() end)
end
