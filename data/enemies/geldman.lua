local enemy = ...

-- Geldman: a basic desert enemy.

function enemy:go_random()
  enemy:get_sprite():set_animation("walking")
  local m = sol.movement.create("random")
  m:set_speed(32)
  m:start(self)
  going_hero = false
end

function enemy:go_hero()
  enemy:get_sprite():set_animation("walking")
  local hero = self:get_map():get_entity("hero")
  local m = sol.movement.create("target")
  m:set_target(hero)
  m:set_speed(32)
  m:start(self)
  going_hero = true
end

function enemy:go_emerge()
  enemy:get_sprite():set_animation("emerging")
  enemy:set_enabled(true)
  sol.timer.start(self, 1000, function() self:check_hero() end)
end

function enemy:go_sink()
  enemy:get_sprite():set_animation("sinking")
  sol.timer.start(self, 1000, function() enemy:set_enabled(false) end)
  sol.timer.start(self:get_map(), math.random(6)*2000, function()
    self:go_emerge()
  end)
end

function enemy:check_hero()
  enemy:get_sprite():set_animation("walking")
  local hero = self:get_map():get_entity("hero")
  local _, _, layer = self:get_position()
  local _, _, hero_layer = hero:get_position()
  local near_hero = layer == hero_layer
    and self:get_distance(hero) < 100

  if near_hero and not going_hero then
    self:go_hero()
  elseif not near_hero and going_hero then
    self:go_random()
  elseif not near_hero and not going_hero then
    self:go_sink()
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
  self:go_sink()
end

function enemy:on_restarted()
  self:check_hero()
end
