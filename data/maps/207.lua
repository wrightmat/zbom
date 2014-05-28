local map = ...
local game = map:get_game()

----------------------------------------
-- Dungeon 5: Lakebed Lair (Basement) --
----------------------------------------

function map:on_started(destination)
  if not game:get_value("b1125") then chest_key_5:set_enabled(false) end
  map:set_doors_open("boss_shutter")
  map:set_doors_open("shutter_2")
  if not game:get_value("b1140") then map:set_entities_enabled("water_stream_chest", false) end
end

function door_bomb_1:on_opened()
  water_source_1:fade_out(50)
  water_source_1:set_enabled(false)
  water_source_2:set_enabled(false)
  map:set_entities_enabled("water_stream", false)
  sol.audio.play_sound("secret")
end

function sensor_open_shutter_1:on_activated()
  map:open_doors("shutter_1")
end
function sensor_close_shutter_1:on_activated()
  map:close_doors("shutter_1")
end

function sensor_close_shutter_2:on_activated()
  map:close_doors("shutter_2")
end

function sensor_open_shutter_3:on_activated()
  map:open_doors("shutter_3")
end
function sensor_close_shutter_3:on_activated()
  map:close_doors("shutter_3")
end

function switch_water_chest:on_activated()
  game:set_value("b1140", true)
  map:set_entities_enabled("water_stream_chest", true)
end

for enemy in map:get_entities("aquadracini") do
  enemy.on_dead = function()
    if not map:has_entities("aquadracini") then
      chest_key_5:set_enabled(true)
      sol.audio.play_sound("chest_appears")
    end
  end
end

for enemy in map:get_entities("chuchu") do
  enemy.on_dead = function()
    if not map:has_entities("chuchu") then
      map:open_doors("shutter_2")
    end
  end
end
