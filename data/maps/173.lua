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
  flying_heart:get_sprite():set_animation("heart")
  flying_heart_2:get_sprite():set_animation("heart")
end

function flying_heart:on_obtained()
  self:get_game():add_life(4); self:get_game():add_stamina(8)
end
function flying_heart_2:on_obtained()
  self:get_game():add_life(4); self:get_game():add_stamina(8)
end

function switch_1:on_activated()
  map:move_camera(232, 568, 250, function()
    map:open_doors("door_shutter")
    game:set_value("b1222", true)
  end, 500, 500)
end

function switch_2:on_activated()
  sol.audio.play_sound("secret")
  map:move_camera(112, 824, 250, function()
    -- Drain swamp water to expose spoils chest.
    map:set_entities_enabled("swamp_drain", true)
    barrier:set_enabled(false)
    swamp_water_1:set_enabled(false)
    sol.timer.start(map, 1000, function() map:set_entities_enabled("swamp_drain", false) end)
    sol.timer.start(map, 60000, function() map:revert_swamp_water() end)  -- Water comes back after 60 seconds.
  end, 500, 500)
end

function map:revert_swamp_water()
  -- Replace drained water
  map:move_camera(112, 824, 350, function()
    map:set_entities_enabled("swamp_drain", true)
    barrier:set_enabled(true)
    swamp_water_1:set_enabled(true)
    sol.timer.start(map, 1000, function() map:set_entities_enabled("swamp_drain", false) end)
  end, 500, 500)
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