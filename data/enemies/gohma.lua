local enemy = ...
local map = enemy:get_map()

-- Gohma: Boss who has to be shot in the eye with an arrow to be hurt.

function enemy:on_created()
  self:set_life(9); self:set_damage(2)
  local sprite = self:create_sprite("enemies/gohma")
  self:set_size(64, 32); self:set_origin(32, 29)
  self:set_hurt_style("boss")
  self:set_attack_consequence("sword", "protected")
  sprite:set_animation("walking")
end

function enemy:check_action()
  local action = math.random(10)
  if self:get_life() > 6 then
    -- first phase: if less than three hits then mostly just move around (slowly), and create tektites
    if math.random(3) == 1 and map:get_entities_count(self:get_name().."_son") <= 5 then
     self:create_enemy{
      name = self:get_name().."_son",
      breed = "tektite_green"
     }
    end
    if action >= 1 and action <= 7 then self:go(64) else self:blink() end
  elseif self:get_life() > 3 and self:get_life() <= 6 then
    -- second phase: if more than 3 but less than 6 hits then blink a lot more, and create tektites
    if math.random(2) == 1 and map:get_entities_count(self:get_name().."_son") <= 10 then
     self:create_enemy{
      name = self:get_name().."_son",
      breed = "tektite_green",
      treasure_name = "heart"
     }
    end
    if action >= 1 and action <= 7 then self:blink() else self:go(72) end
  elseif self:get_life() <= 3 then
    -- final phase: if more than 6 hits then move a lot faster, and create tektites!
    if math.random(2) == 1 and map:get_entities_count(self:get_name().."_son") <= 10 then
     self:create_enemy{
      name = self:get_name().."_son",
      breed = "tektite_green",
      treasure_name = "random_woods"
     }
    end
    if action >= 1 and action <= 6 then self:blink() else self:go(104) end
  end
  sol.timer.start(self, 2000, function() self:open() end)
end

function enemy:go(speed)
  self:set_attack_consequence("arrow", 1)
  local m = sol.movement.create("random")
  m:set_speed(speed)
  m:set_max_distance(24)
  m:start(self)
end

function enemy:blink()
  local sprite = self:get_sprite()
  sprite:set_animation("blinking")
  
  function sprite:on_animation_finished(animation)
    enemy:set_attack_consequence("arrow", "protected")
    sprite:set_animation("closed")
    sol.timer.start(enemy, math.random(6)*2000, function() enemy:open() end)
  end
end

function enemy:open()
  local sprite = self:get_sprite()
  sprite:set_animation("opening")

  function sprite:on_animation_finished(animation)
    enemy:set_attack_consequence("arrow", 1)
    sprite:set_animation("walking")
    sol.timer.start(enemy, 3000, function() enemy:check_action() end)
  end
end

function enemy:on_restarted()
  self:get_sprite():set_animation("walking")
  self:check_action()
end

function enemy:on_obstacle_reached()
  self:check_action()
end