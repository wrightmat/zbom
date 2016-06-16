local map = ...
local game = map:get_game()

----------------------------------------------------
-- Outside N1 (Nabooru Wastelands) - Enemy Hoarde --
----------------------------------------------------

function map:on_started(destination)
  if not game:get_value("hinox_camp_crystal") then chest_crystal:set_enabled(false) end
end

for enemy in map:get_entities("hinox") do
  enemy.on_dead = function()
    if not map:has_entities("hinox") and not game:get_value("hinox_camp_crystal") then
      chest_cystal:set_enabled(true)
      sol.audio.play_sound("chest_appears")
    end
  end
end