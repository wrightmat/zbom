local map = ...
local game = map:get_game()

-----------------------------------------------------------------
-- Outside D1 (Zola Settlement/Northern Waters) - Enemy Hoarde --
-----------------------------------------------------------------

function map:on_started(destination)
  if not game:get_value("zola_camp_crystal") then chest_crystal:set_enabled(false) end
end

for enemy in map:get_entities("zola") do
  enemy.on_dead = function()
    if not map:has_entities("zola") and not game:get_value("zola_camp_crystal") then
      chest_crystal:set_enabled(true)
      sol.audio.play_sound("chest_appears")
    end
  end
end