local map = ...
local game = map:get_game()

----------------------------------------
-- Dungeon 5: Lakebed Lair (Basement) --
----------------------------------------

function map:on_started(destination)
  if not game:get_value("b1125") then chest_key_5:set_enabled(false) end
  map:set_doors_open("door_boss") -- shutter door
  map:set_doors_open("shutter_2")
  if not game:get_value("b1140") then map:set_entities_enabled("water_stream_chest", false) end
  if not game:get_value("b1131") then
    boss_plasmarine_blue:set_enabled(false)
    boss_plasmarine_red:set_enabled(false)
    to_outside:set_enabled(false)
  end
  if not game:get_value("b1134") then chest_book:set_enabled(false) end
  if not game:get_value("b1133") then boss_heart:set_enabled(false) end
  if game:get_value("b1141") then
    water_source_1:set_enabled(false)
    water_source_2:set_enabled(false)
    map:set_entities_enabled("water_stream", false)
    obstacle:set_enabled(false)
    obstacle_2:set_enabled(false)
  end
  stone:set_enabled(false)
end

function door_bomb_1:on_opened()
  water_source_1:set_enabled(false)
  water_source_2:set_enabled(false)
  map:set_entities_enabled("water_stream", false)
  sol.audio.play_sound("water_drain")
  game:set_value("b1141", true)
  obstacle:set_enabled(false)
  obstacle_2:set_enabled(false)
end

function sensor_boss:on_activated()
  if boss_plasmarine_blue ~= nil and boss_plasmarine_red ~= nil then
    map:close_doors("door_boss")
    boss_plasmarine_blue:set_enabled(true)
    boss_plasmarine_red:set_enabled(true)
    sol.audio.play_music("boss")
  end
end

if boss_plasmarine_blue ~= nil and boss_plasmarine_red ~= nil then
  function boss_plasmarine_blue:on_dead()
    if boss_plasmarine_red == nil then -- both Plasmarines have to be dead to win
      game:set_value("b1131", true)
      map:open_doors("door_boss")
      sol.audio.play_sound("boss_killed")
      if boss_heart ~= nil then boss_heart:set_enabled(true) end
      chest_book:set_enabled(true)
      sol.audio.play_sound("chest_appears")
      sol.audio.play_music("temple_lake")
      to_outside:set_enabled(true)
      map:open_doors("shutter_waterfall")
      sensor_close_shutter_waterfall:set_enabled(false)
    end
  end
  function boss_plasmarine_red:on_dead()
    if boss_plasmarine_blue == nil then -- both Plasmarines have to be dead to win
      game:set_value("b1131", true)
      map:open_doors("door_boss")
      sol.audio.play_sound("boss_killed")
      if boss_heart ~= nil then boss_heart:set_enabled(true) end
      chest_book:set_enabled(true)
      sol.audio.play_sound("chest_appears")
      sol.audio.play_music("temple_lake")
      to_outside:set_enabled(true)
      map:open_doors("shutter_waterfall")
      sensor_close_shutter_waterfall:set_enabled(false)
    end
  end
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

function sensor_open_shutter_waterfall:on_activated()
  if game:get_value("b1141") then
    map:open_doors("shutter_waterfall")
    obstacle:set_enabled(false)
    obstacle_2:set_enabled(false)
  else
    game:start_dialog("lakebed.waterfall")
  end
end
function sensor_close_shutter_waterfall:on_activated()
  map:close_doors("shutter_waterfall")
end

function switch_water_chest:on_activated()
  game:set_value("b1140", true)
  map:set_entities_enabled("water_stream_chest", true)
  sol.audio.play_sound("secret")
end

function switch_stone:on_activated()
  stone:set_enabled(true)
end
function switch_stone:on_inactivated()
  stone:set_enabled(false)
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

function map:on_obtained_treasure(item, variant, savegame_variable)
  if item:get_name() == "book_mudora" then
    game:set_dungeon_finished(5)
  end
end