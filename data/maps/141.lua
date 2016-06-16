local map = ...
local game = map:get_game()

----------------------------------------------------
-- Outside N2 (Nabooru Wastelands) - Enemy Hoarde --
----------------------------------------------------

function map:on_started(destination)
  if not game:get_value("snapdragon_camp_crystal") then chest_crystal:set_enabled(false) end
end

for enemy in map:get_entities("snapdragon") do
  enemy.on_dead = function()
    if not map:has_entities("snapdragon") and not game:get_value("snapdragon_camp_crystal") then
      chest_cystal:set_enabled(true)
      sol.audio.play_sound("chest_appears")
    end
  end
end