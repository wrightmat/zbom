local behavior = {}

-- Behavior of an enemy that chases the hero
-- and spawns additional enemies. Can regenerate
-- hero's life when his hits a certain level.

-- Example of use from an enemy script:

-- local enemy = ...
-- local behavior = require("enemies/generic/leader")
-- local properties = {
--   main_sprite = "enemies/green_knight_soldier",
--   life = 4,
--   damage = 2,
--   play_hero_seen_sound = false,
--   normal_speed = 32,
--   faster_speed = 64,
--   hurt_style = "normal"
-- }
-- behavior:create(enemy, properties)

-- The properties parameter is a table.
-- Its values are all optional except main_sprite
-- and sword_sprite.

function behavior:create(enemy, properties)
  local main_sprite = nil
  local towards_hero = false
  local away_hero = false
  local attacked_hero = false
  local towards_enemy = false
  local timer, fire_timer
  
  -- Set default values.
  if properties.life == nil then
    properties.life = 4
  end
  if properties.damage == nil then
    properties.damage = 4
  end
  if properties.play_hero_seen_sound == nil then
    properties.play_hero_seen_sound = false
  end
  if properties.stopped_speed == nil then
    properties.stopped_speed = 0
  end
  if properties.normal_speed == nil then
    properties.normal_speed = 40
  end
  if properties.faster_speed == nil then
    properties.faster_speed = 64
  end
  if properties.hurt_style == nil then
    properties.hurt_style = "normal"
  end
  if properties.regen == nil then
    properties.regen = 0
  end
  
  function enemy:on_created()
    enemy:set_life(properties.life)
    enemy:set_damage(properties.damage)
    enemy:set_hurt_style(properties.hurt_style)
    main_sprite = enemy:create_sprite(properties.main_sprite)
    enemy:set_size(16, 16)
    enemy:set_origin(8, 13)
    
    enemy:set_attack_consequence("sword", 1)
    enemy:restart()
  end
  
  function enemy:on_restarted()
    local get_life = enemy:get_life()
    local ehalflife = .5 * properties.life 
    local hero = enemy:get_map():get_entity("hero")
    local _, _, layer = enemy:get_position()
    local _, _, hero_layer = hero:get_position()
    local spawn_line = layer == hero_layer and enemy:get_distance(hero) > 200
    local sight_line = layer == hero_layer and enemy:get_distance(hero) < 100
    local life_recharge = enemy:get_life() < properties.life
    local life_low = enemy:get_life() < ehalflife and enemy:get_distance(hero) < 64
    if spawn_line and enemy:get_map():get_entities_count("lizalfos") <= 3 then
      enemy:go_spawn()
    elseif not sight_line then
      enemy:go_random()
    elseif sight_line and not towards_hero and not away_hero then
      enemy:go_hero()
    elseif not sight_line and not towards_hero then
      enemy:go_random()
    elseif sight_line and towards_hero then
      if not fire_timer then enemy:fire() end
    elseif life then
      enemy:go_away()
    else
      enemy:go_random()
    end
    if life_recharge then
      enemy:get_game():add_life(properties.regen)
      enemy:go_spawn()
    end
  end
  
  function enemy:on_obstacle_reached(movement)
    if being_pushed then
      enemy:go_hero()
    end
  end
  
  function enemy:on_movement_changed(movement)
    local direction4 = movement:get_direction4()
    main_sprite:set_direction(direction4)
  end
  
  function enemy:go_spawn()
    local x, y, layer = enemy:get_position()
    local direction = enemy:get_sprite():get_direction()
    
    if direction == 0 then
      x = x + 32
    elseif direction == 1 then
      y = y - 32
    elseif direction == 2 then
      x = x - 32
    elseif direction == 3 then
      y = y + 32
    end
    
    local spawn = enemy:create_enemy{
      name = "lizalfos",
      breed = "lizalfos",
      x = x,
      y = y,
      layer = layer,
      direction = direction,
      treasure_name = "random"
    }
    spawn:set_position(x, y, layer)
    spawn:set_optimization_distance(0)
  end
  
  function enemy:go_away()
    local x, y = enemy:get_map():get_entity("hero"):get_position()
    local direction = enemy:get_sprite():get_direction()
    if direction == 0 then
      x = x + 128
    elseif direction == 1 then
      y = y - 128
    elseif direction == 2 then
      x = x - 128
    elseif direction == 3 then
      y = y + 128
    end
    
    local m = sol.movement.create("target")
    m:set_speed(properties.faster_speed)
    m:set_target(x, y)
    m:set_ignore_obstacles(false)
    m:start(enemy)
    away_hero = true 
    towards_hero = false
  end
  
  function enemy:go_random()
    enemy:get_sprite():set_animation("walking")
    local m = sol.movement.create("random_path")
    m:set_speed(properties.normal_speed)
    m:start(enemy)
    towards_hero = false
    away_hero = false
  end
  
  function enemy:go_hero()
    local m = sol.movement.create("target")
    m:set_speed(properties.normal_speed)
    m:start(enemy)
    towards_hero = true
    away_hero = false
  end
  
  function enemy:go_static()
    local m = sol.movement.create("target")
    m:set_speed(0)
    m:start(enemy)
    towards_hero = false
  end
  
  function enemy:fire()
    enemy:get_sprite():set_animation("firing")
    fire_timer = sol.timer.start(self, 100, function()
      local x, y, layer = enemy:get_position()
      local direction = enemy:get_sprite():get_direction()
      
      if direction == 0 then
        x = x + 16
      elseif direction == 1 then
        y = y - 16
      elseif direction == 2 then
        x = x - 16
      elseif direction == 3 then
        y = y + 16
      end
      if rock == nil or not rock:exists() then
        local rock = enemy:create_enemy{
          x = x,
          y = y,
          layer = layer,
          direction = direction,
          breed = "beam_particle"
        }
        self.created = true
        rock:set_position(x, y, layer)
        rock:set_optimization_distance(0)
      end
    end)
    sol.timer.start(self, 1000, function() fire_timer = nil end)
  end

  -- Prevent enemies from "piling up" as much, which makes it easy to kill multiple in one hit.
  function enemy:on_collision_enemy(other_enemy, other_sprite, my_sprite)
    if enemy:is_traversable() then
      enemy:set_traversable(false)
      sol.timer.start(200, function() enemy:set_traversable(true) end)
    end
  end
end

return behavior