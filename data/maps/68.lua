local map = ...
local game = map:get_game()

------------------------------------------------------
-- Outside World I6 (Death Mountain/Mausoleum Entr) --
------------------------------------------------------

local torch_overlay = nil

function map:on_started(destination)
  if game:get_value("i1029") == 5 then
    -- set ghost's position to hero and then follow
    -- (on intermediate layer so he doesn't collide)
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
  else
    npc_goron_ghost:remove()
  end
  if not game:get_value("b1110") then
    npc_dampeh:remove()
  else
    if game:get_value("i1910") < 4 then
      torch_1:get_sprite():set_animation("lit")
      sol.timer.start(1000, function()
        hero:freeze()
        torch_overlay = sol.surface.create("entities/dark.png")
        torch_overlay:fade_in(50)
        game:start_dialog("ordona.4.death_mountain", game:get_player_name(), function()
          torch_overlay:fade_out(50)
          sol.timer.start(2000, function() torch_overlay = nil end)
          hero:unfreeze()
	game:add_max_stamina(100)
	game:set_stamina(game:get_max_stamina())
	torch_1:get_sprite():set_animation("unlit")
          game:set_value("i1910", 4)
        end)
      end)
    end
  end
  if dialog_timer ~= nil then dialog_timer = nil end -- shut the ghost up :)
end

function map:on_draw(dst_surface)
  -- Show torch overlay for Ordona dialog
  if game:get_time_of_day() ~= "night" and torch_overlay ~= nil then
    local screen_width, screen_height = dst_surface:get_size()
    local cx, cy = map:get_camera_position()
    local tx, ty = torch_1:get_center_position()
    local x = 320 - tx + cx
    local y = 240 - ty + cy
    torch_overlay:draw_region(x, y, screen_width, screen_height, dst_surface)
  end
end

function npc_dampeh:on_interaction()
  game:start_dialog("dampeh.2.mausoleum")
end