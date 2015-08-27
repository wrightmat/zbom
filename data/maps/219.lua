local map = ...
local game = map:get_game()

----------------------------------------------
-- Dungeon 8: Interloper Sanctum (Basement) --
----------------------------------------------

function map:on_started(destination)
   game:set_value("dungeon_8_room_b25_lit")
end

for enemy in map:get_entities("room_1") do
  enemy.on_dead = function()
    if not map:has_entities("room_1") and not game:get_value("dungeon_8_room_b1_lit") then
      sol.audio.play_sound("lamp")
      game:set_value("dungeon_8_room_b1_lit")
    end
  end
end

for enemy in map:get_entities("room_12") do
  enemy.on_dead = function()
    if not map:has_entities("room_12") and not game:get_value("dungeon_8_room_b12_lit") then
      sol.audio.play_sound("lamp")
      game:set_value("dungeon_8_room_b12_lit")
    end
  end
end

for enemy in map:get_entities("room_14") do
  enemy.on_dead = function()
    if not map:has_entities("room_14") and not game:get_value("dungeon_8_room_b14_lit") then
      sol.audio.play_sound("lamp")
      game:set_value("dungeon_8_room_b14_lit")
    end
  end
end