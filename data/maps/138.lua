local map = ...
local game = map:get_game()

-----------------------------------------------------------------
-- Outside World M5 (Ancient Library) - Library, Ordona Speaks --
-----------------------------------------------------------------

function map:on_started(destination)
  if game:get_value("i1032") == 1 then
    sol.timer.start(1500, function()
      torch_ordona:get_sprite():set_animation("lit")
    end)
    sol.timer.start(2000, function()
      hero:freeze()
      torch_overlay = sol.surface.create("entities/dark.png")
      torch_overlay:fade_in(50)
      game:start_dialog("ordona.2.library", game:get_player_name(), function()
        torch_overlay:fade_out(50)
        sol.timer.start(2000, function()
          torch_overlay = nil
          torch_ordona:get_sprite():set_animation("unlit")
        end)
        hero:unfreeze()
        game:add_max_stamina(100)
        game:set_stamina(game:get_max_stamina())
        game:set_value("i1032", 2)
      end)
    end)
  elseif game:get_value("i1032") >= 2 then
    door:set_enabled(false)
  end
end

if game:get_time_of_day() ~= "night" then
function game:on_map_changed(map)
  function map:on_draw(dst_surface)
    if map:get_id() == "138" and torch_overlay then
      local screen_width, screen_height = dst_surface:get_size()
      local cx, cy = map:get_camera_position()
      local tx, ty = torch_ordona:get_center_position()
      local x = 320 - tx + cx
      local y = 240 - ty + cy
      torch_overlay:draw_region(x, y, screen_width, screen_height, dst_surface)
    end
  end
end
end