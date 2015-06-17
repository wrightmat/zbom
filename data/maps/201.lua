local map = ...
local game = map:get_game()

------------------------------
-- Dungeon 1: Eastern Ruins --
------------------------------

function map:on_started(destination)
  if miniboss_knight ~= nil then miniboss_knight:set_enabled(false) end
  if boss_carock ~= nil then boss_carock:set_enabled(false) end
  if game:get_value("b1049") then
    map:open_doors("door_room1")
  end
  if not game:get_value("b1035") then boss_heart:set_enabled(false) end
  if game:get_value("b1050") then map:open_doors("door_miniboss") end
  if game:get_value("b1046") then map:open_doors("door_boss") end
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
    map:close_doors("door_key3")
    map:close_doors("door_miniboss")
    miniboss_knight:set_enabled(true)
    sol.audio.play_music("miniboss")
  end
end

function sensor_boss:on_activated()
  if boss_carock ~= nil and not game:get_value("b1046") then
    map:close_doors("door_boss")
    boss_carock:set_enabled(true)
    sol.audio.play_music("boss")
  end
end

if miniboss_knight ~= nil then
 function miniboss_knight:on_dead()
  map:open_doors("door_key3")
  map:open_doors("door_miniboss")
  sol.audio.play_music("sewers")
 end
end

if boss_carock ~= nil then
 function boss_carock:on_removed()
  game:set_value("b1046", true)
  map:open_doors("door_boss")
  if boss_heart ~= nil then boss_heart:set_enabled(true) end
  sol.audio.play_music("sewers")
 end
end

function map:on_obtained_treasure(item, variant, savegame_variable)
  if item:get_name() == "book_mudora" then
    game:set_dungeon_finished(1)
  end
end