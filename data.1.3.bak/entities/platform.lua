local entity = ...
local hero = entity:get_map():get_entity("hero")

-- Platform: entity which moves in either horizontally or
-- vertically (depending on direction) and carries the hero on it.

local speed = 25
local time_stopped = 1000

function entity:on_created()
  self:create_sprite("entities/platform")
  self:set_size(32, 32)
  self:set_origin(16, 16)
  self:set_can_traverse("jumper", true)
  self:set_can_traverse_ground("hole", true)
  self:set_can_traverse_ground("deep_water", true)
  self:set_can_traverse_ground("traversable", false)
  self:set_can_traverse_ground("shallow_water", false)
  self:set_can_traverse_ground("wall", false)
  self:set_modified_ground("traversable")
  self:set_layer_independent_collisions(false)

  local m = sol.movement.create("path")
  local direction4 = self:get_sprite():get_direction()
  m:set_path{direction4 * 2}
  m:set_speed(speed)
  m:set_loop(true)
  m:start(self)
  
  self:add_collision_test("touching", function(platform, other)
    if other:get_type() == "wall" and other:get_type() ~= "jumper" then
      self:on_obstacle_reached(m)
    end
  end)

end

function entity:on_obstacle_reached(movement)
  --Make the platform turn back.
  movement:stop()
  movement = sol.movement.create("path")    
  local direction4 = self:get_sprite():get_direction()
  direction4 = (direction4+2)%4
  movement:set_path{direction4 * 2}
  movement:set_speed(speed)
  movement:set_loop(true)
  sol.timer.start(self, time_stopped, function() movement:start(self) end)
end

function entity:on_position_changed()
  -- Moves the hero if located over the platform. 
  if not self:is_on_platform(hero) then return end
  local hx, hy, hl = hero:get_position()
  local direction4 = self:get_sprite():get_direction()
  local dx, dy = 0, 0 --Variables for the translation.
  if direction4 == 0 then dx = 1
  elseif direction4 == 1 then dy = -1
  elseif direction4 == 2 then dx = -1
  elseif direction4 == 3 then dy = 1
  end
  if not hero:test_obstacles(dx, dy, hl) then hero:set_position(hx + dx, hy + dy, hl) end
end

function entity:on_movement_changed(movement)
  --Change direction of the sprite when the movement changes.
  local direction4 = movement:get_direction4()
  self:get_sprite():set_direction(direction4)
end

function entity:is_on_platform(other_entity)
  --Returns true if other_entity is on the platform. 
  local ox, oy, ol = other_entity:get_position()
  local ex, ey, el = self:get_position()
  if ol ~= el then return false end
  local sx, sy = self:get_size()
  if math.abs(ox - ex) < sx/2 -1 and math.abs(oy - ey) < sy/2 -1 then return true end
  return false
end
