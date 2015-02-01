local entity = ...
local map = entity:get_map()
local hero = map:get_entity("hero")

local ex, ey, el, hx, hy, hl
local recent_obstacle = 0
local timer

-- Platform: entity which moves in either horizontally or
-- vertically (depending on direction) and carries the hero on it.

function entity:on_created()
  self:create_sprite("entities/platform")
  self:set_size(32, 32)
  self:set_origin(20, 20)
  self:set_can_traverse_ground("hole", true)
  self:set_can_traverse_ground("deep_water", true)
  self:set_can_traverse_ground("traversable", false)
  self:set_can_traverse_ground("shallow_water", false)
  self:set_can_traverse_ground("wall", false)
  self:set_modified_ground("traversable")
  self:set_layer_independent_collisions(false)

  self:add_collision_test("overlapping", function(platform, other)
    -- This callback will be repeatedly called while other is overlapping the platform
    if other:get_type() ~= "hero" then
      return
    end
    local hero = other

    -- Only do this in some specific states (in particular, don't do it while jumping, flying with the hookshot, etc.)
    if hero:get_state() ~= "free" and hero:get_state() ~= "sword loading" then
      return
    end
    
    -- Keep the hero on the platform as it moves
    if timer == nil then
      timer = sol.timer.start(self, 50, function()
        timer = nil  -- This variable "timer" ensures that only one timer is running.
      end)
    end
  end)

  local direction4 = self:get_sprite():get_direction()
  local m = sol.movement.create("path")
  m:set_path{direction4 * 2}
  m:set_speed(32)
  m:set_loop(true)
  m:start(self)

  self:add_collision_test("containing", function(platform, other)
    if other:get_type() == "wall" and other:get_type() ~= "jumper" then
      self:on_obstacle_reached(m)
    end
  end)

end

function entity:on_obstacle_reached(movement)
  movement:stop()

  local direction4 = self:get_sprite():get_direction()
  if direction4 == 0 then
    direction4 = 2
  elseif direction4 == 2 then
    direction4 = 0
  elseif direction4 == 1 then
    direction4 = 3
  elseif direction4 == 3 then
    direction4 = 1
  end

  movement:set_path{direction4 * 2}
  movement:set_speed(32)
  movement:set_loop(true)
  movement:start(self)

  local x, y = self:get_position()
  recent_obstacle = 8
end

function entity:on_position_changed()
  if timer ~= nil then
    hx, hy, hl = hero:get_position()
    ex, ey, el = entity:get_position()
    local ox = hx - ex
    local oy = hy - ey
    hero:set_position(hx-(ox/10), hy-(oy/10))
  end

  if recent_obstacle > 0 then
    recent_obstacle = recent_obstacle - 1
  end
end

function entity:on_movement_changed(movement)
  local direction4 = movement:get_direction4()
  self:get_sprite():set_direction(direction4)
end
