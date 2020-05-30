local map = ...
local game = map:get_game()

---------------------------------------------
-- Dungeon 7: Tower of the Winds (Floor 5) --
---------------------------------------------

map:register_event("on_started", function(self, destination)
  game:set_world_rain_mode("dungeon_7", "rain")
  if not game:get_value("b1173") then chest_key_2:set_enabled(false) end
  warp_chuchu:set_enabled(false)
  warp_item:set_enabled(false)
end)

function warp:on_activated()
  local hero = map:get_entity("hero")
  if hero:get_direction() == 0 then -- East
    warp:set_destination_name("destination_3")
  elseif hero:get_direction() == 3 then -- South
    warp:set_destination_name("destination_2")
  elseif hero:get_direction() == 2 then -- West
    warp:set_destination_name("destination_1")
  end
end

function switch_1:on_activated()
  hole_1:remove()
end
function switch_2:on_activated()
  hole_2:remove()
  hole_4:remove()
end
function switch_3:on_activated()
  hole_3:remove()
end

function switch_chest:on_activated()
  chest_key_2:set_enabled(true)
  sol.audio.play_sound("chest_appears")
end

for enemy in map:get_entities("chuchu") do
  enemy.on_dead = function()
    if not map:has_entities("chuchu") then
      warp_chuchu:set_enabled(true)
      sol.audio.play_sound("secret")
    end
  end
end

function map:on_obtained_treasure(treasure_name, treasure_variant, treasure_savegame_variable)
  if treasure_name == "shield" then
    warp_item:set_enabled(true)
  end
end