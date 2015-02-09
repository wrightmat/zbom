local entity = ...
local map = entity:get_map()
local hero = map:get_entity("hero")

local ex, ey, el
local timer
local time_in = 0

-- Quicksand: entity which slows the hero until
-- he finally falls in

function entity:on_created()
  self:create_sprite("entities/quicksand")
  self:set_size(32, 32)
  self:set_origin(16, 16)
  ex, ey, el = self:get_center_position()
  self:get_sprite():set_animation("quicksand")

  self:add_collision_test("overlapping", function(quicksand, other)
    if other:get_type() ~= "hero" then
      return
    end
    local hero = other

    -- Only do this in some specific states (in particular, don't do it while jumping, flying with the hookshot, etc.)
    if hero:get_state() ~= "free" and hero:get_state() ~= "sword loading" then
      return
    end

    -- Move the hero toward the quicksand's center every 20 ms while he is overlapping it.
    if timer == nil then
      timer = sol.timer.start(self, 20, function()
        time_in = time_in + 1
	hx, hy, hl = hero:get_position()
	if ex > hx then hx = hx + 1 else hx = hx - 1 end
	if ey > hy then hy = hy + 1 else hy = hy - 1 end
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
