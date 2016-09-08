-- The icon that shows what the pause command does.

local pause_icon_builder = {}

function pause_icon_builder:new(game)
  local pause_icon = {}
  
  function pause_icon:initialize(game)
    pause_icon.surface = sol.surface.create(72, 24)
    pause_icon.icons_img = sol.surface.create("pause_icon.png", true)
    pause_icon.icon_region_y = nil
    pause_icon.is_game_paused = false
    pause_icon.icon_flip_sprite = sol.sprite.create("hud/pause_icon_flip")
    pause_icon:compute_icon_region_y()
    
    function pause_icon.icon_flip_sprite:on_animation_finished()
      if pause_icon.icon_region_y == nil then
        pause_icon:compute_icon_region_y()
        pause_icon:rebuild_surface()
      end
    end
    
    function self.icon_flip_sprite:on_frame_changed()
      pause_icon:rebuild_surface()
    end
    
    pause_icon:rebuild_surface()
  end

  function pause_icon:compute_icon_region_y()
    pause_icon.icon_region_y = 24
    if game:is_paused() or game:get_command_effect("pause") == "return" or game:get_custom_command_effect("pause") then
      pause_icon.icon_region_y = 48
    end
  end
  
  function pause_icon:on_paused()
    pause_icon.icon_region_y = nil
    pause_icon.icon_flip_sprite:set_frame(0)
    pause_icon:rebuild_surface()
  end
  
  function pause_icon:on_unpaused()
    pause_icon.icon_region_y = nil
    pause_icon.icon_flip_sprite:set_frame(0)
    pause_icon:rebuild_surface()
  end

  function pause_icon:on_menu_opened()
    pause_icon.icon_region_y = nil
    pause_icon.icon_flip_sprite:set_frame(0)
    pause_icon:rebuild_surface()
    game:set_custom_command_effect("pause", "return")
  end
  
  function pause_icon:on_menu_closed()
    pause_icon.icon_region_y = nil
    pause_icon.icon_flip_sprite:set_frame(0)
    pause_icon:rebuild_surface()
    game:set_custom_command_effect("pause", nil)
  end
  
  function pause_icon:rebuild_surface()
    pause_icon.surface:clear()

    if pause_icon.icon_region_y ~= nil then
      -- Draw the static image of the icon: "Pause" or "Back".
      pause_icon.icons_img:draw_region(0, self.icon_region_y, 72, 24, self.surface)
    else
      -- Draw the flipping sprite
      pause_icon.icon_flip_sprite:draw(self.surface, 24, 0)
    end
  end

  function pause_icon:set_dst_position(x, y)
    pause_icon.dst_x = x
    pause_icon.dst_y = y
  end

  function pause_icon:on_mouse_pressed(button, x, y)
    if game:get_value("control_scheme") == "touch_1" or game:get_value("control_scheme") == "touch_2" then
    -- Enable mouse (and thereby touch as well) control when that scheme is enabled.
      if (x > pause_icon.dst_x + 24) and (x < pause_icon.dst_x + 48) and (y > pause_icon.dst_y) and (y < pause_icon.dst_y + 24) then
        game:simulate_command_pressed("pause")
      end
    end
  end

  function pause_icon:on_draw(dst_surface)
    if not game:is_dialog_enabled() then
      local x, y = pause_icon.dst_x, pause_icon.dst_y
      local width, height = dst_surface:get_size()
      if x < 0 then x = width + x end
      if y < 0 then y = height + y end
      pause_icon.surface:draw(dst_surface, x, y)
    end
  end

  pause_icon:initialize()

  return pause_icon
end

return pause_icon_builder