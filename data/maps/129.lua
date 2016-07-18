local map = ...

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
  end
end