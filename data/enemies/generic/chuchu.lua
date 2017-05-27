local behavior = {}

-- Behavior of an enemy that goes toward the
-- the hero if he sees him, and randomly walks otherwise.
-- The enemy has only one sprite.

function behavior:create(enemy, properties)
  local going_hero = false
  
  -- Set default properties.
  if properties.life == nil then
    properties.life = 1
  end
  if properties.damage == nil then
    properties.damage = 2
  end
  if properties.normal_speed == nil then
    properties.normal_speed = 32
  end
  if properties.faster_speed == nil then
    properties.faster_speed = 48
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
    properties.detection_distance = 160
  end
  if properties.obstacle_behavior == nil then
    properties.obstacle_behavior = "normal"
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
    self:create_sprite(properties.sprite)
    self:set_hurt_style(properties.hurt_style)
    self:set_pushed_back_when_hurt(properties.pushed_when_hurt)
    self:set_push_hero_on_sword(properties.push_hero_on_sword)
    self:set_obstacle_behavior(properties.obstacle_behavior)
    self:set_attack_hookshot("immobilized")
    self:set_size(16, 16)
    self:set_origin(8, 13)
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
  
  function enemy:check_hero()
    local hero = self:get_map():get_entity("hero")
    local _, _, layer = self:get_position()
    local _, _, hero_layer = hero:get_position()
    local near_hero = layer == hero_layer
      and self:get_distance(hero) < properties.detection_distance
      and self:is_in_same_region(hero)

    if near_hero and not going_hero then
      self:go_hero()
    elseif not near_hero and going_hero then
      self:go_random()
    end

    sol.timer.stop_all(self)
    sol.timer.start(self, 100, function() self:check_hero() end)
  end
  
  function enemy:go_random()
    going_hero = false
    local m = properties.movement_create()
    if m == nil then
      -- No movement.
      self:get_sprite():set_animation("stopped")
      m = self:get_movement()
      if m ~= nil then
        -- Stop the previous movement.
        m:stop()
      end
    else
      m:set_speed(properties.normal_speed)
      m:set_ignore_obstacles(properties.ignore_obstacles)
      m:start(self)
    end
  end
  
  function enemy:go_hero()
    going_hero = true
    local m = sol.movement.create("target")
    m:set_speed(properties.faster_speed)
    m:set_ignore_obstacles(properties.ignore_obstacles)
    m:start(self)
    self:get_sprite():set_animation("walking")
  end
  
  function enemy:disappear()
    local sprite = self:get_sprite()
    sprite:set_animation("disappearing")

    function sprite:on_animation_finished(animation)
      enemy:set_enabled(false)
      sol.timer.start(enemy, math.random*5000, function() enemy:reappear() end)
    end
  end
  
  function enemy:reappear()
    local sprite = self:get_sprite()
    sprite:set_animation("reappearing")

    function sprite:on_animation_finished(animation)
      enemy:set_enabled(true)
      enemy:restart()
    end
  end
end

return behavior