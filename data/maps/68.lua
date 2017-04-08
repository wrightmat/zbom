local map = ...
local game = map:get_game()

------------------------------------------------------
-- Outside World I6 (Death Mountain/Mausoleum Entr) --
------------------------------------------------------

function map:on_started(destination)
  if game:get_value("i1029") == 5 then
    -- Set ghost's position to hero and then follow
    -- (on intermediate layer so he doesn't collide).
    hx, hy, hl = map:get_entity("hero"):get_position()
    if map:get_entity("hero"):get_direction() == 0 or map:get_entity("hero"):get_direction() == 3 then
      npc_goron_ghost:set_position(hx+16, hy+16, 1)
    elseif map:get_entity("hero"):get_direction() == 1 or map:get_entity("hero"):get_direction() == 2 then
      npc_goron_ghost:set_position(hx-16, hy-16, 1)
    end
    sol.audio.play_sound("ghost")
    local m = sol.movement.create("target")
    m:set_speed(32)
    m:start(npc_goron_ghost)
  else npc_goron_ghost:remove() end
  
  if not game:get_value("b1110") then npc_dampeh:remove() else
    if game:get_value("i1910") < 4 then
      torch_1:get_sprite():set_animation("lit")
      sol.timer.start(1000, function()
        hero:freeze()
        if game:get_time_of_day() ~= "night" then
          local previous_tone = game:get_map_tone()
          game:set_map_tone(32,64,128,255)
        end
        game:start_dialog("ordona.4.death_mountain", game:get_player_name(), function()
          sol.timer.start(500, function()
            if game:get_time_of_day() ~= "night" then game:set_map_tone(previous_tone) end
          end)
          hero:unfreeze()
          game:add_max_stamina(100)
          game:set_stamina(game:get_max_stamina())
          torch_1:get_sprite():set_animation("unlit")
          game:set_value("i1910", 4)
        end)
      end)
    end
  end
  if dialog_timer ~= nil then dialog_timer = nil end -- Shut the ghost up :)
end

npc_dampeh:register_event("on_interaction", function()
  game:set_dialog_style("default")
  game:start_dialog("dampeh.2.mausoleum")
end)