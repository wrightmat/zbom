local enemy = ...

-- Tektite: a swimming enemy which moves toward the hero

function enemy:on_created()
  self:set_life(1)
  self:set_damage(2)
  self:create_sprite("enemies/tektite_water")
  self:set_hurt_style("monster")
  self:set_size(16, 16)
  self:set_origin(8, 13)
  self:set_pushed_back_when_hurt(true)
  self:set_push_hero_on_sword(false)
  self:set_obstacle_behavior("swimming")
end

function enemy:on_movement_changed(movement)
  local direction4 = movement:get_direction4()
  local sprite = self:get_sprite()
  sprite:set_direction(direction4)
end

function enemy:on_obstacle_reached(movement)
  if not going_hero then
    self:go_random()
    self:check_hero()
  end
end

function enemy:on_restarted()
  self:go_random()
  self:check_hero()
end

function enemy:on_hurt()
  if timer ~= nil then
    timer:stop()
    timer = nil
  end
end

function enemy:check_hero()
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

function enemy:go_random()
  going_hero = false
  sol.timer.start(self, 2000, function() self:check_hero() end)
end

function enemy:go_hero()
  local hero = self:get_map():get_entity("hero")
  local m = sol.movement.create("target")
  m:set_target(hero)
  m:set_speed(32)
  self:get_sprite():set_frame(0) --crouched
  sol.timer.start(self, 500, function() m:start(self) end)
  going_hero = true
end