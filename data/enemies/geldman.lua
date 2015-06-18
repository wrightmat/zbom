local enemy = ...

-- Geldman: a basic desert enemy.

function enemy:go_random()
  enemy:get_sprite():set_animation("walking")
  local m = sol.movement.create("random")
  m:set_speed(40)
  m:start(self)
  going_hero = false
  self:set_attack_consequence("fire", "protected")
end

function enemy:go_hero()
  enemy:get_sprite():set_animation("walking")
  local hero = self:get_map():get_entity("hero")
  local m = sol.movement.create("target")
  m:set_target(hero)
  m:set_speed(48)
  m:start(self)
  going_hero = true
end

function enemy:check_hero()
  enemy:get_sprite():set_animation("walking")
  local hero = self:get_map():get_entity("hero")
  local _, _, layer = self:get_position()
  local _, _, hero_layer = hero:get_position()
  local near_hero = layer == hero_layer
    and self:get_distance(hero) < 200

  if near_hero and not going_hero then
    self:go_hero()
  elseif not near_hero and going_hero then
    self:go_random()
  end
  timer = sol.timer.start(self, 2000, function() self:check_hero() end)
end

function enemy:on_created()
  self:set_life(3)
  self:set_damage(2)
  self:create_sprite("enemies/geldman")
  self:set_size(40, 16)
  self:set_origin(20, 13)
end

function enemy:on_obstacle_reached(movement)
  self:check_hero()
end

function enemy:on_restarted()
  self:check_hero()
end
