local enemy = ...

-- Vire: Flying enemy which also creates and controls Keese.

function enemy:on_created()
  self:set_life(4); self:set_damage(2)
  local sprite = self:create_sprite("enemies/vire")
  self:set_size(24, 16); self:set_origin(12, 13)
  self:set_hurt_style("monster")
  self:set_pushed_back_when_hurt(true)
  self:set_push_hero_on_sword(false)
  self:set_obstacle_behavior("flying")
  self:set_layer_independent_collisions(true)
  sprite:set_animation("walking")
end

function enemy:on_restarted()
  if sprite == "enemies/vire" then self:get_sprite():set_animation("walking") end
  self:go_circle()
  self:check_hero()
end

function enemy:on_hurt()
  if self:get_map():get_entities_count("keese_fire") < 3 then
    sol.timer.start(self, 2000, function() self:create_enemy({ name = "keese_fire_", layer = 1, breed = "keese_fire", treasure_name = "random" }) end)
  end
end

function enemy:check_hero()
  if sprite == "enemies/vire" then self:get_sprite():set_animation("walking") end
  local hero = self:get_map():get_entity("hero")
  local _, _, layer = self:get_position()
  local _, _, hero_layer = hero:get_position()
  local near_hero = layer == hero_layer and self:get_distance(hero) < 100
  local rand = math.random(3)
  
  if rand == 0 then
    self:go_circle()
  elseif rand == 1 then
    self:go_hero()
  else
    if self:get_map():get_entities_count("keese_fire") < 3 then
      sol.timer.start(self, 2000, function () self:create_enemy({ name = "keese_fire_", layer = 1, breed = "keese_fire", treasure_name = "random" }) end)
    end
  end
  sol.timer.start(self, 5000, function() self:check_hero() end)
end

function enemy:go_hero()
  if sprite == "enemies/vire" then self:get_sprite():set_animation("walking") end
  local angle = self:get_angle(self:get_map():get_entity("hero"))
  local m = sol.movement.create("straight")
  m:set_speed(192)
  m:set_angle(angle)
  m:set_max_distance(320)
  m:start(self)
end

function enemy:go_circle()
  if sprite == "enemies/vire" then self:get_sprite():set_animation("walking") end
  local hero = self:get_map():get_entity("hero")
  local m = sol.movement.create("circle")
  m:set_center(hero, 0, -18)
  m:set_radius(32)
  --m:set_initial_angle(math.pi / 2)
  --m:set_angle_speed(48)
  m:set_angle_from_center(math.pi / 2)
  m:set_angular_speed(0.85)
  m:start(self)
end

function enemy:on_dying()
  -- Split the vire into two keese
  self:create_enemy({ breed = "keese", layer = 1, treasure_name = "heart" })
  self:create_enemy({ breed = "keese", layer = 1, treasure_name = "random" })
end