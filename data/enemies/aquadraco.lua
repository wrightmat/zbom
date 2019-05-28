local enemy = ...
local firing = false

-- Aquadraco: A flying, water-based miniboss who shoots blue flames.

-- Possible positions where he flys to.
local positions = {
  {x = 1312, y = 384 },
  {x = 1256, y = 400 },
  {x = 1184, y = 384 },
  {x = 1208, y = 424 },
  {x = 1240, y = 448 },
  {x = 1320, y = 456 }
}

function enemy:on_created()
  self:set_life(12); self:set_damage(4)
  self:create_sprite("enemies/aquadraco")
  self:set_size(32, 40); self:set_origin(16, 37)
  self:set_hurt_style("boss")
  self:set_pushed_back_when_hurt(true)
  self:set_push_hero_on_sword(false)
  self:set_obstacle_behavior("flying")
end

function enemy:on_movement_changed(movement)
  local direction4 = movement:get_direction4()
  local sprite = self:get_sprite()
  sprite:set_direction(direction4)
end

function enemy:on_obstacle_reached(movement)
  if not firing then self:fly() end
end

function enemy:on_restarted()
  sol.timer.start(self:get_map(), 2000, function() self:fly() end)
end
function enemy:on_hurt()
  sol.timer.start(self:get_map(), 2000, function() self:fly() end)
end

function enemy:fly()
  firing = false
  self:get_sprite():set_animation("walking")
  local m = sol.movement.create("target")
  local position = (positions[math.random(#positions)])
  m:set_target(position.x, position.y)
  m:set_speed(72)
  m:start(self)

  function m:on_finished()
    local rand = math.random(10)
    if rand < 4 then
      enemy:create_enemy({ breed = "aquadracini", treasure_name = "heart" })
      enemy:fly()
    elseif rand < 8 then
      enemy:spit_fire()
    else
      enemy:go_hero()
    end
  end
end

function enemy:spit_fire()
  firing = true
  local sprite = self:get_sprite()
  sprite:set_animation("firing")
  self:create_enemy({ breed = "flame_blue" })
  sol.timer.start(enemy, 800, function()
    self:get_sprite():set_animation("spreading")
    sol.timer.start(enemy, 800, function() enemy:fly() end)
  end)
end

function enemy:go_hero()
  firing = false
  self:get_sprite():set_animation("walking")
  local m = sol.movement.create("target")
  m:set_speed(64)
  m:start(self)
  sol.timer.start(enemy, math.random(10)*1000, function() enemy:fly() end)
end