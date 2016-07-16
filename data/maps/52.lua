local map = ...
local game = map:get_game()

---------------------------------
-- Outside World B5 (Snowpeak) --
---------------------------------

function map:on_started(destination)
  -- Bushes are frozen and can only by cut with a more powerful sword.
  if game:get_ability("sword") >= 2 then
    for bush in map:get_entities("bush_") do
      bush:set_can_be_cut(true)
    end
  end

  -- Activate any night-specific dynamic tiles.
  if game:get_time_of_day() == "night" then
    for entity in game:get_map():get_entities("night_") do
      entity:set_enabled(true)
    end
  end
end