local map = ...
local game = map:get_game()

---------------------------------------------
-- Dungeon 7: Tower of the Winds (Floor 4) --
---------------------------------------------

map:register_event("on_started", function(self, destination)
  game:set_world_rain_mode("dungeon_7", "rain")
  if not game:get_value("b1160") then chest_compass:set_enabled(false) end
  if not game:get_value("b1171") then chest_key_1:set_enabled(false) end
  if game:get_value("b1164") then
    map:open_doors("door_shutter")
    map:remove_entities("keese")
  end
end)

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
    if not map:has_entities("geldman") and not map:has_entities("armos") and not game:get_value("b1171") then
      chest_compass:set_enabled(true)
      sol.audio.play_sound("chest_appears")
    end
  end
end
for enemy in map:get_entities("armos") do
  enemy.on_dead = function()
    if not map:has_entities("geldman") and not map:has_entities("armos") and not game:get_value("b1171") then
      chest_compass:set_enabled(true)
      sol.audio.play_sound("chest_appears")
    end
  end
end

for enemy in map:get_entities("gibdos") do
  enemy.on_dead = function()
    if not map:has_entities("gibdos") and not map:has_entities("giga") then
      map:move_camera(552, 125, 250, function()
        chest_key_1:set_enabled(true)
        sol.audio.play_sound("chest_appears")
      end, 500, 500)
    end
  end
end
for enemy in map:get_entities("giga") do
  enemy.on_dead = function()
    if not map:has_entities("gibdos") and not map:has_entities("giga") then
      map:move_camera(552, 125, 250, function()
        chest_key_1:set_enabled(true)
        sol.audio.play_sound("chest_appears")
      end, 500, 500)
    end
  end
end