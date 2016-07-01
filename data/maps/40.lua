local map = ...
local game = map:get_game()

-------------------------------------------
-- Outside World F9 (Hyrule Castle Town) --
-------------------------------------------

function map:on_started(destination)
  -- Opening doors
  local entrance_names = { "office", "collector" }
  for _, entrance_name in ipairs(entrance_names) do
    local sensor = map:get_entity(entrance_name .. "_door_sensor")
    local tile = map:get_entity(entrance_name .. "_door")
    sensor.on_activated_repeat = function()
      if hero:get_direction() == 1 and tile:is_enabled() then
        if entrance_name == "office" and game:get_time_of_day() == "day" then
          tile:set_enabled(false)
          sol.audio.play_sound("door_open")
        elseif entrance_name == "collector" then
          tile:set_enabled(false)
          sol.audio.play_sound("door_open")
        end
      end
    end
  end
  -- Activate any night-specific dynamic tiles/entities.
  if game:get_time_of_day() == "night" then
    for entity in map:get_entities("night_") do
      entity:set_enabled(true)
    end
    butterfly_1:remove()
    butterfly_2:remove()
    door_1:set_enabled(true)
    door_2:set_enabled(true)
    door_3:set_enabled(true)
    door_4:set_enabled(true)
  else
    moth_1:remove()
    moth_2:remove()
  end
end

function ocarina_wind_to_north:on_interaction()
  game:set_dialog_style("default")
  if game:has_item("ocarina") then
    game:start_dialog("warp.to_51", function(answer)
      if answer == 1 then
        map:get_hero():set_animation("ocarina")
        sol.audio.play_sound("ocarina_wind")
        map:get_entity("hero"):teleport(51, "ocarina_warp", "fade")
      end
    end)
  end
end
function ocarina_wind_to_east:on_interaction()
  game:set_dialog_style("default")
  if game:has_item("ocarina") then
    game:start_dialog("warp.to_66", function(answer)
      if answer == 1 then
        map:get_hero():set_animation("ocarina")
        sol.audio.play_sound("ocarina_wind")
        map:get_entity("hero"):teleport(66, "ocarina_warp", "fade")
      end
    end)
  end
end
function ocarina_wind_to_south:on_interaction()
  game:set_dialog_style("default")
  if game:has_item("ocarina") then
    game:start_dialog("warp.to_11", function(answer)
      if answer == 1 then
        map:get_hero():set_animation("ocarina")
        sol.audio.play_sound("ocarina_wind")
        map:get_entity("hero"):teleport(11, "ocarina_warp", "fade")
      end
    end)
  end
end
function ocarina_wind_to_west:on_interaction()
  game:set_dialog_style("default")
  if game:has_item("ocarina") then
    game:start_dialog("warp.to_72", function(answer)
      if answer == 1 then
        map:get_hero():set_animation("ocarina")
        sol.audio.play_sound("ocarina_wind")
        map:get_entity("hero"):teleport(72, "ocarina_warp", "fade")
      end
    end)
  end
end