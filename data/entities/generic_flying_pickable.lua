-- Basic script to create a flying pickable that can only be obtained by the hero when jumping.

local entity = ...

entity.can_save_state = true
entity.sound = nil -- Default sound.

function entity:on_created()
  self:set_drawn_in_y_order(true)
  self:bring_to_front()
  -- Set traversable properties.
  self:set_can_traverse_ground("hole",true)
  self:set_can_traverse_ground("lava",true)
  self:set_can_traverse_ground("shallow_water",true)
  self:set_can_traverse_ground("deep_water",true)
  self:set_can_traverse_ground("grass",true)
  self:set_can_traverse_ground("wall",false)
  -- Add main sprite (the item sprite) if necessary and shift it.
  -- Draw this sprite under the wings sprite.
  local sprite = self:get_sprite()
  if sprite then self.main_sprite = sprite end -- Store main sprite in variable.
  -- Add wings sprite.
  local wings_sprite = self:create_sprite("npc/butterfly_grey")
  wings_sprite:set_animation("wings")
  self.wings_sprite = wings_sprite -- Store wings sprite in variable.
  -- Create shadow sprite.
  local shadow = self:create_sprite("entities/ground_effects")
  shadow:set_animation("shadow_small")
  -- Move the sprites up and down.
  self:restart_wavering()
  -- Add collision test.
  self:add_jumping_collision()
  -- Add custom event. This can be used to assign the pickable and other properties.
  if self.on_custom_created then self:on_custom_created() end
end

-- Detect collision with jumping hero.
function entity:add_jumping_collision()
  local hero = self:get_map():get_hero()
  self:add_collision_test("sprite", function(entity, other, sprite, other_sprite)
    -- Do nothing if the colliding sprite is not the main sprite.
    if sprite == nil or sprite ~= entity.main_sprite then return end
    -- After collision with jumping hero, call custom event and remove.
    if other == hero and hero:get_state() == "jumping" then
      -- If there is collision with the sword, start falling.
      local animation_set = other_sprite:get_animation_set()
      local sword_id = hero:get_sword_sprite_id()
      if animation_set == sword_id then 
        self:clear_collision_tests()
        sol.timer.stop_all(self) -- Stop wavering timer.
        if self.start_fall then self:start_fall() end -- Start falling.
        return
      end
      -- If the collision is not with the sword, pick the entity.
      if entity.on_obtained then entity:on_obtained() end
      -- Play sound if any.
      if entity.sound then sol.audio.play_sound(entity.sound) end
      -- Destroy entity.
      entity:remove()
    end
  end)
end

-- Function to start or restart wavering effect.
function entity:restart_wavering()
  sol.timer.stop_all(self) -- Reset wavering timer.
  local sprite = self.main_sprite
  local wings_sprite = self.wings_sprite
  if sprite then sprite:set_xy(0,-24) end
  if wings_sprite then wings_sprite:set_xy(0,-30) end
  -- Create timer to start moving up and down. 
  -- Position is changed several times per second.
  local dy = 1
  local t = 0
  sol.timer.start(entity, 1000/5, function()
    local _,y = sprite:get_xy()
    local _,wy = wings_sprite:get_xy()
    if sprite then sprite:set_xy(0,y+dy) end
    if wings_sprite then wings_sprite:set_xy(0,wy+dy) end
    -- Direction of movement is changed each second.
    t = (t+1)%5
    if t == 0 then dy = -dy end
    -- Restart timer.
    return true
  end)
end

-- Start the default falling animation.
function entity:start_fall()
  -- Reset sprite shift and set initial falling position.
  sol.timer.stop_all(self)
  self:stop_movement()
  local sprite = self.main_sprite
  sprite:set_xy(0, 0)
  local x,y,layer = self:get_position()
  self:set_position(x,y-24,layer)
  -- Start falling movement.
  local trajectory = {
    { 0,  0},{ 0, -2},{ 0, -2},{ 0, -2},{ 0, -2},
    { 0, -2},{ 0,  0},{ 0,  0},{ 1,  1},{ 1,  1},
    { 1,  0},{ 1,  1},{ 1,  1},{ 0,  0},{-1,  0},
    {-1,  1},{-1,  0},{-1,  1},{-1,  0},{-1,  1},
    { 0,  1},{ 1,  1},{ 1,  1},{-1,  0}
  }
  local m = sol.movement.create("pixel")
  m:set_trajectory(trajectory)
  m:set_delay(100)
  m:set_loop(false)
  m:set_ignore_obstacles(true)
  m:start(entity)
end

-- Create random movement.
function entity:random_move()
  self:stop_movement()
  local m = sol.movement.create("straight")
  local angle = 2*math.pi*math.random(); m:set_angle(angle)
  m:set_speed(10); m:set_max_distance(10)
  function m:on_finished() entity:random_move() end
  function m:on_obstacle_reached() entity:random_move() end
  m:start(self)
end