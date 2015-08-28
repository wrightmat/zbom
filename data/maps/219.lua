local map = ...
local game = map:get_game()
local room9_1, room9_2, room9_3 = false

----------------------------------------------
-- Dungeon 8: Interloper Sanctum (Basement) --
----------------------------------------------

function map:on_started(destination)
   game:set_value("dungeon_8_room25_lit")
end

for enemy in map:get_entities("room_1") do
  enemy.on_dead = function()
    if not map:has_entities("room_1") and not game:get_value("dungeon_8_room1_lit") then
      sol.audio.play_sound("lamp")
      game:set_value("dungeon_8_room_b1_lit")
    end
  end
end

function room9_switch_1:on_activated()
  room9_pit_2:set_enabled(false)
  room9_pit_4:set_enabled(false)
  room9_1 = true
  if room9_1 and room9_2 and room9_3 then game:set_value("dungeon_8_room9_lit") end
end
function room9_switch_2:on_activated()
  room9_pit_1:set_enabled(false)
  room9_2 = true
  if room9_1 and room9_2 and room9_3 then game:set_value("dungeon_8_room9_lit") end
end
function room9_switch_3:on_activated()
  room9_pit_3:set_enabled(false)
  room9_3 = true
  if room9_1 and room9_2 and room9_3 then game:set_value("dungeon_8_room9_lit") end
end

for enemy in map:get_entities("room_12") do
  enemy.on_dead = function()
    if not map:has_entities("room_12") and not game:get_value("dungeon_8_room12_lit") then
      sol.audio.play_sound("lamp")
      game:set_value("dungeon_8_room_b12_lit")
    end
  end
end

for enemy in map:get_entities("room_14") do
  enemy.on_dead = function()
    if not map:has_entities("room_14") and not game:get_value("dungeon_8_room14_lit") then
      sol.audio.play_sound("lamp")
      game:set_value("dungeon_8_room_b14_lit")
    end
  end
end

function map:on_update()
  if game:get_value("dungeon_8_room9_lit") then
    room9_gate_e1:set_enabled(false)
    room9_gate_e2:set_enabled(false)
    room12_gate_w1:set_enabled(false)
    room12_gate_w2:set_enabled(false)
  end
end