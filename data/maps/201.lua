local map = ...
local game = map:get_game()

------------------------------
-- Dungeon 1: Eastern Ruins --
------------------------------

function map:on_started(destination)
  miniboss_knight:set_enabled(false)
  boss_carock:set_enabled(false)
end

for enemy in map:get_entities("helmasaur_red") do
  enemy.on_dead = function()
    if not map:has_entities("room3_helmasaur") then
      door_room1_shutter:set_open()
    end
  end
end
