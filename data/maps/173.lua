local map = ...
local game = map:get_game()

-------------------------------------------
-- Midoro Palace - Mini Dungeon (Shovel) --
-------------------------------------------

function map:on_started(destination)

end

for enemy in map:get_entities("octolux") do
  enemy.on_dead = function()
    if not map:has_entities("octolux") then
      sol.audio.play_sound("secret")
      -- Drain swamp water to expose spoils chest.
      map:set_entities_enabled("swamp_drain", true)
      swamp_water_1:get_sprite():fade_out(100, function() swamp_water_2:set_enabled(false) end)
      barrier:set_enabled(false)
    end
  end
end