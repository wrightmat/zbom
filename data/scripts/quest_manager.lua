local quest_manager = {}

-- This script handles global behavior of this quest,
-- that is, things not related to a particular savegame.

-- Initialize the behavior of destructible entities.
local function initialize_destructibles()
  local destructible_meta = sol.main.get_metatable("destructible")

  function destructible_meta:on_looked()
    -- Here, self is the destructible object.
    local game = self:get_game()
    game:set_dialog_style("default")
    if self:get_can_be_cut()
        and not self:get_can_explode()
        and not self:get_game():has_ability("sword") then
      -- The destructible can be cut, but the player no cut ability.
      game:start_dialog("_cannot_lift_should_cut");
    elseif not game:has_ability("lift") then
      -- No lift ability at all.
      game:start_dialog("_cannot_lift_too_heavy");
    else
      -- Not enough lift ability.
      game:start_dialog("_cannot_lift_still_too_heavy");
    end
  end

  -- Make certain entities automatic hooks for the hookshot.
  function destructible_meta:is_hookshot_hook()
    if self:get_destruction_sound() ~= nil then
      if self:get_destruction_sound() == "stone" then return true end
    else return false end
  end
end

-- Initialize sensor behavior specific to this quest.
local function initialize_sensors()
  local sensor_meta = sol.main.get_metatable("sensor")

  function sensor_meta:on_activated()
    local game = self:get_game()
    local hero = self:get_map():get_hero()
    local name = self:get_name()
    local dungeon = game:get_dungeon()

    -- Sensors named "to_layer_X_sensor" move the hero on that layer.
    if name:match("^layer_up_sensor") then
      local x, y, layer = hero:get_position()
      if layer < 2 then hero:set_position(x, y, layer + 1) end
    elseif name:match("^layer_down_sensor") then
      local x, y, layer = hero:get_position()
      if layer > 0 then hero:set_position(x, y, layer - 1) end
    end

    -- Sensors prefixed by "dungeon_room_N_" save exploration state of room "N" of current dungeon floor.
    -- Optional treasure savegame value appended to end will play signal chime if value is false and hero has compass in inventory. "dungeon_room_N_bxxx"
    local room = name:match("^dungeon_room_(%d+)")
    local signal = name:match("(%U%d+)$")
    if room ~= nil then
      game:set_explored_dungeon_room(nil, nil, tonumber(room))
      if signal ~= nil and not game:get_value(signal) then
        if game:has_dungeon_compass(game:get_dungeon_index()) then
          sol.audio.play_sound("signal")
          self:set_enabled(false)  -- Disable and re-enabled after 10 seconds to avoid multiple chimes.
          sol.timer.start(game, 10000, function() self:set_enabled(true) end)
        end
      end
    end
  end
end

-- Initialize the behavior of enemies.
local function initialize_enemies()
  local enemy_meta = sol.main.get_metatable("enemy")

  -- Enemies: redefine the damage of the hero's sword. (The default damages are less important.)
  function enemy_meta:on_hurt_by_sword(hero, enemy_sprite)
    -- Here, self is the enemy.
    local game = self:get_game()
    local sword = game:get_ability("sword")
    local damage_factors = { 1, 2, 5 }  -- Damage factor of each sword.
    local damage_factor = damage_factors[sword]
    if hero:get_state() == "sword spin attack" then
      game:remove_stamina(1)
      damage_factor = damage_factor * 2  -- The spin attack is twice as powerful, but costs more stamina.
    end

    local reaction = self:get_attack_consequence_sprite(enemy_sprite, "sword")
    self:remove_life(reaction * damage_factor)
  end

  -- Helper function to inflict an explicit reaction from a scripted weapon.
  function enemy_meta:receive_attack_consequence(attack, reaction)
    if type(reaction) == "number" then
      self:hurt(reaction)
    elseif reaction == "immobilized" then
      self:immobilize()
    elseif reaction == "protected" then
      sol.audio.play_sound("sword_tapping")
    elseif reaction == "custom" then
      if self.on_custom_attack_received ~= nil then
        self:on_custom_attack_received(attack)
      end
    end
  end
end

-- Initialize NPC behavior specific to this quest.
local function initialize_npcs()
  local npc_meta = sol.main.get_metatable("npc")
  local chest_meta = sol.main.get_metatable("chest")

  -- Give default dialog styles to certain entities.
  function npc_meta:on_interaction()
    local game = self:get_game()
    local name = self:get_name()

    if name:match("^sign") then
      game:set_dialog_style("wood")
      game:start_dialog(name)
    elseif name:match("^mailbox") then
      game:set_dialog_style("wood")
      if self:get_name() == "mailbox_link" then
        game:start_dialog("mailbox.link")
      elseif self:get_name() == "mailbox_office" then
        game:start_dialog("mailbox.office")
      elseif self:get_name() == "mailbox_relic_collector" then
        game:start_dialog("mailbox.relic_collector")
      elseif self:get_name() == "mailbox_mr_write" then
        game:start_dialog("mailbox.mr_write")
      else
        game:start_dialog("mailbox")
      end
    elseif name:match("^hint_stone") then
      game:set_dialog_style("stone")
      game:start_dialog(name)
    else
      game:set_dialog_style("default")
    end
  end

  -- Make certain entities automatic hooks for the hookshot.
  function npc_meta:is_hookshot_hook()
    if self:get_sprite() ~= nil then
      if self:get_sprite():get_animation_set() == "entities/sign" then return true end
      if self:get_sprite():get_animation_set() == "entities/mailbox" then return true end
      if self:get_sprite():get_animation_set() == "entities/torch" then return true end
      if self:get_sprite():get_animation_set() == "entities/torch_wood" then return true end
      if self:get_sprite():get_animation_set() == "entities/block" then return true end
    else return false end
  end
  function chest_meta:is_hookshot_hook()
    return true
  end
end

local function initialize_hero()
  -- Modify metatable of hero to make carried entities follow him with hero:on_position_changed().
  local hero_meta = sol.main.get_metatable("hero")
  -- Define a function to change to carrying state. (The same functions are defined for npc_heroes.)
  function hero_meta:set_carrying(boolean)
    if boolean then
      self:set_fixed_animations("carrying_stopped", "carrying_walking")
      self:set_animation("carrying_stopped")
    else
      self:set_fixed_animations(nil, nil)
      if self:is_walking() then self:set_animation("walking")
      else self:set_animation("stopped") end
    end
  end
  -- Make carried entities follow the hero when the position changes.
  function hero_meta:on_position_changed()
    if self.custom_carry then -- There is a carried item.
      local x, y, layer = self:get_position()
      if self.custom_carry.set_position then
        self.custom_carry:set_position(x, y+2, layer)
      end
    end
  end  
  -- Throw the carried entities when hurt.    
  function hero_meta:on_taking_damage(damage)
    self:get_game():remove_life(damage) -- Remove life.
    if self.custom_carry then
      self:start_throw() -- Throw carried entity.
    end
  end  
  -- Throw generic portable entities.
  -- Display the throwing animation of the hero and throw the portable entity.
  function hero_meta:start_throw()
    -- State changes and properties. Get direction to throw.
    local game = self:get_game()
    local animation = self:get_animation()
    local direction = self:get_direction()
    if animation == "carrying_stopped" or animation == "hurt" then direction = nil end
    local portable = self.custom_carry
    if not portable then return end
    self.custom_carry = nil
    -- Change animation of hero to stop carrying.
    self:set_carrying(false)
    local carrier = self
    -- Throw the portable entity.
    local args = {falling_direction = direction, carrier = carrier}
    portable:throw(args)
  end
  -- Function to know if the hero is walking.
  function hero_meta:is_walking()
    local m = self:get_movement()
    return m and m.get_speed and m:get_speed() > 0
  end
  -- Function to set a fixed direction for the hero (or nil to disable it).
  function hero_meta:set_fixed_direction(direction)
    self.fixed_direction = direction
    if direction then self:get_sprite("tunic"):set_direction(direction) end
  end
  -- Function to get a fixed direction for the hero.
  function hero_meta:get_fixed_direction()
    return self.fixed_direction
  end
  -- Function to set fixed stopped/walking animations for the hero (or nil to disable it).
  function hero_meta:set_fixed_animations(stopped_animation, walking_animation)
    self.fixed_stopped_animation = stopped_animation
    self.fixed_walking_animation = walking_animation
    -- Initialize fixed animations if necessary.
    if self:get_state() == "free" then
      if self:is_walking() then self:set_animation(walking_animation or "walking")
      else self:set_animation(stopped_animation or "stopped") end
    end
  end
  -- Function to get fixed stopped/walking animations for the hero.
  function hero_meta:get_fixed_animations()
    return self.fixed_stopped_animation, self.fixed_walking_animation
  end
  -- Functions to enable/disable pushing ability for the hero.
  -- TODO: change this if necessary for a built-in function when it is done.
  local pushing_animation
  function hero_meta:get_pushing_animation() return pushing_animation end
  function hero_meta:set_pushing_animation(animation) pushing_animation = animation end
  -- Initialize events to fix direction and animation for the tunic sprite of the hero.
  -- To do it, we redefine the on_created and set_tunic_sprite_id events using the hero metatable.
  local function initialize_fixing_functions(hero)
    -- Define events for the tunic sprite.
    local sprite = hero:get_sprite("tunic")
    function sprite:on_animation_changed(animation)
      local fixed_stopped_animation = hero.fixed_stopped_animation
      local fixed_walking_animation = hero.fixed_walking_animation
      local tunic_animation = sprite:get_animation()
      if (tunic_animation == "stopped" or tunic_animation == "stopped_with_shield") and fixed_stopped_animation ~= nil then 
        if fixed_stopped_animation ~= tunic_animation then
          sprite:set_animation(fixed_stopped_animation)
        end
      elseif (tunic_animation == "walking" or tunic_animation == "walking_with_shield") and fixed_walking_animation ~= nil then 
        if fixed_walking_animation ~= tunic_animation then
          sprite:set_animation(fixed_walking_animation)
        end
      elseif tunic_animation == "pushing" then
        local pushing_animation = hero:get_pushing_animation()
        if pushing_animation then hero:set_animation(pushing_animation) end
      end
    end
    function sprite:on_direction_changed(animation, direction)
      local fixed_direction = hero.fixed_direction
      local tunic_direction = sprite:get_direction()
      if fixed_direction ~= nil and fixed_direction ~= tunic_direction then
        sprite:set_direction(fixed_direction)
      end
    end
  end
  -- Initialize fixing functions when the hero is created.
  function hero_meta:on_created()
    initialize_fixing_functions(self)
  end
  -- Initialize fixing functions for the new sprite when the sprite is replaced for a new one.
  local old_set_tunic = hero_meta.set_tunic_sprite_id -- Redefine this function.
  function hero_meta:set_tunic_sprite_id(sprite_id)
    old_set_tunic(self, sprite_id)
    initialize_fixing_functions(self)
  end
end


-- Initialize map entity related behaviors.
local function initialize_entities()
  initialize_destructibles()
  initialize_enemies()
  initialize_sensors()
  initialize_npcs()
  initialize_hero()
end

local function initialize_maps()
  local map_metatable = sol.main.get_metatable("map")
  local shadow = sol.surface.create(1120, 1120)
  local lights = sol.surface.create(1120, 1120)
  shadow:set_blend_mode("multiply")
  lights:set_blend_mode("add")
  local heat_timer, swim_timer, draw_counter, magic_counter, opacity
  local camera_x, camera_y, camera_h, camera_w
  screen_overlay = nil
  draw_counter = 0
  magic_counter = 0
  opacity = 255
  local t = {}

  function map_metatable:on_draw(dst_surface)
    local game = self:get_game()
    local hour_of_day = (time_counter / 3000)
    -- Put the night (or sunrise or sunset) overlay on any outdoor map if it's night time.
    if (hour_of_day >= 19.6 or hour_of_day <= 7.6) and
       (game:is_in_outside_world() or (self:get_id() == "20" or self:get_id() == "21" or self:get_id() == "22")) then
      if draw_counter >= 15 then
        if hour_of_day >= 19.6 and hour_of_day < 20 then
          t[1] = 255; t[2] = 255; t[3] = 255
          -- Dusk
          if t[1] >= 2 then
            t[1] = t[1] - 2 -- Red: Goal is 0 (fade to black, which is the same as fading in for this blend mode)
          else time_counter = 20 * 3000 end
          if t[2] >= 3 then
            t[2] = t[2] - 3 -- Green: Goal is 0
          else time_counter = 20 * 3000 end
          if t[3] >= 4 then
            t[3] = t[3] - 4 -- Blue: Goal is 0
          else time_counter = 20 * 3000 end
          shadow:fill_color(t)
        elseif hour_of_day >= 20 and hour_of_day < 21 then
          -- Sunset
          if t[1] >= 32 then
            t[1] = t[1] - 3 -- Red: Goal is 32 (from 255)
          else
            game:set_value("time_of_day", "night")
            time_counter = 21 * 3000
          end
          if t[2] >= 64 then
            t[2] = t[2] - 2 -- Green: Goal is 64 (from 255)
          else
            game:set_value("time_of_day", "night")
            time_counter = 21 * 3000
          end
          if t[3] >= 128 then
            t[3] = t[3] - 1  -- Blue: Goal is 128 (from 255)
          else
            game:set_value("time_of_day", "night")
            time_counter = 21 * 3000
          end
          shadow:fill_color(t)
        elseif hour_of_day >= 6 and hour_of_day <= 7 then
          -- Sunrise
          t[1] = (182*(hour_of_day-6))+18 -- Red: Goal is 182 (from 32)
          t[2] = (62*(hour_of_day-6))+66 -- Green: Goal is 126 (from 64)
          t[3] = (37*(1-(hour_of_day-6)))+87 -- Blue: Goal is 91 (from 128)
          shadow:fill_color(t)
        elseif hour_of_day > 7 and hour_of_day <= 7.6 then
          -- Dawn
          if t[1] <= 253 then
            t[1] = t[1] + 3 -- Red: Goal is 255 (fade to white, which is the same as fading out for this blend mode)
          else
            game:set_value("time_of_day", "day")
            time_counter = 7.7 * 3000
          end
          if t[2] <= 252 then
            t[2] = t[2] + 4 -- Green: Goal is 255
          else
            game:set_value("time_of_day", "day")
            time_counter = 7.7 * 3000
          end
          if t[3] <= 251 then
            t[3] = t[3] + 5 -- Blue: Goal is 255
          else
            game:set_value("time_of_day", "day")
            time_counter = 7.7 * 3000
          end
          shadow:fill_color(t)
        else
          -- Night
          shadow:fill_color({32,64,128,255})
          game:set_value("time_of_day", "night")
        end
        
        lights:clear()
        for e in game:get_map():get_entities("torch_") do
          if e:is_enabled() and e:get_sprite():get_animation() == "lit" and e:get_distance(game:get_hero()) <= 300 then
            local xx,yy = e:get_position()
            local sp = sol.sprite.create("entities/torch_light")
            sp:set_blend_mode("blend")
            sp:draw(lights, xx-32, yy-32)
         end
        end
        for e in game:get_map():get_entities("night_") do
          if e:is_enabled() and e:get_distance(game:get_hero()) <= 300 then
            local xx,yy = e:get_position()
            local sp = sol.sprite.create("entities/torch_light")
            sp:set_blend_mode("blend")
            sp:draw(lights, xx-24, yy-24)
          end
        end
        for e in game:get_map():get_entities("lava_") do
          if e:is_enabled() and e:get_distance(game:get_hero()) <= 300 then
            local xx,yy = e:get_position()
            local sp = sol.sprite.create("entities/torch_light_tile")
            sp:set_blend_mode("blend")
            sp:draw(lights, xx-8, yy-8)
          end
        end
        for e in game:get_map():get_entities("warp_") do
          if e:is_enabled() and e:get_distance(game:get_hero()) <= 300 then
            local xx,yy = e:get_position()
            local sp = sol.sprite.create("entities/torch_light_tile")
            sp:set_blend_mode("blend")
            sp:draw(lights, xx-16, yy-20)
          end
        end
        for e in game:get_map():get_entities("poe") do
          if e:is_enabled() and e:get_distance(game:get_hero()) <= 300 then
            local xx,yy = e:get_position()
            local sp = sol.sprite.create("entities/torch_light")
            sp:set_blend_mode("blend")
            sp:draw(lights, xx-32, yy-32)
          end
        end
        if game:has_item("lamp") and game:get_magic() > 0 and game:get_time_of_day() == "night" then
          local xx, yy = game:get_map():get_entity("hero"):get_position()
          local sp = sol.sprite.create("entities/torch_light_hero")
          sp:set_blend_mode("blend")
          sp:draw(lights, xx-64, yy-68)
        end
        draw_counter = 0
      end
      lights:draw_region(camera_x,camera_y,camera_w,camera_h,shadow,camera_x,camera_y)
      shadow:draw_region(camera_x,camera_y,camera_w,camera_h,dst_surface)
    end
    if screen_overlay ~= nil then screen_overlay:draw(dst_surface) end

    -- As of Solarus 1.5, the function map:move_camera is deprecated, so we use a custom version instead.
    function map_metatable:move_camera(x, y, speed, callback, delay_before, delay_after)
      local camera = self:get_camera()
      local game = self:get_game()
      local hero = self:get_hero()
      
      delay_before = delay_before or 1000
      delay_after = delay_after or 1000
      
      local back_x, back_y = camera:get_position_to_track(hero)
      game:set_suspended(true)
      camera:start_manual()

      local movement = sol.movement.create("target")
      movement:set_target(camera:get_position_to_track(x, y))
      movement:set_ignore_obstacles(true)
      movement:set_speed(speed)
      movement:start(camera, function()
        local timer_1 = sol.timer.start(self, delay_before, function()
          if callback ~= nil then
            callback()
          end
          local timer_2 = sol.timer.start(self, delay_after, function()
            local movement = sol.movement.create("target")
            movement:set_target(back_x, back_y)
            movement:set_ignore_obstacles(true)
            movement:set_speed(speed)
            movement:start(camera, function()
              game:set_suspended(false)
              camera:start_tracking(hero)
              if self.on_camera_back ~= nil then
                self:on_camera_back()
              end
            end)
          end)
          timer_2:set_suspended_with_map(false)
        end)
        timer_1:set_suspended_with_map(false)
      end)
    end
  end
  
  function map_metatable:on_started(destination)
    local game = self:get_game()
    
    function random_8(lower, upper)
      math.randomseed(os.time() - os.clock() * 1000)
      return math.random(math.ceil(lower/8), math.floor(upper/8))*8
    end
    
    -- Night time is more dangerous - add various enemies.
    if game:get_map():get_world() == "outside_world" and game:get_time_of_day() == "night" then
      local keese_random = math.random()
      if keese_random < 0.7 then
        local ex = random_8(1,1120)
        local ey = random_8(1,1120)
        self:create_enemy({ breed="keese", x=ex, y=ey, layer=2, direction=1 })
        sol.timer.start(self, 1100, function()
          local ex = random_8(1,1120)
          local ey = random_8(1,1120)
          self:create_enemy({ breed="keese", x=ex, y=ey, layer=2, direction=1 })
        end)
      elseif keese_random >= 0.7 then
        local ex = random_8(1,1120)
        local ey = random_8(1,1120)
        self:create_enemy({ breed="keese", x=ex, y=ey, layer=2, direction=1 })
        sol.timer.start(self, 1100, function()
          local ex = random_8(1,1120)
          local ey = random_8(1,1120)
          self:create_enemy({ breed="keese", x=ex, y=ey, layer=2, direction=1 })
        end)
        sol.timer.start(self, 1100, function()
          local ex = random_8(1,1120)
          local ey = random_8(1,1120)
          self:create_enemy({ breed="keese", x=ex, y=ey, layer=2, direction=1 })
        end)
      end
      local poe_random = math.random()
      if poe_random <= 0.5 then
        local ex = random_8(1,1120)
        local ey = random_8(1,1120)
        self:create_enemy({ name = "poe", breed="poe", x=ex, y=ey, layer=2, direction=1 })
      elseif keese_random <= 0.2 then
        local ex = random_8(1,1120)
        local ey = random_8(1,1120)
        self:create_enemy({ name = "poe", breed="poe", x=ex, y=ey, layer=2, direction=1 })
        sol.timer.start(self, 1100, function()
          local ex = random_8(1,1120)
          local ey = random_8(1,1120)
          self:create_enemy({ name = "poe", breed="poe", x=ex, y=ey, layer=2, direction=1 })
        end)
      end
      local redead_random = math.random()
      if poe_random <= 0.1 then
        local ex = random_8(1,1120)
        local ey = random_8(1,1120)
        self:create_enemy({ breed="redead", x=ex, y=ey, layer=0, direction=1 })
      end
    end
  end
  
  function map_metatable:on_finished()
    self:get_game().save_between_maps:save_map(self)
  end
  
  function map_metatable:on_update()
    local game = self:get_game()
    camera_x,camera_y = game:get_map():get_camera():get_position()
    camera_w,camera_h = game:get_map():get_camera():get_size()    
    
    -- Slowly drain magic when using lantern.
    if magic_counter >= 1000 and game:get_time_of_day() == "night" and game:is_in_outside_world() then
      game:remove_magic(1)
      magic_counter = 0
    end
    if not game:is_suspended() then magic_counter = magic_counter + 1 end
    draw_counter = draw_counter + 1
    
    -- If hero doesn't have red tunic on, slowly remove stamina in hot areas (Subrosia).
    if game:get_map():get_world() == "outside_subrosia" and
    game:get_value("tunic_equipped") ~= 2 then
      if not heat_timer then
        heat_timer = sol.timer.start(game:get_map(), 5000, function()
          game:remove_stamina(5)
          return true
        end)
      end
    else
      if heat_timer then
        heat_timer:stop()
        heat_timer = nil
      end
    end
    
    -- If hero doesn't have blue tunic on, slowly remove stamina while swimming.
    if game:get_hero():get_state() == "swimming" and
    game:get_value("tunic_equipped") ~= 3 then
      if not swim_timer then
        swim_timer = sol.timer.start(game:get_map(), 5000, function()
          game:remove_stamina(5)
          return true
        end)
      end
    else
      if swim_timer then
        swim_timer:stop()
        swim_timer = nil
      end
    end
    
    -- Update the time of day.
    -- One minute (60 seconds) is two hours in-game. Update every 0.1 minute.
    if game:get_value("hour_of_day") == nil then game:set_value("hour_of_day", 12) end
    if time_counter == nil then time_counter = game:get_value("hour_of_day") * 3000 end
    local hour_of_day = game:get_value("hour_of_day")
    if hour_of_day == nil then hour_of_day = 0 end
    hour_of_day = (time_counter / 3000)
    
    if hour_of_day >= 23 then
      hour_of_day = 0
      time_counter = 0
    end
    if hour_of_day > 21 then
      game:set_time_of_day("night")
      for entity in game:get_map():get_entities("night_") do
        entity:set_enabled(true)
      end
    elseif hour_of_day > 7 and hour_of_day < 21 then
      game:set_time_of_day("day")
      for entity in game:get_map():get_entities("night_") do
        entity:set_enabled(false)
      end
    end
    game:set_value("hour_of_day", hour_of_day)
    if not game:is_suspended() then time_counter = time_counter + 1 end
  end
end

local function initialize_game()
  local game_metatable = sol.main.get_metatable("game")

  -- Stamina functions mirror magic and life functions.
  function game_metatable:get_stamina()
    return self:get_value("i1024")
  end

  function game_metatable:set_stamina(value)
    if value > self:get_max_stamina() then value = self:get_max_stamina() end
    return self:set_value("i1024", value)
  end

  function game_metatable:add_stamina(value)
    stamina = self:get_value("i1024") + value
    if value >= 0 then
      if stamina > self:get_max_stamina() then stamina = self:get_max_stamina() end
      return self:set_value("i1024", stamina)
    end
  end

  function game_metatable:remove_stamina(value)
    stamina = self:get_value("i1024") - value
    if stamina < 0 then stamina = 0 end
    if value >= 0 then
      return self:set_value("i1024", stamina)
    end
  end

  function game_metatable:get_max_stamina()
    return self:get_value("i1025")
  end

  function game_metatable:set_max_stamina(value)
    if value >= 20 then -- Stamina can't be too low or hero can't do anything!
      return self:set_value("i1025", value)
    end
  end

  function game_metatable:add_max_stamina(value)
    stamina = self:get_value("i1025")
    if value > 0 then
      return self:set_value("i1025", stamina+value)
    end
  end

  function game_metatable:get_random_map_position()
    function random_8(lower, upper)
      math.randomseed(os.time())
      return math.random(math.ceil(lower/8), math.floor(upper/8))*8
    end
    function random_points()
      local x = random_8(1, 1120)
      local y = random_8(1, 1120)
      if self:get_map():get_ground(x,y,1) ~= "traversable" then
         random_points()
      else
        return x,y
      end
    end
  end
end

-- Performs global initializations specific to this quest.
function quest_manager:initialize_quest()
  initialize_game()
  initialize_maps()
  initialize_entities()
end

return quest_manager