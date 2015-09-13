local map = ...
local game = map:get_game()
local anouki_talk = 0

-----------------------------------------------
-- Outside World B6 (Snowpeak) - Snow drifts --
-----------------------------------------------

local function random_walk(npc)
  local m = sol.movement.create("random_path")
  m:set_speed(32)
  m:start(npc)
  npc:get_sprite():set_animation("walking")
end

function map:on_started(destination)
  random_walk(npc_anouki_1)
end

function npc_anouki_1:on_interaction()
  game:set_dialog_style("default")
  game:start_dialog("anouki_1."..anouki_talk..".snowpeak")
  if anouki_talk == 0 then anouki_talk = 1 else anouki_talk = 0 end
end

function sensor_snow_drift_1:on_activated()
  x, y, l = map:get_hero():get_position()
  map:get_hero():set_position(x, y, 1)
end

function sensor_snow_drift_2:on_activated()
  x, y, l = map:get_hero():get_position()
  map:get_hero():set_position(x, y, 0)
end

function ocarina_wind_to_B1:on_interaction()
  game:set_dialog_style("default")
  -- if this point not previously discovered
  -- then add it, otherwise do nothing
  if not game:get_value("b1508") then
    game:start_dialog("warp.new_point", function()
      game:set_value("b1508", true)
    end)
  else
    -- if other paired point is discovered (and they have the Ocarina),
    -- then ask the player if they want to warp there!
   if game:has_item("ocarina") then
    if game:get_value("b1509") then
      game:start_dialog("warp.to_B1", function(answer)
        if answer == 1 then
          sol.audio.play_sound("ocarina_wind")
          map:get_entity("hero"):teleport(88, "ocarina_warp", "fade")
        end
      end)
    else
      game:start_dialog("warp.interaction")
    end
   end
  end
end