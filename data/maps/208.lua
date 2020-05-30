local map = ...
local game = map:get_game()

-------------------------------------------
-- Dungeon 5: Snowpeak Caverns (Floor 1) --
-------------------------------------------

map:register_event("on_started", function(self, destination)
  flying_heart:get_sprite():set_animation("heart")
  flying_apple:get_sprite():set_animation("apple")
  map:set_doors_open("door_miniboss")
  if miniboss_chu ~= nil then miniboss_chu:set_enabled(false) end
  if not game:get_value("b1144") then chest_big_key:set_enabled(false) end
  if not game:get_value("b1151") then chest_key_1:set_enabled(false) end
end)

function sensor_miniboss:on_activated()
  if miniboss_chu ~= nil then
    map:close_doors("door_miniboss")
    miniboss_chu:set_enabled(true)
    sol.audio.play_music("miniboss")
  end
end

if miniboss_chu ~= nil then
  function miniboss_chu:on_dead()
    map:open_doors("door_miniboss")
    sol.audio.play_sound("boss_killed")
    sol.timer.start(1000, function()
      sol.audio.play_music("temple_snow")
      chest_big_key:set_enabled(true)
      sol.audio.play_sound("chest_appears")
    end)
  end
end

for enemy in map:get_entities("room5_enemy") do
  enemy.on_dead = function()
    if not map:has_entities("room5_enemy") and not game:get_value("b1151") then
      chest_key_1:set_enabled(true)
      sol.audio.play_sound("chest_appears")
    end
  end
end

function room9_door:on_activated()
  if not switch_ice_block_2:is_activated() then
    map:close_doors("door_shutter9")
  end
end
function room9_door_2:on_activated()
  map:open_doors("door_shutter9")
end

function switch_ice_block:on_activated()
  map:open_doors("door_shutter1")
end

function switch_ice_block_2:on_activated()
  map:open_doors("door_shutter9")
end