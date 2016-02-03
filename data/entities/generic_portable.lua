--[[ Base script used to define entities that can be lifted but not destroyed when thrown. When the custom entity can be lifted, we save a reference to it in hero.custom_lift.
To start lifting a custom entity, call the method "lift()" of the entity to lift, in case it is defined. Similar with hero.custom_carry, entity:set_carried(hero_entity), etc.
To call this script from another,  use: "sol.main.load_file("entities/generic_portable")(entity)" and define a method entity:on_custom_created()  for the initialization, if necessary. 
We simulate the carrying state by changing position of the entity with bigger y-coordinate than the hero and setting the property to draw on Y-order.
 +---
 +The state, "on_ground", "lifting", "carried", "falling", "falling_from_high", can be recovered with entity.state.
 +Custom events:
 +on_custom_created, on_custom_position_changed, on_custom_start_lift, on_custom_finish_lift, 
 +on_custom_start_fall, on_custom_finish_fall, on_custom_start_carry, ...

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
entity.hurt_damage = nil -- Set a damage number to hurt enemies when thrown.
entity.nb_max_bounces = 3 -- Maximum number of bounces when falling (1, 2 or 3).
entity.sprite_shift = 0 -- To customize the shift of the sprite.
entity.speed_pixels_per_second = nil -- Array of speeds for each bounce.
entity.max_distance_x = nil -- Array of max distances for each bounce. 

local game = entity:get_game()
local map = entity:get_map()

-- Variables to recover initial information after thrown.
local temp_moved_on_platform
local temp_can_push_buttons

-- Variables to save between maps when throwing.
local current_instant -- Instant of the current bouncing.
local current_bounce -- Takes values 1, 2 or 3.
local falling_direction -- Normal direction, or nil value if falling down.

function entity:on_created()
  -- Properties.
  entity:set_drawn_in_y_order(true)
  self:set_can_traverse_ground("hole", true)
  self:set_can_traverse_ground("deep_water", true)
  self:set_can_traverse_ground("lava", true)
  self:set_can_traverse_ground("shallow_water", true)
  self:set_can_traverse("jumper", true)
  -- Interaction properties for the HUD.
  game:set_interaction_enabled(entity, true)
  -- Starts checking the ground, once per second (the ground can change).
  entity:start_checking_ground()
  -- Define next function in other scripts for more customization!!!
  if entity.on_custom_created then entity:on_custom_created() end 
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
 -- Custom event before lift.
  if self.on_custom_start_lift then self:on_custom_start_lift() end -- Custom event.
  -- Show the hero lifting animation.
  sol.audio.play_sound("lift")
  hero:set_animation("lifting", function() 
	  hero:set_animation("stopped")
	  hero:unfreeze(); hero:set_invincible(false)
	  self:set_carried(hero)
    -- Custom event after lift.
    if self.on_custom_finish_lift then self:on_custom_finish_lift() end -- Custom event.
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
      sprite:set_xy(dx*16, -8 + entity.sprite_shift)
    elseif i == 2 then 
      sprite:set_xy(dx*16, -16 + entity.sprite_shift)
    else 
      sprite:set_xy(0, -20 + entity.sprite_shift)
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
  self:bring_to_front(); self:get_sprite():set_xy(0, -20 + self.sprite_shift)
  local x,y,z = hero_entity:get_position(); self:set_position(x,y+2,z)
  self:on_position_changed() -- Notify the entity (to move secondary sprites, etc).
  game:set_interaction_enabled(self, false) -- Disable interaction.
end

-- Function to throw the entity.
function entity:throw(optional_args)
  -- Initialize optional arguments and properties for the three bounces.
  local args = optional_args or {}
  current_bounce = args.current_bounce or 1 -- Global variable!
  current_instant = args.current_instant or 0 -- Global variable!
  falling_direction = args.falling_direction -- Global var. Nil means no direction.
  local fdir = falling_direction
  local carrier = args.carrier
  local max_distance_x = entity.max_distance_x or {80, 16, 4} -- Properties for each bounce.
  local max_height_on_x = {30, 8, 2} -- Properties for each bounce.
  local max_height_y = {8, 4, 2} -- Properties for each bounce.
  local speed_pixels_per_second = 
    entity.speed_pixels_per_second or {200, 100, 60} -- Properties for each bounce.
  local sprite = self:get_sprite()
  
  -- More properties and state changes.
  self.associated_hero_index = nil
  self.state = "falling"
  local dx, dy = 0, 0
  if fdir then 
    self:set_direction(fdir) 
    dx, dy = math.cos(fdir*math.pi/2), -math.sin(fdir*math.pi/2)     
  end
  sprite:set_xy(0,-22 + self.sprite_shift)
  
  -- If the entity can push buttons, disable it until it falls. (Enable it later.) 
  -- The same if moved with platforms.
  local temp_can_push_buttons = self.can_push_buttons
  self.can_push_buttons = nil
  local temp_moved_on_platform = self.moved_on_platform
  self.moved_on_platform = nil

  -- Create a custom_entity for shadow (this one is drawn below).
  local px, py, pz = self:get_position()
  self.shadow = map:create_custom_entity({direction=0,layer=pz,x=px,y=py})    
  self.shadow:create_sprite("entities/ground_effects")
  self.shadow:get_sprite():set_animation("shadow_small")
  self.shadow:bring_to_back()
  
  -- Custom event before throw.
  if self.on_custom_start_fall then self:on_custom_start_fall() end
  
  -- Function called when the entity has fallen.
  local function finish_bounce()
    self.shadow:remove(); self.shadow = nil
    sprite:set_xy(0,0); self.state = "on_ground"
    self:stop_movement()
    if not game:is_interaction_enabled(entity) then
      game:set_interaction_enabled(entity, true) -- Start checking the hero again.      
    end
    if temp_moved_on_platform then 
      -- Allow to be moved on platforms again, if necessary.
      entity.moved_on_platform = true
    end 
    if temp_can_push_buttons then
      -- Allow to push buttons again, if necessary.
      self.can_push_buttons = true
    end
    -- Reset global variables (used to save betwen maps).
    entity.inertia = nil -- Destroy inertia info, if any.
    current_instant = nil
    current_bounce = nil
    falling_direction = nil
    -- Custom event after falling.
    if self.on_custom_finish_fall then self:on_custom_finish_fall() end
  end
  
  -- Function to bounce when entity is thrown. Parameters of list "prop" are given in pixels (the speed in pixels per second).
  -- Call: bounce({max_distance_x =..., max_height_on_x =..., max_height_y =..., speed_pixels_per_second =..., callback =...})
  local function bounce()
    -- Finish bouncing if we have already done three bounces.
    if current_bounce > entity.nb_max_bounces then 
      finish_bounce()    
      return
    end  
    -- Initialize parameters for the bounce.
    local x,y,z; local sx, sy = sprite:get_xy()
    local speed = speed_pixels_per_second[current_bounce]
    local x_f = max_distance_x[current_bounce]
    local x_m = max_height_on_x[current_bounce]
    local h = max_height_y[current_bounce]
    local i = current_instant
	  local a = -h/(x_m^2); local b = -2*a*x_m; local h2 =  sy
    local function f1(x) return -math.floor(a*x^2+b*x) end
    local function f2(x) return -math.floor((h2/math.max(x_f-2*x_m, 1))*(x-2*x_m)) end
    local is_obstacle_reached = false
    
    -- Start moving the entity at each instant for each bounce.
    sol.timer.start(entity, math.floor(1000/speed), function()
      i = i+1; current_instant = i
      self.shadow:set_position(entity:get_position())
      entity:on_position_changed() -- Notify the entity (to move secondary sprites, etc).
      if i < 2*x_m then sprite:set_xy(0, h2 + f1(i) + entity.sprite_shift)
      elseif i <= x_f then sprite:set_xy(0, h2 + f2(i) + entity.sprite_shift)
      -- Stop the timer. Start next bounce or finish bounces. 
      else -- The entity hits the ground.
        self:check_on_ground() -- Check for bad ground.
        -- Check if the entity exists (it can be removed on holes, water and lava).
        if self:exists() then 
          current_bounce = current_bounce + 1
          current_instant = 0
          bounce() -- Start next bounce.
        end
        return false
      end
      return true
    end)
    
    -- Move the shadow if necessary. Make the entity stop if its shadow collisions with some obstacle.
    if fdir then
      local m = sol.movement.create("straight")
      m:set_angle(fdir*math.pi/2)
      m:set_speed(speed); m:set_max_distance(x_f); m:set_smooth(false)
      function m:on_obstacle_reached() m:stop(); is_obstacle_reached = true end
      m:start(entity)
    end
  end

  -- Give inertia when thrown by carrier from moving platforms.
  local function make_inertia(carrier)
    -- We need to get inertia info.
    local direction, speed, is_moving
    
    -- If there is inertia info saved between maps, restore it.
    if entity.inertia ~= nil then
      direction = entity.inertia.direction
      speed = entity.inertia.speed
      is_moving = entity.inertia.is_moving
    else -- There is no inertia info saved (between maps).
    -- We need to check platforms.
    
      -- TODO: change next line to use the buggy function get_entities_in_rectangle when fixed.
      --for other in map:get_entities_in_rectangle(carrier:get_bounding_box()) do
    
      for other in map:get_entities("") do
        -- The entity is a platform (it has inertia). Stop looking if found inertia.
        if other.get_inertia then 
          -- Check if carrier is on the platform and if the platform is moving.
          direction, speed, is_moving = other:get_inertia() -- Get intertia info.
          if other:is_on_platform(carrier) and is_moving then 
            -- Store inertia info to save between maps.
            entity.inertia = {direction=direction,speed=speed,is_moving=is_moving}
            break -- Stop looking for more platforms.
          end
        end
      end
    end
      
    -- Stop if no inertia was found.
    if not entity.inertia then return end
    
    -- Start moving.
    local ddx, ddy = math.cos(direction*math.pi/2), -math.sin(direction*math.pi/2)
    local sx, sy, sz
    sol.timer.start(entity, math.floor(1000/speed), function()
      if entity.state ~= "falling" then return false end -- Stop inertia after the fall.
      sx, sy, sz = self.shadow:get_position()
      if not self.shadow:test_obstacles(ddx, ddy, sz) then
        self.shadow:set_position(sx + ddx, sy + ddy, sz)
        local x,y,z = entity:get_position()
        x = x+ddx; y = y+ddy
        entity:set_position(x,y,z)
      else return false end -- Stop inertia if obstacle is found.
      return true
    end)       
  end

  -- Start the bounces in the given direction. Start shift of inertia.
  bounce()
  make_inertia(carrier)
end

-- Used to update direction/state when following the hero. Calls on_custom_position_changed if defined.
function entity:on_position_changed()
  if entity.state == "carried" then
    self:set_direction(game:get_hero():get_direction())
  end
  if self.on_custom_position_changed then self:on_custom_position_changed() end
end

-- Check for bad ground (water, hole and lava) and for empty ground (used on each bounce when thrown).
function entity:check_on_ground()
  --self:get_map():ground_collision(entity)
end

-- Start a timer to check ground once per second (useful if the ground moves or changes type!!!).
function entity:start_checking_ground()
  sol.timer.start(self, 1000, function()
    if entity.state == "on_ground" then entity:check_on_ground() end
    return true
  end)
end

-- Function to make the entity fall from high. To use it set:
-- properties = {height = ..., x = ..., y = ..., layer = ..., falling_animation = ..., animation = ...} 
function entity:fall_from_high(falling_properties)
  -- Get properties.
  entity.fall_from_high_properties = falling_properties -- Used to save between maps.
  local height = falling_properties.height
  -- Custom event before falling.
  if self.on_custom_start_fall then self:on_custom_start_fall() end
  -- Create shadow.
  local x,y,layer = falling_properties.x, falling_properties.y, falling_properties.layer
  self.shadow = map:create_custom_entity({direction=0, layer=layer, x=x, y=y})
  self.shadow:create_sprite("entities/ground_effects")
  self.shadow:get_sprite():set_animation("shadow_small")
  self.shadow:bring_to_back()
  -- Set initial position and state.
  self:set_position(x,y-height,2)
  self.state = "falling_from_high"
  if game:is_interaction_enabled(entity) then
    game:set_interaction_enabled(entity, false) -- Disable checking hero interaction.      
  end
  -- Create movement.
  local m = sol.movement.create("straight")
  m:set_speed(150); m:set_angle(3*math.pi/2)
  m:set_ignore_obstacles(true)
  m:set_max_distance(height)
  m:start(entity)
  -- Bouncing effect after falling.
  function m:on_finished() 
    sol.audio.play_sound(entity.sound) -- Bounce sound.
    entity:check_on_ground() -- Check for bad ground.
    m = sol.movement.create("straight")
    m:set_speed(60); m:set_angle(math.pi/2)
    m:set_max_distance(16); m:set_ignore_obstacles(true)
    m:start(entity)
    function m:on_finished() 
    m = sol.movement.create("straight")
      m:set_speed(60); m:set_angle(3*math.pi/2)
      m:set_max_distance(16); m:set_ignore_obstacles(true)
      m:start(entity)
    function m:on_finished() 
        sol.audio.play_sound(entity.sound) -- Bounce sound.
        entity:check_on_ground() -- Check for bad ground.
        entity.shadow:remove(); entity.shadow = nil
        entity:set_position(x,y,layer) -- Restore initial layer.
	      entity.state = "on_ground"
        game:set_interaction_enabled(entity, true) -- Enable checking hero interaction.
        entity.fall_from_high_properties = nil -- Destroy this info.
        -- Call custom event after falling on solid ground.
        if entity.on_custom_finish_fall then entity:on_custom_finish_fall() end
      end
    end	
  end
end

-- Function to get the information to save between maps.
function entity:get_saved_info()
  local properties = {associated_hero_index = self.associated_hero_index, state = self.state,
  current_instant = current_instant, current_bounce = current_bounce, falling_direction = falling_direction}
  if self.state == "falling_from_high" then
    properties.fall_from_high_properties = self.fall_from_high_properties
    local _,y,_ = self:get_position()
    local height = properties.fall_from_high_properties.y - y
    properties.fall_from_high_properties.height = height
  end
  -- Use the function entity.get_more_saved_info to get more extra information!!!
  if entity.get_more_saved_info then properties = entity:get_more_saved_info(properties) end
  return properties
end

-- Function to recover the saved information between maps.
function entity:set_saved_info(properties)
  self.state = properties.state
  current_bounce = properties.current_bounce
  current_instant = properties.current_instant
  falling_direction = properties.falling_direction
  if self.state == "carried" then
    local hero = game:get_hero()
    self:set_carried(hero)
  elseif self.state == "falling" then
    self:throw({falling_direction = falling_direction, current_bounce = current_bounce, 
        current_instant = current_instant})   
  elseif self.state == "falling_from_high" then
    entity:fall_from_high(properties.fall_from_high_properties)     
  else
    entity:check_on_ground() -- Check for bad grounds.
  end
  -- Use the function entity.set_more_saved_info to set more extra information!!!
  if entity.set_more_saved_info then entity:set_more_saved_info(properties) end
end