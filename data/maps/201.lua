local map = ...
local game = map:get_game()

------------------------------
-- Dungeon 1: Eastern Ruins --
------------------------------

function map:on_started(destination)
  miniboss_knight:set_enabled(false)
  boss_carock:set_enabled(false)
  if game:get_value("b1049") then
    map:open_doors("door_room1")
  end
end

for enemy in map:get_entities("room3_helmasaur") do
  enemy.on_dead = function()
    if not map:has_entities("room3_helmasaur") then
      map:open_doors("door_room1")
      game:set_value("b1049", true)
    end
  end
end

function sensor_miniboss:on_activated()
  if miniboss_knight ~= nil then
    door_key3_2:set_sprite("door_shutter")
    map:close_doors("door_boss")
    miniboss_knight:set_enabled(true)
    sol.audio.play_music("miniboss")
  end
end

function sensor_boss:on_activated()
  if boss_carock ~= nil then
    map:close_doors("door_boss")
    boss_carock:set_enabled(true)
    sol.audio.play_music("boss")
  end
end

if boss_carock ~= nil then
 function boss_carock:on_dead()
  map:open_doors("door_boss")
  map:open_doors("door_boss")
  sol.audio.play_sound("boss_killed")
  boss_heart:set_enabled(true)
  sol.audio.play_music("sewers")
 end
end

function map:on_obtained_treasure(treasure_item, treasure_variant, treasure_savegame_variable)
  if treasure_name == book_mudora and treasure_variant == 6 then
    game:set_dungeon_finished(1)
  end
end
