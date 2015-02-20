local map = ...
local game = map:get_game()

------------------------------
-- Dungeon 1: Eastern Ruins --
------------------------------

function map:on_started(destination)
  miniboss_knight:set_enabled(false)
  boss_carock:set_enabled(false)
end

for enemy in map:get_entities("room3_helmasaur") do
  enemy.on_dead = function()
    if not map:has_entities("room3_helmasaur") then
      door_room1_1:set_open()
      door_room1_2:set_open()
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
