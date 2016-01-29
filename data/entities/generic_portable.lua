--[[ Base script used to define entities that can be lifted but not destroyed when thrown. When the custom entity can be lifted, we save a reference to it in hero.custom_lift.
To start lifting a custom entity, call the method "lift()" of the entity to lift, in case it is defined. Similar with hero.custom_carry, entity:set_carried(hero_entity), etc.
To call this script from another,  use: "sol.main.load_file("entities/generic_portable")(entity)" and define a method entity:on_custom_created()  for the initialization, if necessary. 
The state, "on_ground", "lifting", "carried", "falling", can be recovered with entity.state.

To create a portable entity which is unique, use another entity script, and write:
  local entity = ...
  sol.main.load_file("entities/generic_portable")(entity)
  entity.unique_id = "first_key"
  
Warning: Use the CUSTOM event entity:on_custom_created() instead of entity:on_created() to customize each portable entity.
For instance, to change the bouncing sound, use the event to change the default value of the variable "entity.sound".
Other CUSTOM events that can be used in other scripts are:
entity:on_custom_position_changed() and entity:on_custom_interaction()
*Don't use the non custom events of the engine to avoid overriding functions of this script!!!!

*Define a string value for "entity.unique_id" if there is only one instance at most of this entity in the game. This is used to avoid to clone the
entity if it is carried to another map and then back to the previous map.
*Set "entity.is_independent = true" if the entity saves its position (and maybe more information) in the map when it is left and the hero
goes back to its map. This requires defining the string value "entity.unique_id".

REQUIRED SCRIPTS:
*In order to make use of "entity.unique_id" and "entity.is_independent", it is needed to have the script save_between_maps,
which in turn requires some modifications in the game_manager script.
*To lift the entities, it is required the script custom_interactions (and some modifications of the game manager script),
which in turn requires the script collision_test_manager to make it work.
*Another animation set is used when the hero is carrying a generic_portable entity (create it with the sprite editor!!!).
*If an independent entity is thrown, teletransporters are disabled during a second, to allow saving the position of the entity on solid
ground after falling (cannot save state on the air).
--]]

local entity = ...

entity.is_portable = true -- Use this to identify portable entities in other scripts.
entity.unique_id = nil -- String value or nil. Define it if there is at most one instance of this entity in the game (if so, create them dynamically!!!).
entity.is_independent = nil -- If true, saves position on the map (when the hero leaves the map). Requires "entity.unique_id" string.
entity.can_push_buttons = nil
entity.moved_on_platform = true
entity.state = "on_ground"
entity.sound = "throw" -- Default id of the bouncing sound.
entity.action_effect = "custom_lift" -- Used to interact (see custom_interactions script).

local game = entity:get_game()
local map = entity:get_map()

-- Variables to recover initial information after thrown.
local temp_starting_animation
local temp_moved_on_platform
local temp_can_push_buttons

function entity:on_created()
  -- Properties.
  entity:set_drawn_in_y_order(true)
  if entity.on_custom_created then entity:on_custom_created() end -- Define this in other scripts!!!
  self:set_can_traverse_ground("hole", true)
  self:set_can_traverse_ground("deep_water", true)
  self:set_can_traverse_ground("lava", true)
  self:set_can_traverse("jumper", true)
  -- Interaction properties for the HUD.
  game:set_interaction_enabled(entity, true)
  -- Starts checking the ground, once per second (the ground can change).
  entity:start_checking_ground()
end

-- On interaction, lift the entity.
function entity:on_custom_interaction()
  game:set_interaction_enabled(entity, false)
  game:set_custom_command_effect("action", nil) -- Change the custom action effects.
  game:set_custom_command_effect("attack", "custom_carry")
  self:lift()
end 
 
-- Start lifting the object.
function entity:lift()
  local hero = map:get_hero()
  self.state = "lifting"; hero:freeze(); hero:set_invincible(true)
  entity:on_position_changed() -- Notify the entity (to move secondary sprites, etc).
  -- Associate the entity to the hero.
  hero.custom_carry  = entity; hero.custom_lift = nil
  -- Show the hero lifting animation.
  sol.audio.play_sound("lift")
  hero:set_animation("lifting", function() 
	  hero:set_animation("stopped")
	  hero:unfreeze(); hero:set_invincible(false)
	  self:set_carried(hero)
  end)
  -- Move the entity while lifting. (If direction is "up", the item must be drawn behind the hero, so the position is different.)
  local i = 0; local hx, hy, hz = hero:get_position(); local dir = hero:get_direction()
  local dx, dy = math.cos(dir*math.pi/2), -math.sin(dir*math.pi/2)
  if dir ~= 1 then self:set_position(hx, hy +2, hz) else self:set_position(hx, hy, hz) end
  local sprite = self:get_sprite(); sprite:set_xy(dx*14, -6); entity:set_direction(dir)
  entity:on_position_changed() -- Notify the entity (to move secondary sprites, etc).
  sol.timer.start(entity, math.floor(100), function()
    i = i+1
    if i == 1 then 
      sprite:set_xy(dx*16, -8)
    elseif i == 2 then 
      sprite:set_xy(dx*16, -16)
    else 
      sprite:set_xy(0, -20)
      if dir == 1 then self:set_position(hx, hy +2, hz) end 
    end
    entity:on_position_changed() -- Notify the entity (to move secondary sprites, etc).
    return i < 3
  end)
end

-- The hero is displayed carrying this entity (modify this later to allow enemies to carry custom entities!!!). 
function entity:set_carried(hero_entity)
  -- Change animation set of the entity carrying (usually the hero).
  hero_entity.custom_carry = entity
  self.state = "carried"
  hero_entity:set_carrying(true) -- Change animation set of hero.
  -- Display the entity correctly.
  self:stop_movement()
  self:bring_to_front(); self:get_sprite():set_xy(0, -20)
  local x,y,z = hero_entity:get_position(); self:set_position(x,y+2,z)
  entity:on_position_changed() -- Notify the entity (to move secondary sprites, etc).
end

function entity:throw()
  -- Set variables. (Take animation and direction before freezing the hero.)
  local hero = game:get_hero(); local sprite = self:get_sprite()
  local animation = hero:get_animation(); local direction = hero:get_direction()
  hero:freeze(); hero:set_invincible(true)
  if entity.is_independent then game.save_between_maps:disable_teletransporters(map) end
  hero.custom_carry = nil; self.state = "falling"; self:set_direction(direction)
  -- If the entity can push buttons, disable it until it falls. (Enable it later.) The same if moved with platforms.
  local temp_can_push_buttons = self.can_push_buttons; self.can_push_buttons = nil
  local temp_moved_on_platform = self.moved_on_platform; self.moved_on_platform = nil
  -- Change animation set of hero to stop carrying. Start animation throw of the hero.
  hero:set_carrying(false)
  hero:set_animation("grabbing")
  sol.timer.start(self, 200, function()
    hero:set_animation("stopped"); hero:set_invincible(false); hero:unfreeze()
  end)
  game:set_custom_command_effect("action", nil); game:set_custom_command_effect("attack", nil)
  local dx, dy = 0, 0; if animation == "carrying_walking" then dx, dy = math.cos(direction*math.pi/2), -math.sin(direction*math.pi/2) end
  -- Set position on hero position and the sprite above of the entity.
  local hx,hy,hz = hero:get_position(); self:set_position(hx,hy,hz); sprite:set_xy(0,-22)
  -- Create a custom_entity for shadow (this one is drawn below).
  self.shadow = map:create_custom_entity({direction=0,layer=hz,x=hx,y=hy})    
  self.shadow:create_sprite("entities/ground_effects") -- Create sprite of the shadow.
  self.shadow:get_sprite():set_animation("shadow_small")
  self.shadow:bring_to_back()
  -- Set falling animation if any.
  if sprite:has_animation("falling") then 
    temp_starting_animation = sprite:get_animation()
    sprite:set_animation("falling") 
  end
  -- Function to bounce when entity is thrown. Parameters of list "prop" are given in pixels (the speed in pixels per second).
  -- Call: bounce({max_distance_x =..., max_height_on_x =..., max_height_y =..., speed_pixels_per_second =..., callback =...})
  local function bounce(prop)
    -- Start moving the entity.
	  local x,y,z; local sx, sy = sprite:get_xy(); local speed = prop.speed_pixels_per_second
	  local x_f, x_m, h, i = prop.max_distance_x, prop.max_height_on_x, prop.max_height_y, 0
	  local a = -h/(x_m^2); local b = -2*a*x_m; local h2 =  sy
    local function f1(x) return -math.floor(a*x^2+b*x) end
    local function f2(x) return -math.floor((h2/math.max(x_f-2*x_m, 1))*(x-2*x_m)) end
    local is_obstacle_reached = false
    sol.timer.start(entity, math.floor(1000/speed), function()
      i = i+1; self.shadow:set_position(entity:get_position())
      entity:on_position_changed() -- Notify the entity (to move secondary sprites, etc).
      if i < 2*x_m then sprite:set_xy(0, h2 + f1(i))
      elseif i <= x_f then sprite:set_xy(0, h2 + f2(i))
      -- Call the callback and stop the timer. 
      else
        self:check_on_ground() -- Check for bad ground.
        if prop.callback ~= nil and self:exists() then -- Check if the entity exists (it can be removed on holes, water and lava).
          prop:callback() 
        end    
        return false
      end
      return true
    end)
    -- Move the shadow if necessary. Make the entity stop if its shadow collisions with some obstacle.
    if animation == "carrying_walking" then
      local m = sol.movement.create("straight"); m:set_angle(direction*math.pi/2)
      m:set_speed(speed); m:set_max_distance(x_f); m:set_smooth(false)
      function m:on_obstacle_reached() m:stop(); is_obstacle_reached = true end
      m:start(entity)
    end
  end
  
  -- Function called when the entity has fallen.
  local function finish_bounce()
    self.shadow:remove() 
    sprite:set_xy(0,0); self.state = "on_ground"
    game:set_interaction_enabled(entity, true) -- Start checking the hero again.
    game:clear_interaction() -- Restart hero interaction.
    if temp_starting_animation then sprite:set_animation(temp_starting_animation) end -- Restore the initial animation, if necessary.
    entity:on_position_changed() -- Notify the entity (to move secondary sprites, etc).
    if temp_moved_on_platform then entity.moved_on_platform = true end -- Allow to be moved on platforms again, if necessary.
    if temp_can_push_buttons then self.can_push_buttons = true end -- Allow to push buttons again, if necessary.
    --entity:start_checking_ground() -- Restart the timer to check ground once per second.
                                     -- (creates multiple timers so recommended to remove by Diarandor for v0.8)
  end
  
  -- Start movement of the shadow. Throw the entity away in the direction of the hero and start checking the hero.
  bounce({max_distance_x = 80, max_height_on_x = 30, max_height_y = 8, speed_pixels_per_second = 200,
  callback = function() bounce({max_distance_x = 16, max_height_on_x = 8, max_height_y = 4, speed_pixels_per_second = 100,
  callback = function() bounce({max_distance_x = 4, max_height_on_x = 2, max_height_y = 2, speed_pixels_per_second = 60,
  callback = finish_bounce }) end }) end })
end

-- Used to update direction/state when following the hero. Calls on_custom_position_changed if defined.
function entity:on_position_changed()
  if entity.state == "carried" then
    self:set_direction(game:get_hero():get_direction())
  end
  if self.on_custom_position_changed then self:on_custom_position_changed() end
end

-- Check for bad ground (water, hole and lava) and also for empty ground. (Used on each bounce when thrown.)
function entity:check_on_ground()
  local x, y, layer = self:get_position()
  local ground = map:get_ground(x, y, layer)
  if ground == "empty" and layer > 0 then 
    -- Fall to lower layer and check ground again.
     self:set_position(x, y, layer-1)
     self:check_on_ground() -- Check again new ground.
  elseif ground == "hole" then  
    -- Create falling animation centered correctly on the 8x8 grid.
    x = math.floor(x/8)*8 + 4; if map:get_ground(x, y, layer) ~= "hole" then x = x + 4 end
    y = math.floor(y/8)*8 + 4; if map:get_ground(x, y, layer) ~= "hole" then y = y + 4 end
    local fall_on_hole = map:create_custom_entity({x = x, y = y, layer = layer, direction = 0})
    local sprite = fall_on_hole:create_sprite("entities/ground_effects")
    sprite:set_animation("hole_fall")
    self.shadow:remove(); self:remove()
    function sprite:on_animation_finished() fall_on_hole:remove() end
    --sol.audio.play_sound("falling_on_hole")
  elseif ground == "deep_water" then
    -- Sink in water.
    local water_splash = map:create_custom_entity({x = x, y = y, layer = layer, direction = 0})    
    local sprite = water_splash:create_sprite("entities/ground_effects")
    sprite:set_animation("water_splash")
    self.shadow:remove(); self:remove()
    function sprite:on_animation_finished() water_splash:remove() end
    --sol.audio.play_sound("splash")
  elseif ground == "lava" then
    -- Sink in lava.
    local lava_splash = map:create_custom_entity({x = x, y = y, layer = layer, direction = 0})    
    local sprite = lava_splash:create_sprite("entities/ground_effects")
    sprite:set_animation("lava_splash")
    self.shadow:remove(); self:remove()
    function sprite:on_animation_finished() lava_splash:remove() end
    --sol.audio.play_sound("splash")
  elseif self.state == "falling" then -- Used for bounces, when the entity is thrown.
    sol.audio.play_sound(self.sound) -- Bouncing sound.
  end
end

-- Start a timer to check ground once per second (useful if the ground moves or changes type!!!).
function entity:start_checking_ground()
  sol.timer.start(self, 1000, function()
    if entity.state == "on_ground" then entity:check_on_ground() end
    return true
  end)
end

-- Function to get the information to save between maps.
function entity:get_saved_info()
  local properties = {state = self.state}
  -- Use the function entity.get_more_saved_info to get more extra information!!!
  if entity.get_more_saved_info then properties = entity:get_more_saved_info(properties) end
  return properties
end

-- Function to recover the saved information between maps.
function entity:set_saved_info(properties)
  self.state = properties.state
  if self.state == "carried" then
    local hero = game:get_hero()
    self:set_carried(hero)
  end
  -- Use the function entity.set_more_saved_info to set more extra information!!!
  if entity.set_more_saved_info then entity:set_more_saved_info(properties) end
end