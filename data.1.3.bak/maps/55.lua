local map = ...
local game = map:get_game()

--------------------------------------------------
-- Outside World E5 (Septen Heights/Tower Entr) --
--------------------------------------------------

function map:on_started(destination)

  if game:get_value("b1170") then
    if game:get_value("i1910") < 7 then
      sol.timer.start(1000, function()
        hero:freeze()
        torch_overlay = sol.surface.create("entities/dark.png")
        torch_overlay:fade_in(50)
        game:start_dialog("ordona.7.septen", game:get_player_name(), function()
          torch_overlay:fade_out(50)
          hero:unfreeze()
	  game:add_max_stamina(100)
	  game:set_stamina(game:get_max_stamina())
          game:set_value("i1910", 7)
        end)
      end)
    end
  end
end

function sensor_change_layer:on_activated()
  -- if walking forward on low level, change to intermediate level
  if layer ~= 1 and hero:get_direction() == 1 then
    local x, y, layer = hero:get_position()
    hero:set_position(x, y, layer+1)
  end

  -- if walking down on intermediate level, changle to low level
  if layer ~= 0 and hero:get_direction() == 3 then
    local x, y, layer = hero:get_position()
    hero:set_position(x, y, layer-1)
  end
end

if game:get_time_of_day() ~= "night" then
function game:on_map_changed(map)
  function map:on_draw(dst_surface)
    if map:get_id() == "55" and torch_overlay then
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
end
