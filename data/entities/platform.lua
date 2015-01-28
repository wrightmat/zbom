local entity = ...
local map = entity:get_map()
local hero = map:get_entity("hero")

local ex, ey, el, hx, hy, hl
local recent_obstacle = 0

-- Platform: entity which moves in either horizontally or
-- vertically (depending on direction) and carries the hero on it.

function entity:on_created()
  self:create_sprite("entities/platform")
  self:set_size(32, 32)
  self:set_origin(20, 20)
  self:set_traversable_by("hero", true)
  self:set_can_traverse_ground("hole", true)
  self:set_can_traverse_ground("deep_water", true)
  self:set_can_traverse_ground("traversable", false)
  self:set_can_traverse_ground("shallow_water", false)

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
    
    ex, ey, el = entity:get_center_position()
    hx, hy, hl = hero:get_position()
    print('x: '..ex+(hx-ex)..', y: '..ey+(hy-ey))
    self:set_position(ex+(hx-ex), ey+(hy-ey))
  end)

end

function entity:on_restarted()
  local direction4 = self:get_sprite():get_direction()
  local m = sol.movement.create("path")
  m:set_path{direction4 * 2}
  m:set_speed(96)
  m:set_loop(true)
  m:start(self)
end

function entity:on_obstacle_reached()
  local direction4 = self:get_sprite():get_direction()
  self:get_sprite():set_direction((direction4 + 2) % 4)

  local x, y = self:get_position()
  recent_obstacle = 8
  self:restart()
end

function entity:on_position_changed()
  if recent_obstacle > 0 then
    recent_obstacle = recent_obstacle - 1
  end

end

function entity:on_movement_changed(movement)
  local direction4 = movement:get_direction4()
  self:get_sprite():set_direction(direction4)
end
