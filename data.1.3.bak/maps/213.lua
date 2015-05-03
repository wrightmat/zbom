local map = ...
local game = map:get_game()

---------------------------------------------
-- Dungeon 7: Tower of the Winds (Floor 4) --
---------------------------------------------

function map:on_started(destination)
  if not game:get_value("b1160") then chest_compass:set_enabled(false) end
  if not game:get_value("b1171") then chest_key_1:set_enabled(false) end
  if game:get_value("b1164") then
    map:open_doors("door_shutter")
    map:remove_entities("keese")
  end
end

for enemy in map:get_entities("keese") do
  enemy.on_dead = function()
    if not map:has_entities("keese") then
      map:open_doors("door_shutter")
      game:set_value("b1164", true)
    end
  end
end

for enemy in map:get_entities("geldman") do
  enemy.on_dead = function()
    if not map:has_entities("geldman") and not map:has_entities("armos") then
      chest_compass:set_enabled(true)
    end
  end
end
for enemy in map:get_entities("armos") do
  enemy.on_dead = function()
    if not map:has_entities("geldman") and not map:has_entities("armos") then
      chest_compass:set_enabled(true)
    end
  end
end

for enemy in map:get_entities("gibdos") do
  enemy.on_dead = function()
    if not map:has_entities("gibdos") and not map:has_entities("giga") then
      chest_key_1:set_enabled(true)
    end
  end
end
for enemy in map:get_entities("giga") do
  enemy.on_dead = function()
    if not map:has_entities("gibdos") and not map:has_entities("giga") then
      chest_key_1:set_enabled(true)
    end
  end
end
