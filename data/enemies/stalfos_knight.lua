local enemy = ...
local map = enemy:get_map()

-- Stalfos: An undead soldier boss. PLACEHOLDER!

-- Possible positions where he lands.
local positions = {
  {x = 224, y = 288, direction4 = 3},
  {x = 232, y = 192, direction4 = 3},
  {x = 360, y = 304, direction4 = 3},
  {x = 336, y = 184, direction4 = 3},
  {x = 288, y = 256, direction4 = 3}
}

local vulnerable = false
local hidden = false
local timer = nil

function enemy:on_created()
  self:set_life(10)
  self:set_damage(4)
  self:create_sprite("enemies/stalfos_knight")
  self:set_size(32, 40)
  self:set_origin(16, 36)
  self:set_hurt_style("boss")
  self:set_attack_consequence("arrow", "protected")
  self:set_attack_consequence("hookshot", "protected")
  self:set_attack_consequence("boomerang", "protected")
  self:set_attack_consequence("explosion", "custom")
  self:set_attack_consequence("sword", "protected")
  self:set_pushed_back_when_hurt(false)
  self:set_push_hero_on_sword(false)
end

function enemy:on_restarted()
  local sprite = self:get_sprite()
  local action = math.random(2)

  if not hidden and not vulnerable then
    if action == 1 then
      timer = sol.timer.start(self, math.random(10)*500, function() self:hide() end)
    else
      self:go_hero()
    end
  end
end

function enemy:on_obstacle_reached(movement)
  enemy:restart()
end
function enemy:on_hurt()
  enemy:restart()
end

function enemy:on_update()
  if vulnerable then
    self:get_sprite():set_animation("immobilized")
    self:set_attack_consequence("sword", 1)
  else
    self:get_sprite():set_animation("walking")
    self:set_attack_consequence("sword", "protected")
  end
end

function enemy:hide()
  vulnerable = false
  hidden = true
  self:set_position(-100, -100)
  timer = sol.timer.start(self, math.random(10)*500, function() self:unhide() end)
end

function enemy:unhide()
  hidden = false
  local position = (positions[math.random(#positions)])
  self:set_position(position.x, position.y)
  local sprite = self:get_sprite()
  sprite:set_direction(position.direction4)
end

function enemy:go_hero()
  self:get_sprite():set_animation("walking")
  local m = sol.movement.create("target")
  m:set_speed(24)
  m:start(self)
  sol.timer.start(enemy, math.random(10)*1000, function() enemy:restart() end)
end

function enemy:on_custom_attack_received(attack, sprite)
  if attack == "explosion" then
    vulnerable = true
    self:stop_movement()
    self:get_sprite():set_animation("immobilized")
    self:set_attack_consequence("sword", 1)
    attack_timer = sol.timer.start(self, 3000, function()
      vulnerable = false
      self:set_attack_consequence("sword", "protected")
      self:get_sprite():set_animation("shaking")
    end)
  end

  function sprite:on_animation_finished(animation)
    if animation == "shaking" then
      vulnerable = false
      self:get_sprite():set_animation("walking")
      enemy:restart()
    end
  end
end
