local map = ...
local game = map:get_game()

-----------------------------------------------------------------
-- Outside World M5 (Ancient Library) - Library, Ordona Speaks --
-----------------------------------------------------------------

function map:on_started(destination)
  if game:get_value("i1032") == 1 then
    torch_ordona:get_sprite():set_animation("lit")
    sol.timer.start(4000, function()
      hero:freeze()
      torch_overlay = sol.surface.create("entities/dark.png")
      torch_overlay:fade_in(50)
      game:start_dialog("ordona.2.library", game:get_player_name(), function()
        torch_overlay:fade_out(50)
        hero:unfreeze()
        game:set_value("i1032", 2)
      end)
    end)
  end
end

function game:on_map_changed(map)
  function map:on_draw(dst_surface)
    if map:get_id() == "11" and torch_overlay then
      local torch = map:get_entity("torch_1")
      local screen_width, screen_height = dst_surface:get_size()
      local cx, cy = map:get_camera_position()
      local tx, ty = torch:get_center_position()
      local x = 320 - tx + cx
      local y = 240 - ty + cy
      torch_overlay:draw_region(x, y, screen_width, screen_height, dst_surface)
    end
  end
end
