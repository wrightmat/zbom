local enemy = ...

-- Stone Arrghus: Miniboss who creates small rocks and has to be hit in the eye to be hurt.

function enemy:on_created()
  self:set_life(8); self:set_damage(4)
  local sprite = self:create_sprite("enemies/arrghus_stone")
  self:set_size(80, 80); self:set_origin(40, 72)
  self:set_hurt_style("boss")
  self:set_attack_consequence("sword", "protected")
  sprite:set_animation("walking")
end

function enemy:check_action()
  if self:get_life() > 3 then
    local x, y, l = self:get_position()
    self:create_enemy({ x = x+10, y = y, breed = "arrghus_baby", treasure_name = "arrow" })
    sol.timer.start(self, 2000, function() self:open() end)
  else
    -- In second phase, create a slew of enemies and then start moving around.
    self:create_enemy({ breed = "arrghus_baby", treasure_name = "arrow" })
    self:create_enemy({ breed = "arrghus_baby", treasure_name = "arrow" })
    self:create_enemy({ breed = "arrghus_baby", treasure_name = "arrow" })
    self:create_enemy({ breed = "arrghus_baby", treasure_name = "arrow" })
    self:create_enemy({ breed = "arrghus_baby", treasure_name = "arrow" })
    self:create_enemy({ breed = "arrghus_baby", treasure_name = "arrow" })
    enemy:go(32)
  end
end

function enemy:go(speed)
  self:set_attack_consequence("arrow", 1)
  local m = sol.movement.create("random")
  m:set_speed(speed)
  m:set_max_distance(24)
  m:start(self)
end

function enemy:close()
  local x, y, l = self:get_position()
  self:set_attack_arrow("protected")
  self:get_sprite():set_animation("closed")
  self:create_enemy({ x = x+10, y = y, breed = "arrghus_baby", treasure_name = "arrow" })
  sol.timer.start(self, random(6)*1000, function() self:open() end)
  self:go(64)
end

function enemy:open()
  local sprite = self:get_sprite()
  self:set_attack_arrow(1)
  sprite:set_animation("opening")

  function sprite:on_animation_finished(animation)
    sprite:set_animation("walking")
    enemy:check_action()
  end
end

function enemy:on_restarted()
  self:get_sprite():set_animation("walking")
  self:check_action()
end