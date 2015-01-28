local entity = ...
local map = entity:get_map()
local hero = map:get_entity("hero")

local ex, ey, el
local timer
local entity_name
local entity_suffix
local recent_obstacle = 0

-- Platform: entity which moves in either horizontally or
-- vertically (depending on direction) and carries the hero on it.
-- Name of the platform must be prefixed by the name of the custom entity on the map:
-- e.g. custom entity named "water_platform" would control a platform called "water_platform_1"

function entity:on_created()

  for entity in map:get_entities(self:get_name()) do
    -- full name of the entity: e.g. "water_platform_horiz"
    entity_name = entity:get_name()
    -- just the unique part of the name: e.g. "_horiz" (this usually denotes direction)
    entity_suffix = string.sub(entity_name, string.len(self:get_name()))
    ex, ey, el = entity:get_center_position()

    entity:add_collision_test("overlapping", function(platform, other)
      -- This callback will be repeatedly called while other is overlapping the platform
      if other:get_type() ~= "hero" then
        return
      end
      local hero = other

      -- Only do this in some specific states (in particular, don't do it while jumping, flying with the hookshot, etc.)
      if hero:get_state() ~= "free" and hero:get_state() ~= "sword loading" then
        return
      end

      -- Start moving the hero on the platform while he is overlapping it.
      if timer == nil then
        timer = sol.timer.start(self, 20, function()
          hero:set_position(ex, ey)
          timer = nil  -- This variable "timer" ensures that only one timer is running.
        end)
      end

    end)
  end --for

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
