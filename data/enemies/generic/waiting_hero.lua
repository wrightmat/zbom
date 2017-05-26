local behavior = {}

-- Behavior of an enemy that is in a sleep state,
-- goes towards the the hero when he sees him,
-- and then goes randomly if it loses sight.
-- The enemy has only two new sprites animation: an asleep one,
-- and an awaking transition.
-- a different walking one can be set in the properties, though.

-- Example of use from an enemy script:

-- local enemy = ...
-- local behavior = require("enemies/generic/waiting_for_hero")
-- local properties = {
--   sprite = "enemies/globul",
--   life = 4,
--   damage = 2,
--   normal_speed = 32,
--   faster_speed = 48,
--   hurt_style = "normal",
--   push_hero_on_sword = false,
--   pushed_when_hurt = true,
--   asleep_animation = "stopped",
--   awaking_animation = "awaking",
--   normal_animation = "walking",
--   ignore_obstacles = false,
--   obstacle_behavior = "flying",
--   awakening_sound  = "stone",
--   waking_distance = 100,
-- }
-- behavior:create(enemy, properties)

-- The properties parameter is a table.
-- All its values are optional except the sprite.

function behavior:create(enemy, properties)
  local going_hero = false
  local awaken = false

  -- Set default values.
  if properties.life == nil then
    properties.life = 2
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
  if properties.asleep_animation == nil then
    properties.asleep_animation = "stopped"
  end
  if properties.normal_animation == nil then
    properties.normal_animation = "walking"
  end  
  if properties.ignore_obstacles == nil then
    properties.ignore_obstacles = false
  end
  if properties.obstacle_behavior == nil then
    properties.obstacle_behavior = "normal"
  end
  if properties.waking_distance == nil then
    properties.waking_distance = 100
  end

  function enemy:on_created()
    self:set_life(properties.life)
    self:set_damage(properties.damage)
    self:set_hurt_style(properties.hurt_style)
    self:set_pushed_back_when_hurt(properties.pushed_when_hurt)
    self:set_push_hero_on_sword(properties.push_hero_on_sword)
    self:set_size(16, 16)
    self:set_origin(8, 13)
    self:set_obstacle_behavior(properties.obstacle_behavior)

    local sprite = self:create_sprite(properties.sprite)
    function sprite:on_animation_finished(animation)
      -- If the awakening transition is finished, make the enemy go toward the hero.
      if animation == properties.awaking_animation then
        finish_waking()
      end
    end
    sprite:set_animation(properties.asleep_animation)
  end

  function enemy:on_movement_changed(movement)
    local direction4 = movement:get_direction4()
    local sprite = self:get_sprite()
    sprite:set_direction(direction4)
  end

  function enemy:on_obstacle_reached(movement)

    if awaken and not going_hero then
      self:check_hero()
    end
  end

  function enemy:on_restarted()
    if not awaken then
      local sprite = self:get_sprite()
      sprite:set_animation(properties.asleep_animation)
    else
      self:go_hero()
    end
    self:check_hero()
  end

  function enemy:check_hero()
    local hero = self:get_map():get_entity("hero")
    local near_hero = self:get_distance(hero) < properties.waking_distance and self:is_in_same_region(hero)

    if awaken then
      if near_hero and not going_hero then
        self:go_hero()
      elseif not near_hero and going_hero then
        self:go_random()
      end
    elseif not awaken and near_hero then
      self:wake_up()
    end

    sol.timer.stop_all(self)
    sol.timer.start(self, 200, function() self:check_hero() end)
  end

  function enemy:finish_waking_up()
    self:get_sprite():set_animation(properties.normal_animation)
    awaken = true
    self:go_hero()
  end

  function enemy:wake_up()
    self:stop_movement()
    if properties.awakening_sound == nil then
      self:finish_waking_up()
    else
      sol.audio.play_sound(properties.awakening_sound)
    end
    if properties.awaking_animation ~= nil then
      local sprite = self:get_sprite()
      sprite:set_animation(properties.awaking_animation)
    end
  end

  function enemy:go_random()
    local m = sol.movement.create("random")
    m:set_speed(properties.normal_speed)
    m:set_ignore_obstacles(properties.ignore_obstacles)
    m:start(self)
    going_hero = false
  end

  function enemy:go_hero()
    local m = sol.movement.create("target")
    m:set_speed(properties.faster_speed)
    m:set_ignore_obstacles(properties.ignore_obstacles)
    m:start(self)
    going_hero = true
  end
end

return behavior