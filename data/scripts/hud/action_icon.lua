-- The icon that shows what the action command does.

local action_icon_builder = {}

function action_icon_builder:new(game)
  local action_icon = {}

  function action_icon:initialize()
    action_icon.surface = sol.surface.create(72, 24)
    action_icon.icons_img = sol.surface.create("action_icon.png", true)
    action_icon.icon_region_y = nil
    action_icon.icon_flip_sprite = sol.sprite.create("hud/action_icon_flip")
    action_icon.is_flipping = false
    action_icon.effect_displayed = game:get_command_effect("action") or game:get_custom_command_effect("action")
    action_icon:compute_icon_region_y()

    function action_icon.icon_flip_sprite:on_animation_finished()
      if action_icon.is_flipping then
        action_icon.is_flipping = false
        action_icon:compute_icon_region_y()
        action_icon:rebuild_surface()
      end
    end

    function action_icon.icon_flip_sprite:on_frame_changed()
      action_icon:rebuild_surface()
    end

    action_icon:check()
    action_icon:rebuild_surface()
  end

  function action_icon:compute_icon_region_y()
    local y
    if action_icon.effect_displayed ~= nil then
      -- Create an icon with the name of the current effect.
      local effects_indexes = {
        ["validate"] = 1,
        ["next"] = 2,
        ["info"] = 3,
        ["return"] = 4,
        ["look"] = 5,
        ["open"] = 6,
        ["action"] = 7,
        ["lift"] = 8,
        ["throw"] = 9,
        ["grab"] = 10,
        ["stop"] = 11,
        ["speak"] = 12,
        ["change"] = 13,
        ["swim"] = 14,
        ["custom_lift"] = 8,
        ["custom_carry"] = nil,
      }
      if effects_indexes[action_icon.effect_displayed] ~= nil then
        action_icon.icon_region_y = 24 * effects_indexes[action_icon.effect_displayed]
      end
    end
  end

  function action_icon:check()
    local need_rebuild = false
    local interaction_entity = game:get_hero():get_facing_entity()
    local interaction_effect = interaction_entity and interaction_entity.action_effect
    
    if not action_icon.flipping then
      local effect = game:get_command_effect("action") 
        or game:get_custom_command_effect("action")
        or interaction_effect -- Show custom interaction effect.
      if effect ~= action_icon.effect_displayed then
        if action_icon.effect_displayed ~= nil then
          if effect ~= nil then
            action_icon.icon_flip_sprite:set_animation("flip")
          else
            action_icon.icon_flip_sprite:set_animation("disappearing")
          end
        else
          action_icon.icon_flip_sprite:set_animation("appearing")
        end
        action_icon.effect_displayed = effect
        action_icon.icon_region_y = nil
        action_icon.is_flipping = true
        need_rebuild = true
      end
    end

    -- Redraw the surface only if something has changed.
    if need_rebuild then
      action_icon:rebuild_surface()
    end

    -- Schedule the next check.
    sol.timer.start(game, 50, function()
      action_icon:check()
    end)
  end

  function action_icon:rebuild_surface()
    action_icon.surface:clear()

    if action_icon.icon_region_y ~= nil then
      -- Draw the static image of the icon.
      action_icon.icons_img:draw_region(0, action_icon.icon_region_y, 72, 24, action_icon.surface)
    elseif action_icon.is_flipping then
      -- Draw the flipping sprite
      action_icon.icon_flip_sprite:draw(action_icon.surface, 24, 0)
    end
  end

  function action_icon:set_dst_position(x, y)
    action_icon.dst_x = x
    action_icon.dst_y = y
  end

  function action_icon:on_mouse_pressed(button, x, y)
    if game:get_value("control_scheme") == "touch_1" or game:get_value("control_scheme") == "touch_2" then
      -- Enable mouse (and thereby touch as well) control when that scheme is enabled.
      if (x > action_icon.dst_x + 24) and (x < action_icon.dst_x + 48) and (y > action_icon.dst_y) and (y < action_icon.dst_y + 24) then
        if action_icon.effect_displayed ~= nil then
          game:simulate_command_pressed("action")
        end
      end
    end
  end

  function action_icon:on_draw(dst_surface)
    local x, y = action_icon.dst_x, action_icon.dst_y
    local width, height = dst_surface:get_size()
    if x < 0 then
      x = width + x
    end
    if y < 0 then
      y = height + y
    end

    action_icon.surface:draw(dst_surface, x, y)
  end

  action_icon:initialize()

  return action_icon
end

return action_icon_builder