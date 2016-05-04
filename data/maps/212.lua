local map = ...
local game = map:get_game()

---------------------------------------------
-- Dungeon 7: Tower of the Winds (Floor 3) --
---------------------------------------------

function map:on_started(destination)
  if not game:get_value("b1162") then chest_big_key:set_enabled(false) end
end

function switch_puzzle_1:on_activated()
  map:set_entities_enabled("barrier", false)
end

function switch_puzzle_2:on_activated()
  map:open_doors("door_shutter")
end

for enemy in map:get_entities("dodongo") do
  enemy.on_dead = function()
    if not map:has_entities("dodongo") and not map:has_entities("tektite") and not game:get_value("b1162") then
      chest_big_key:set_enabled(true)
      sol.audio.play_sound("chest_appears")
    end
  end
end
for enemy in map:get_entities("tektite") do
  enemy.on_dead = function()
    if not map:has_entities("dodongo") and not map:has_entities("tektite") and not game:get_value("b1162") then
      chest_big_key:set_enabled(true)
      sol.audio.play_sound("chest_appears")
    end
  end
end
