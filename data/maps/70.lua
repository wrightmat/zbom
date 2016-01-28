local map = ...
local game = map:get_game()

--------------------------------------------------------------------
-- Outside World B7 (Desert/Pyramid Entrance) - Abandoned Pyramid --
--------------------------------------------------------------------

local torch_overlay = nil
if game:get_value("i1068")==nil then game:set_value("i1068", 0) end

function map:on_started(destination)
  -- If you haven't gotten all of the parts (and have met the Geruod), Ordona directs you back.
  if destination == from_pyramid and game:get_value("i1068") >= 1 then
    if not game:get_value("b1087") or not game:get_value("b1088") or not game:get_value("b1089") then
      torch_1:get_sprite():set_animation("lit")
      sol.timer.start(1000, function()
        hero:freeze()
        torch_overlay = sol.surface.create("entities/dark.png")
        torch_overlay:fade_in(50)
        hero:set_direction(2)
        game:start_dialog("ordona.1.pyramid", game:get_player_name(), function()
          torch_overlay:fade_out(50)
          sol.timer.start(2000, function() torch_overlay = nil end)
          hero:unfreeze()
          game:set_stamina(game:get_max_stamina())
          torch_1:get_sprite():set_animation("unlit")
        end)
      end)
    end
  end
end

if game:get_time_of_day() ~= "night" then
  function map:on_draw(dst_surface)
    -- Show torch overlay for Ordona dialog.
    if torch_overlay ~= nil then
      local screen_width, screen_height = dst_surface:get_size()
      local cx, cy = map:get_camera_position()
      local tx, ty = torch_1:get_center_position()
      local x = 320 - tx + cx
      local y = 240 - ty + cy
      torch_overlay:draw_region(x, y, screen_width, screen_height, dst_surface)
    end
  end
end