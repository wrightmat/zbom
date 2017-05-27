local behavior = {}

-- Behavior of an enemy that goes toward the
-- the hero if he sees him, and randomly walks otherwise.
-- The enemy has only one sprite.

function behavior:create(enemy, properties)
  local state = "stopped"
  local going_hero = false
  local main_sprite = nil
  
  -- Set default properties.
  if properties.life == nil then
    properties.life = 1
  end
  if properties.damage == nil then
    properties.damage = 2
  end
  if properties.normal_speed == nil then
    properties.normal_speed = 56
  end
  if properties.faster_speed == nil then
    properties.faster_speed = 64
  end
  if properties.hurt_style == nil then
    properties.hurt_style = "normal"
  end
  if properties.pushed_when_hurt == nil then
    properties.pushed_when_hurt = true
  end
  if properties.push_hero_on_sword == nil then
    properties.push_hero_on_sword = false
  end
  if properties.ignore_obstacles == nil then
    properties.ignore_obstacles = false
  end
  if properties.detection_distance == nil then
    properties.detection_distance = 96
  end
  if properties.stop_distance == nil then
    properties.stop_distance = 144
  end
  if properties.obstacle_behavior == nil then
    properties.obstacle_behavior = "flying"
  end
  if properties.movement_create == nil then
    properties.movement_create = function()
      local m = sol.movement.create("random_path")
      return m
    end
  end
  
  function enemy:on_created()
    self:set_life(properties.life)
    self:set_damage(properties.damage)
    main_sprite = self:create_sprite(properties.sprite)
    self:set_hurt_style(properties.hurt_style)
    self:set_pushed_back_when_hurt(properties.pushed_when_hurt)
    self:set_push_hero_on_sword(properties.push_hero_on_sword)
    self:set_obstacle_behavior(properties.obstacle_behavior)
    self:set_layer_independent_collisions(true)
    self:set_size(16, 16)
    self:set_origin(8, 13)
    main_sprite:set_animation("stopped")
  end
  
  function enemy:on_update()
    local sprite = self:get_sprite()
    local hero = self:get_map():get_entity("hero")
    -- Check whether the hero is close.
    if self:get_distance(hero) <= properties.detection_distance and state ~= "going" then
      if sprite == "enemies/keese" then sprite:set_animation("walking") end
      local m = sol.movement.create("target")
      m:set_speed(properties.faster_speed)
      m:start(self); state = "going"
    elseif self:get_distance(hero) > properties.detection_distance and state ~= "random" then
      if sprite == "enemies/keese" then sprite:set_animation("walking") end
      local m = sol.movement.create("random")
      m:set_speed(properties.normal_speed)
      m:start(self); state = "random"
    elseif self:get_distance(hero) > properties.stop_distance then
      if sprite == "enemies/keese" then sprite:set_animation("stopped") end
      state = "stopped"; self:stop_movement()
    end
  end
end

return behavior