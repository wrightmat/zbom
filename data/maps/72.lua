local map = ...
local game = map:get_game()

------------------------------------------
-- Outside World B8 (Gerudo Encampment) --
------------------------------------------

function map:on_started()
  -- Activate any night-specific dynamic tiles.
  if game:get_time_of_day() == "night" then
    for entity in game:get_map():get_entities("night_") do
      entity:set_enabled(true)
    end
  end
end