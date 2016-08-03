local map = ...
local game = map:get_game()

-----------------------------------------------------------------
-- Outside D1 (Zola Settlement/Northern Waters) - Enemy Hoarde --
-----------------------------------------------------------------

function map:on_started(destination)
  if not game:get_value("knight_camp_crystal") then chest_crystal:set_enabled(false) end
end

for enemy in map:get_entities("knight") do
  enemy.on_dead = function()
    if not map:has_entities("knight") and not game:get_value("knight_camp_crystal") then
      chest_crystal:set_enabled(true)
      sol.audio.play_sound("chest_appears")
    end
  end
end