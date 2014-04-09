local enemy = ...

-- Stone Arrghus: Miniboss who creates small rocks and has to be hit in the eye to be hurt
-- NOT DONE YET: TO DO- check in-game and correct any weirdness

function enemy:on_created()
  self:set_life(6)
  self:set_damage(2)
  self:create_sprite("enemies/arrghus_stone")
  self:set_hurt_style("boss")
  self:set_size(80, 80)
  self:set_origin(40, 72)
  self:set_attack_consequence("sword", "protected")
end

function enemy:check_action()
  self:create_enemy({ breed = "arrghus_baby" })
  sol.timer.start(self, 2000, function() self:open() end)
end

function enemy:go(speed)
  self:set_attack_consequence("arrow", 1)
  local m = sol.movement.create("random")
  m:set_speed(speed)
  m:set_max_distance(24)
  m:start(self)
end

function enemy:close()
  self:set_attack_consequence("arrow", "protected")
  self:get_sprite():set_animation("blinking")

  function enemy:on_animation_finished(sprite, animation)
    self:get_sprite():set_animation("closed")
    sol.timer.start(self, random(6)*1000, function() self:open() end)
    self:go(64)
  end
end

function enemy:open()
  self:set_attack_consequence("arrow", 1)
  self:get_sprite():set_animation("opening")

  function enemy:on_animation_finished(sprite, animation)
    self:check_action()
  end
end

function enemy:on_restarted()
  self:check_action()
end
