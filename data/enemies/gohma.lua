local enemy = ...

-- Gohma: Boss who has to be shot in the eye with an arrow to be hurt

function enemy:on_created()
  self:set_life(9)
  self:set_damage(2)
  self:create_sprite("enemies/gohma")
  self:set_hurt_style("boss")
  self:set_size(64, 32)
  self:set_origin(32, 29)
  self:set_attack_consequence("sword", "protected")
  self:get_sprite():set_animation("walking")
  self:set_optimization_distance(0)
end

function enemy:check_action()
  local action = math.random(10)
  if self:get_life() > 6 then
    -- first phase: if less than three hits then mostly just move around (slowly), and create tektites
    local son_name = self:get_name().."_son"
    self:create_enemy{
      name = son_name,
      breed = "tektite_green",
      treasure_name = "heart"
    }
    if action >= 1 and action <= 7 then self:go(96) else self:blink() end
  elseif self:get_life() > 3 and self:get_life() <= 6 then
    -- second phase: if more than 3 but less than 6 hits then blink a lot more, and create tektites
    if action >= 1 and action <= 7 then self:blink() else self:go(96) end
    local son_name = self:get_name().."_son"
    self:create_enemy{
      name = son_name,
      breed = "tektite_green"
    }
  elseif self:get_life() < 3 and self:get_life() > 0 then
    -- final phase: if more than 6 hits then move a lot faster, and create tektites!
    if action >= 1 and action <= 6 then self:blink() else self:go(128) end
    local son_name = self:get_name().."_son"
    self:create_enemy{
      name = son_name,
      breed = "tektite_green"
    }
  end
  sol.timer.start(self, 100, function() self:open() end)
end

function enemy:go(speed)
  self:get_sprite():set_animation("walking")
  self:set_attack_consequence("arrow", 1)
  local m = sol.movement.create("random")
  m:set_speed(speed)
  m:set_max_distance(24)
  m:start(self)
end

function enemy:blink()
  self:set_attack_consequence("arrow", "protected")
  local sprite = self:get_sprite()
  sprite:set_animation("blinking")
  
  function sprite:on_animation_finished(animation)
    enemy:set_attack_consequence("arrow", "protected")
    sprite:set_animation("closed")
    sol.timer.start(enemy, random(6)*1000, function() enemy:open() end)
    enemy:go(64)
  end
end

function enemy:open()
  self:set_attack_consequence("arrow", 1)
  local sprite = self:get_sprite()
  sprite:set_animation("opening")
  function sprite:on_animation_finished(animation)
    enemy:set_attack_consequence("arrow", "protected")
    sprite:set_animation("walking")
    sol.timer.start(enemy, 1000, function() enemy:check_action() end)
  end
end

function enemy:on_restarted()
  self:get_sprite():set_animation("walking")
  self:check_action()
end

function enemy:on_obstacle_reached()
  self:check_action()
end
