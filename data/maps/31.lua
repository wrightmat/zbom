local map = ...
local game = map:get_game()

--------------------------------------------------------------------------------------
-- Outside World E11 (Lakebed Lair Entr) - Entrance to Lakebed Lair (dynamic water) --
--------------------------------------------------------------------------------------

if game:get_value("i1030")==nil then game:set_value("i1030", 0) end

function map:on_started(destination)
  if game:get_value("b1134") then
    -- If the dungeon has been completed, the water returns
    map:set_entities_enabled("water", true)
    map:set_entities_enabled("wake", true)

    if game:get_value("i1910") < 5 then
      sol.timer.start(1000, function()
        hero:freeze()
        torch_overlay = sol.surface.create("entities/dark.png")
        torch_overlay:fade_in(50)
        game:start_dialog("ordona.5.lake_hylia", game:get_player_name(), function()
          torch_overlay:fade_out(50)
          hero:unfreeze()
          game:set_value("i1910", 5)
        end)
      end)
    end

  elseif game:get_value("i1030") >= 2 then
    -- If the switch has been flipped in the sewers, the water is gone
    map:set_entities_enabled("water", false)
    map:set_entities_enabled("wake", false)
    sx, sy, sl = statue:get_position()
    tx, ty, tl = temple_entr:get_position()
    statue:set_position(sx, sy, 0)
    temple_entr:set_position(tx, ty, 1)
  end
end

function game:on_map_changed(map)
  function map:on_draw(dst_surface)
    if map:get_id() == "31" and torch_overlay then
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
