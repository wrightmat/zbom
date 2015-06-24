local map = ...
local game = map:get_game()

--------------------------------------------------------------------
-- Outside World B7 (Desert/Pyramid Entrance) - Abandoned Pyramid --
--------------------------------------------------------------------

function map:on_started(destination)
  -- If you haven't gotten all of the parts, Ordona directs you back
  if destination == from_pyramid then
    if not game:get_value("b1087") or not game:get_value("b1088") or not game:get_value("b1089") then
      sol.timer.start(1000, function()
        torch_1:get_sprite():set_animation("lit")
      end)
      sol.timer.start(1000, function()
        hero:freeze()
        torch_overlay = sol.surface.create("entities/dark.png")
        torch_overlay:fade_in(50)
        hero:set_direction(2)
        game:start_dialog("ordona.1.pyramid", game:get_player_name(), function()
          torch_overlay:fade_out(50)
          hero:unfreeze()
	  game:set_stamina(game:get_max_stamina())
            sol.timer.start(2000, function()
              torch_1:get_sprite():set_animation("unlit")
            end)
        end)
      end)
    end
  end
end

if game:get_time_of_day() ~= "night" then
function game:on_map_changed(map)
  function map:on_draw(dst_surface)
    if map:get_id() == "11" and torch_overlay then
      local screen_width, screen_height = dst_surface:get_size()
      local cx, cy = map:get_camera_position()
      local tx, ty = torch_1:get_center_position()
      local x = 320 - tx + cx
      local y = 240 - ty + cy
      torch_overlay:draw_region(x, y, screen_width, screen_height, dst_surface)
    end
  end
end
end