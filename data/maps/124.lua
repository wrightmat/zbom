local map = ...
local game = map:get_game()

--------------------------------------------
-- Outside World K1 (Darunia Town/Market) --
--------------------------------------------

local function random_walk_slow(npc)
  local m = sol.movement.create("random_path")
  m:set_speed(16)
  m:start(npc)
  npc:get_sprite():set_animation("walking")
end

function map:on_started()
  random_walk_slow(goron_1)
  random_walk_slow(goron_4)

  -- Activate any night-specific dynamic tiles.
  if game:get_time_of_day() == "night" then
    for entity in game:get_map():get_entities("night_") do
      entity:set_enabled(true)
    end
    -- Market is closed at night.
    goron_1:remove()
    goron_4:remove()
    market_alchemy:remove()
    if market_hammer ~= nil then market_hammer:remove() end
    market_jade:remove()
    market_apple:remove()
    market_amber:remove()
  end
end