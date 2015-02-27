local map = ...
local game = map:get_game()

---------------------------------------------
-- Dungeon 7: Tower of the Winds (Floor 2) --
---------------------------------------------

function map:on_started(destination)

end

for enemy in map:get_entities("keese") do
  enemy.on_dead = function()
    if not map:has_entities("keese") then
      door_shutter:set_open(true)
    end
  end
end
