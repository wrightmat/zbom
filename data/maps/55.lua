local map = ...
local game = map:get_game()

--------------------------------------------------
-- Outside World E5 (Septen Heights/Tower Entr) --
--------------------------------------------------

local torch_overlay = nil

function map:on_started(destination)
  if game:get_value("b1150") then stone_pile:remove() end -- Tower construction over after Snowpeak Caverns beat.
  if game:get_value("b1170") and game:get_value("i1910") < 7 then
    torch_1:get_sprite():set_animation("lit")
    sol.timer.start(1000, function()
      hero:freeze()
      torch_overlay = sol.surface.create("entities/dark.png")
      torch_overlay:fade_in(50)
      game:start_dialog("ordona.7.septen", game:get_player_name(), function()
        torch_overlay:fade_out(50)
        sol.timer.start(2000, function() torch_overlay = nil end)
        hero:unfreeze()
        game:add_max_stamina(100)
        game:set_stamina(game:get_max_stamina())
        torch_1:get_sprite():set_animation("unlit")
        game:set_value("i1910", 7)
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

function map:on_draw(dst_surface)
  -- Show torch overlay for Ordona dialog.
  if game:get_time_of_day() ~= "night" and torch_overlay ~= nil then
    local screen_width, screen_height = dst_surface:get_size()
    local cx, cy = map:get_camera_position()
    local tx, ty = torch_1:get_center_position()
    local x = 320 - tx + cx
    local y = 240 - ty + cy
    torch_overlay:draw_region(x, y, screen_width, screen_height, dst_surface)
  end
end

function sensor_change_layer:on_activated()
  -- If walking forward on low level, change to intermediate level.
  if layer ~= 1 and hero:get_direction() == 1 then
    local x, y, layer = hero:get_position()
    hero:set_position(x, y, layer+1)
  end

  -- If walking down on intermediate level, changle to low level.
  if layer ~= 0 and hero:get_direction() == 3 then
    local x, y, layer = hero:get_position()
    hero:set_position(x, y, layer-1)
  end
end