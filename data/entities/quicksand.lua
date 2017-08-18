local entity = ...
local map = entity:get_map()
local hero = map:get_entity("hero")
local ex, ey, el
local timer
local time_in = 0

-- Quicksand: entity which slows the hero until he finally falls in.

function entity:on_created()
  self:create_sprite("entities/quicksand")
  self:set_size(32, 32); self:set_origin(16, 16)
  ex, ey, el = self:get_center_position()
  self:get_sprite():set_animation("quicksand")
  
  self:add_collision_test("overlapping", function(quicksand, other)
    if other:get_type() ~= "hero" then return end
    local hero = other
    local hx, hy, hl = hero:get_position()
    -- Make sure the hero doesn't get stuck in the quicksand forever. Set the return point to just
    -- left of the quicksand unless that's an obstacle, then do just to the right.
    if not hero:test_obstacles(-24, 0) then
      hero:save_solid_ground(ex - 24, ey, el)
    else
      hero:save_solid_ground(ex + 24, ey, el)
    end
    -- Move the hero toward the quicksand's center every 20 ms while he is overlapping it (and not in a state like "running").
    if timer == nil and (hero:get_state() == "free" or hero:get_state() == "sword loading") then
      timer = sol.timer.start(self, 20, function()
        time_in = time_in + 1
        if ex > hx then hx = hx + 2 else hx = hx - 2 end
        if ey > hy then hy = hy + 2 else hy = hy - 2 end
        hero:set_position(hx, hy)
        timer = nil  -- This variable "timer" ensures that only one timer is running.
        -- If hero stays in the quicksand too long, he sinks.
        if time_in == 50 then
          time_in = 0
          self:set_modified_ground("hole")
        end
      end)
    end
  end)
end

function entity:on_ground_below_changed(ground_below)
  -- Change ground back to normal from hole.
  sol.timer.start(self, 1000, function() self:set_modified_ground("empty") end)
end