local map = ...
local game = map:get_game()

--------------------------------------------
-- Outside World L1 (Darunia Town/Market) --
--------------------------------------------

local function random_walk_slow(npc)
  local m = sol.movement.create("random_path")
  m:set_speed(16)
  m:start(npc)
  npc:get_sprite():set_animation("walking")
end

function map:on_started()
  random_walk_slow(goron_2)
  random_walk_slow(goron_3)

  -- Activate any night-specific dynamic tiles.
  if game:get_time_of_day() == "night" then
    for entity in game:get_map():get_entities("night_") do
      entity:set_enabled(true)
    end
    -- Market is closed at night.
    goron_2:remove()
    goron_3:remove()
    market_plume:remove()
    if market_bottle ~= nil then market_bottle:remove() end
    market_stick:remove()
    market_bombs:remove()
    market_pumpkin:remove()
  end
end