local map = ...
local game = map:get_game()

----------------------------
-- Outside H3 (Mido Town) --
----------------------------

function map:on_started(destination)
  -- Activate any night-specific dynamic tiles.
  if game:get_time_of_day() == "night" then
    for entity in game:get_map():get_entities("night_") do
      entity:set_enabled(true)
    end
  end

  -- Entrances of houses.
  local entrance_names = { "church" }
  for _, entrance_name in ipairs(entrance_names) do
    local sensor = map:get_entity(entrance_name .. "_door_sensor")
    local tile = map:get_entity(entrance_name .. "_door")
    sensor.on_activated_repeat = function()
      if hero:get_direction() == 1 and tile:is_enabled() then
        sol.audio.play_sound("door_open")
        tile:set_enabled(false)
      end
    end
  end
end

function soldier_1:on_interaction()
  game:start_dialog("mido_soldier.0." .. math.random(2))
end
function soldier_2:on_interaction()
  game:start_dialog("mido_soldier.0." .. math.random(2))
end
function soldier_3:on_interaction()
  game:start_dialog("mido_soldier.0." .. math.random(2))
end
function soldier_4:on_interaction()
  game:start_dialog("mido_soldier.0." .. math.random(2))
end