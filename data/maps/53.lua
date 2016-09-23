local map = ...
local game = map:get_game()

----------------------------------------------
-- Outside World C5 (Snowpeak/Caverns Entr) --
----------------------------------------------

local anouki_talk = 0

local function random_walk(npc)
  local m = sol.movement.create("random_path")
  m:set_speed(32)
  m:start(npc)
  npc:get_sprite():set_animation("walking")
end

function map:on_started(destination)
  if game:get_time_of_day() == "night" then
    npc_anouki_3:remove()
  else
    random_walk(npc_anouki_3)
  end

  if game:get_value("b1150") and game:get_value("i1910") < 6 then
    torch_1:get_sprite():set_animation("lit")
    sol.timer.start(1000, function()
      hero:freeze()
      game:set_map_tone(32,64,128,255)
      game:start_dialog("ordona.6.snowpeak", game:get_player_name(), function()
        sol.timer.start(500, function()
          if game:get_time_of_day() ~= "night" then game:set_map_tone(255,255,255,255) end
        end)
        hero:unfreeze()
        game:add_max_stamina(100)
        game:set_stamina(game:get_max_stamina())
        torch_1:get_sprite():set_animation("unlit")
        game:set_value("i1910", 6)
      end)
    end)
  end

  -- Activate any night-specific dynamic tiles.
  if game:get_time_of_day() == "night" then
    for entity in game:get_map():get_entities("night_") do
      entity:set_enabled(true)
    end
  end
end

function npc_anouki_3:on_interaction()
  game:set_dialog_style("default")
  if not game:get_value("b1117") then
    -- If at least Mausoleum not completed, suggest going there instead.
    game:start_dialog("anouki_3.0.snowpeak", function()
      game:start_dialog("anouki_3.1.not_ready")
    end)
  else
    game:start_dialog("anouki_3."..anouki_talk..".snowpeak")
    if anouki_talk == 0 then anouki_talk = 1 else anouki_talk = 0 end
  end
end