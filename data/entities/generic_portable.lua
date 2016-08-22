--[[ Base script used to define entities that can be lifted but not destroyed when thrown. When the custom entity can be lifted, we save a reference to it in hero.custom_lift.
To start lifting a custom entity, call the method "lift()" of the entity to lift, in case it is defined. Similar with hero.custom_carry, entity:set_carried(hero_entity), etc.
To call this script from another,  use: "sol.main.load_file("entities/generic_portable")(entity)" and define a method entity:on_custom_created()  for the initialization, if necessary. 
We simulate the carrying state by changing position of the entity with bigger y-coordinate than the hero and setting the property to draw on Y-order.
---
The state, "on_ground", "lifting", "carried", "falling", "falling_from_high", can be recovered with entity.state.
Custom events:
on_custom_created, on_custom_position_changed, on_custom_start_lift, on_custom_finish_lift, 
on_custom_start_fall, on_custom_finish_fall, on_custom_start_carry, ...
--]]

local entity = ...

local can_be_lifted = true -- See function "entity:can_be_lifted()" below.
entity.unique_id = nil
entity.is_independent = nil
entity.can_push_buttons = nil
entity.can_save_state = true
entity.moved_on_platform = true
entity.state = "on_ground"
entity.sound = "bomb" -- Default id of the bouncing sound.
entity.action_effect = "lift" -- Use this to notify the effect to the hud.
entity.hurt_damage = nil -- Set a damage number to hurt enemies when thrown.
entity.sprite_shift = 0 -- To customize the shift of the sprite.
entity.num_bounces = 3 -- Number of bounces when falling (it can be 0).
entity.bounce_distances = {80, 16, 4} -- Distances for each bounce.
entity.bounce_heights = {"same", 4, 2} -- Heights for each bounce.
entity.bounce_durations = {400, 160, 70} -- Durations for each bounce.

local game = entity:get_game()
local map = entity:get_map()

-- Variables to recover initial information.
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
  -- Starts checking the ground, once per second.
  entity:start_checking_ground()
  -- Collision test to let other npc_hero catch the entity on the air.
  entity:add_collision_test("overlapping", function(self, other_entity)
    if self.state ~= "falling" then return end -- Do nothing if not falling.
    -- Allow npc_heroes to pick this entity in the air.
    if other_entity.is_npc_hero and other_entity.custom_carry == nil 
    and self:get_distance(other_entity) < 8 then
      -- If the npc_hero has been created in that frame, the index may still be nil (and we get an error).
      if other_entity:get_index() == nil then return end 
      -- Set states.
      sol.timer.stop_all(self)
      can_be_lifted = false
      self.shadow:remove(); self.shadow = nil
      sol.audio.play_sound("lift")
      other_entity.custom_carry = self; self:set_carried(other_entity)
      self.state = "carried"
      -- Custom event when carrying.
      if self.on_custom_start_carry then self:on_custom_start_carry() end
      -- Recover initial values.
      if temp_can_push_buttons then self.can_push_buttons = true end -- Allow to push buttons again, if necessary.
      if temp_moved_on_platform then self.moved_on_platform = true end -- Allow to be moved on platforms again, if necessary.
    -- Allow to damage enemies or other entities, but only if entity.hurt_damage ~= nil.
    elseif self.hurt_damage ~= nil and other_entity:get_type() == "enemy" then
      other_entity:hurt(self.hurt_damage)
    end
  end)
  -- Define next function in other scripts for more customization!!!
  if entity.on_custom_created then entity:on_custom_created() end 
end

-- Return a boolan to know if this can be lifted.
function entity:can_be_lifted() return can_be_lifted end

-- On interaction, lift the entity.
function entity:on_interaction()
  local other_portable = self:get_game():get_hero().custom_carry
  if can_be_lifted and (other_portable == nil) then
    can_be_lifted = false
    self:lift()
  end
end
 
-- Start lifting the object.
function entity:lift()
  entity.action_effect = nil -- Update action effect.
  local hero = map:get_hero()
  self.state = "lifting"; hero:freeze(); hero:set_invincible(true)
  entity:on_position_changed() -- Notify the entity (to move secondary sprites, etc).
  -- Get the index of the hero who is lifting. Associate the entity to the hero. Stop saving between maps.
  hero.custom_carry  = entity; hero.custom_lift = nil
  -- Custom event before lift.
  if self.on_custom_start_lift then self:on_custom_start_lift() end -- Custom event.
  -- Show the hero lifting animation.
  sol.audio.play_sound("lift")
  hero:set_animation("lifting", function()
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

-- The hero or some npc_hero is displayed carrying this entity. 
function entity:set_carried(hero_entity)
  -- Disable interaction.
  can_be_lifted = false
  entity.action_effect = nil -- Update action effect.
  -- Change state. Change animation set of the hero_entity.
  hero_entity.custom_carry = entity
  self.state = "carried"
  hero_entity:set_carrying(true)
  -- Display the entity correctly.
  self:stop_movement()
  self:bring_to_front(); self:get_sprite():set_xy(0, -20 + self.sprite_shift)
  local x,y,z = hero_entity:get_position(); self:set_position(x,y+2,z)
  self:on_position_changed() -- Notify the entity (to move secondary sprites, etc).
  -- Update custom command effects.
  game:set_custom_command_effect("attack", "custom_carry")
end


-- Function to throw the entity.
function entity:throw(optional_args)
  game:set_custom_command_effect("attack", nil)
  -- Initialize optional arguments and properties for the three bounces.
  local args = optional_args or {}
  current_bounce = args.current_bounce or 1 -- Global variable!
  current_instant = args.current_instant or 0 -- Global variable!
  falling_direction = args.falling_direction -- Global var. Nil means no direction.
  local fdir = falling_direction
  local carrier = args.carrier
  local sprite = self:get_sprite()
  
  -- More properties and state changes.
  self.state = "falling"
  local dx, dy = 0, 0
  if fdir then 
    self:set_direction(fdir) 
    dx, dy = math.cos(fdir*math.pi/2), -math.sin(fdir*math.pi/2)     
  end
  sprite:set_xy(0, -22 + self.sprite_shift)
  
  -- If the entity can push buttons, disable it until it falls. (Enable it later.) 
  -- The same if moved with platforms.
  local temp_can_push_buttons = self.can_push_buttons
  self.can_push_buttons = nil
  local temp_moved_on_platform = self.moved_on_platform
  self.moved_on_platform = nil

  -- Create a custom_entity for shadow (this one is drawn below).
  local px, py, pz = self:get_position()
  self.shadow = map:create_custom_entity({direction=0, layer=pz, x=px, y=py, width=16, height=16})    
  self.shadow:create_sprite("entities/shadow")
  self.shadow:bring_to_back()
  
  -- Custom event before throw.
  if self.on_custom_start_fall then self:on_custom_start_fall() end
  
  -- Function called when the entity has fallen.
  local function finish_bounce()
    self.shadow:remove(); self.shadow = nil
    sprite:set_xy(0,0); self.state = "on_ground"
    self:stop_movement()
    can_be_lifted = true
    entity.action_effect = "lift" -- Update action effect.
    if temp_moved_on_platform then 
      -- Allow to be moved on platforms again, if necessary.
      entity.moved_on_platform = true
    end 
    if temp_can_push_buttons then
      -- Allow to push buttons again, if necessary.
      self.can_push_buttons = true
    end
    -- Reset global variables (used to save betwen maps).
    current_instant = nil
    current_bounce = nil
    falling_direction = nil
    -- Change Z-order to give priority for interactions.
    self:bring_to_front() 
    -- Custom event after falling.
    if self.on_custom_finish_fall then self:on_custom_finish_fall() end
  end
    
  -- Function to bounce when entity is thrown.
  local function bounce()
    -- Finish bouncing if we have already done three bounces.
    if current_bounce > entity.num_bounces then 
      finish_bounce()    
      return
    end  
    -- Initialize parameters for the bounce.
	  local x,y,z; local _, sy = sprite:get_xy()
    if entity.bounce_heights[1] == "same" then entity.bounce_heights[1] = -sy end
    local dist = entity.bounce_distances[current_bounce]
    local h = entity.bounce_heights[current_bounce]
    local dur = entity.bounce_durations[current_bounce]  
    local speed = 1000 * dist / dur -- Speed of the straight movement (pixels per second).
    local t = current_instant
    local is_obstacle_reached = false
    
    -- Function to compute height for each fall (bounce).
    local function current_height()
      if current_bounce == 1 then return h * ((t / dur) ^ 2 - 1) end
      return 4 * h * ((t / dur) ^ 2 - t / dur)
    end 
    -- Start straight movement if necessary.
    -- Make the entity stop if it collisions with some obstacle.
    if fdir then
      local m = sol.movement.create("straight")
      m:set_angle(fdir * math.pi / 2)
      m:set_speed(speed); m:set_max_distance(dist); m:set_smooth(false)
      function m:on_obstacle_reached() m:stop(); is_obstacle_reached = true end
      m:start(entity)
    end
    
    -- Start shifting height of the entity at each instant for current bounce.
    local refreshing_time = 5 -- Time between computations of each position.
    sol.timer.start(entity, refreshing_time, function()
      t = t + refreshing_time; current_instant = t
      self.shadow:set_position(entity:get_position())
      entity:on_position_changed() -- Notify the entity (to move secondary sprites, etc).
      if t <= dur then sprite:set_xy(0, current_height() + entity.sprite_shift)
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
  end

  -- Start the bounces in the given direction.
  bounce()
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
    local fall_on_hole = map:create_custom_entity({x = x, y = y, width=16, height=16, layer = layer, direction = 0})
    local sprite = fall_on_hole:create_sprite("entities/ground_effects")
    sprite:set_animation("hole_fall")
    self.shadow:remove(); self:remove()
    function sprite:on_animation_finished() fall_on_hole:remove() end
    --sol.audio.play_sound("falling_on_hole")
  elseif ground == "deep_water" then
    -- Sink in water.
    local water_splash = map:create_custom_entity({x = x, y = y, width=16, height=16, layer = layer, direction = 0})    
    local sprite = water_splash:create_sprite("entities/ground_effects")
    sprite:set_animation("water_splash")
    self.shadow:remove(); self:remove()
    function sprite:on_animation_finished() water_splash:remove() end
    --sol.audio.play_sound("splash")
  elseif ground == "lava" then
    -- Sink in lava.
    local lava_splash = map:create_custom_entity({x = x, y = y, width=16, height=16, layer = layer, direction = 0})    
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
  self.shadow = map:create_custom_entity({direction=0, layer=layer, x=x, y=y, width=16, height=16})
  self.shadow:create_sprite("entities/shadow")
  self.shadow:bring_to_back()
  -- Set initial position and state.
  self:set_position(x,y-height,2)
  self.state = "falling_from_high"
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
        entity.fall_from_high_properties = nil -- Destroy this info.
        -- Call custom event after falling on solid ground.
        if entity.on_custom_finish_fall then entity:on_custom_finish_fall() end
	    end
	  end	
  end
end

-- Delete shadow if any. Call custom event on_custom_removed, if defined.
-- TODO: is this function necessary???
function entity:on_removed()
  if self.shadow then self.shadow:remove() end -- Necessary when switching between maps.
  if self.on_custom_removed then self:on_custom_removed() end
end

-- Function to get the information to save between maps.
function entity:get_saved_info()
  local properties = {state = self.state,
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
    self:set_carried(game:get_hero())
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