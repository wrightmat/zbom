local map = ...
local game = map:get_game()

-------------------------------------------------------------------
-- Outside World E15 (Faron Woods) - Mushroom (trading sequence) --
-------------------------------------------------------------------

if game:get_value("i1840")==nil then game:set_value("i1840", 0) end

function map:on_started()
  if game:get_value("i1840") > 1 then odd_mushroom:set_enabled(false) end

  -- Activate any night-specific dynamic tiles.
  if game:get_time_of_day() == "night" then
    for entity in game:get_map():get_entities("lava_") do
      -- We use the "lava" prefix instead of the usual "night" prefix
      -- because it's a much fainter glow.
      entity:set_enabled(true)
    end
  end
end