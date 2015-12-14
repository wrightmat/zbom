local map = ...
local game = map:get_game()

-------------------------------------------
-- Midoro Palace - Mini Dungeon (Shovel) --
-------------------------------------------

function map:on_started(destination)
  map:get_entity("torch_1"):get_sprite():set_animation("lit")
  map:get_entity("torch_2"):get_sprite():set_animation("lit")
  map:get_entity("torch_3"):get_sprite():set_animation("lit")
  map:get_entity("torch_4"):get_sprite():set_animation("lit")
end

function switch_1:on_activated()
  map:open_doors("door_shutter")
  game:set_value("b1222", true)
end

function switch_2:on_activated()
  sol.audio.play_sound("secret")
  -- Drain swamp water to expose spoils chest.
  map:set_entities_enabled("swamp_drain", true)
  swamp_water_1:fade_out(100, function()
    barrier:set_enabled(false)
    swamp_water_1:set_enabled(false)
    sol.timer.start(map, 1000, function() map:set_entities_enabled("swamp_drain", false) end)
    sol.timer.start(map, 20000, function() map:revert_swamp_water() end)  -- Water comes back after 20 seconds.
  end)
end

function map:revert_swamp_water()
  -- Drain swamp water to expose spoils chest.
  map:set_entities_enabled("swamp_drain", true)
  swamp_water_1:get_sprite():fade_in(100, function()
    barrier:set_enabled(true)
    swamp_water_1:set_enabled(true)
    sol.timer.start(map, 1000, function() map:set_entities_enabled("swamp_drain", false) end)
  end)
end

for enemy in map:get_entities("flower") do
  enemy.on_dead = function()
    if not map:has_entities("flower") then
      sol.audio.play_sound("secret")
      map:create_pickable({ x = 664, y = 741, layer = 0, treasure = "rupee", treasure_variant = 4 })
    end
  end
end

function sensor_temp:on_activated()
  map:open_doors("door_shutter")
  game:set_value("b1222", true)
end