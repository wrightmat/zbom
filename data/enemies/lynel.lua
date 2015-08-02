local enemy = ...

-- Lynel

local shooting = false
local shoot_timer

function enemy:on_created()
  self:set_life(6); self:set_damage(4)
  self:create_sprite("enemies/lynel")
  self:set_hurt_style("monster")
  self:set_size(32, 32); self:set_origin(16, 27)
  self:set_pushed_back_when_hurt(false)
  self:set_attack_consequence("boomerang", "protected")
  self:set_attack_consequence("arrow", "protected")
  self:set_attack_consequence("fire", "protected")
end

function enemy:on_movement_changed(movement)
  local direction4 = movement:get_direction4()
  self:get_sprite():set_direction(direction4)
end

function enemy:on_obstacle_reached(movement)
  self:shoot()
end

function enemy:shoot()
  self:stop_movement()
  local d = self:get_sprite():get_direction()
  self:get_sprite():set_animation("shaking")
  shoot_timer = sol.timer.start(self, 100, function()
    local fire = self:create_enemy({ breed = "projectiles/lynel_fire", direction = d })
    sol.timer.start(self, 2000, function()
      shoot_timer = nil
      self:restart()
    end)
  end)
end

function enemy:on_restarted()
  local m = sol.movement.create("path_finding")
  m:set_speed(32)
  m:start(self)
  if math.random(4) == 1 then self:shoot() end
end