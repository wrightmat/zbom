local map = ...
local game = map:get_game()

------------------------------
-- Dungeon 1: Eastern Ruins --
------------------------------

function map:on_started(destination)
  game:set_value("b1034", false)
  game:set_value("b1046", false)
  if miniboss_knight ~= nil then miniboss_knight:set_enabled(false) end
  if boss_carock ~= nil then boss_carock:set_enabled(false) end
  if game:get_value("b1049") then map:open_doors("door_room1") end
  if not game:get_value("b1035") then boss_heart:set_enabled(false) end
  if game:get_value("b1050") then map:open_doors("door_miniboss") end
  if game:get_value("b1787") then chest_treasure:set_enabled(false) end
  if game:get_value("b1195") or game:get_value("i1808") > 0 then chest_big:set_open(true) end
end

function map:on_update()
  if torch_chest:get_sprite():get_animation() == "lit" then
    chest_treasure:set_enabled(true)
  else
    chest_treasure:set_enabled(false)
  end
end

for enemy in map:get_entities("helmasaur") do
  enemy.on_dead = function()
    if not map:has_entities("helmasaur_room4") then
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

if miniboss_knight ~= nil then
 function miniboss_knight:on_dead()
  map:open_doors("door_key3")
  map:open_doors("door_miniboss")
  sol.audio.play_music("sewers")
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
 function boss_carock:on_removed()
  game:set_value("b1046", true)
  map:open_doors("door_boss")
  if boss_heart ~= nil then boss_heart:set_enabled(true) end
  sol.audio.play_music("sewers")
 end
end

function chest_big:on_opened(item, variant, savegame_variable)
  -- If hero already has the basic boomerang (from Great Fairy),
  -- give the upgraded version instead.
  if game:get_value("i1808") >= 1 then
    map:get_hero():start_treasure("boomerang", 2)
  else
    map:get_hero():start_treasure("boomerang", 1)
  end
end

function chest_book:on_opened(item, variant, savegame_variable)
  -- Dynamically determine book variant to give, since dungeons can be done in any order.
  local book_variant = game:get_item("book_mudora"):get_variant() + 1
  map:get_hero():start_treasure("book_mudora", book_variant)
  game:set_dungeon_finished(1)
  game:set_value("b1033", true) -- This value varies depending on the dungeon (chest save value)
end