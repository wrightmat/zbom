-- The icon that shows what the attack command does.

local attack_icon_builder = {}

function attack_icon_builder:new(game)
  local attack_icon = {}

  function attack_icon:initialize()
    attack_icon.surface = sol.surface.create(72, 24)
    attack_icon.icons_img = sol.surface.create("sword_icon.png", true)
    attack_icon.icon_region_y = nil
    attack_icon.icon_flip_sprite = sol.sprite.create("hud/sword_icon_flip")
    attack_icon.is_flipping = false
    attack_icon.effect_displayed = game:get_command_effect("attack") or game:get_custom_command_effect("attack")
    attack_icon.sword_displayed = game:get_ability("sword")
    attack_icon.showing_dialog = false
    attack_icon:compute_icon_region_y()

    function attack_icon.icon_flip_sprite:on_animation_finished()
      if attack_icon.is_flipping then
        attack_icon.is_flipping = false
        attack_icon:compute_icon_region_y()
        attack_icon:rebuild_surface()
      end
    end

    function attack_icon.icon_flip_sprite:on_frame_changed()
      attack_icon:rebuild_surface()
    end

    attack_icon:check()
    attack_icon:rebuild_surface()
  end

  function attack_icon:compute_icon_region_y()
    if attack_icon.effect_displayed ~= nil or not game:is_dialog_enabled() then
      if attack_icon.effect_displayed == nil then
        -- Show an empty icon.
        attack_icon.icon_region_y = 0
      elseif attack_icon.effect_displayed == "sword" then
        -- Create an icon with the current sword.
        attack_icon.icon_region_y = 96 + 24 * attack_icon.sword_displayed
      elseif attack_icon.effect_displayed ~= nil then
        -- Create an icon with the name of the current effect.
        local effects_indexes = {
          ["save"] = 1,
          ["return"] = 2,
          ["validate"] = 3,
          ["skip"] = 4,
          ["custom_carry"] = 8,
        }
        if effects_indexes[attack_icon.effect_displayed] ~= nil then
          attack_icon.icon_region_y = 24 * effects_indexes[attack_icon.effect_displayed]
        end
      end
    end
  end

  function attack_icon:check()
    local need_rebuild = false

    if not attack_icon.flipping then
      local effect = game:get_custom_command_effect("attack") or game:get_command_effect("attack")
      local sword = game:get_ability("sword")
      local showing_dialog = game:is_dialog_enabled()
      if effect ~= attack_icon.effect_displayed
          or sword ~= attack_icon.sword_displayed
          or showing_dialog ~= attack_icon.showing_dialog then

        if attack_icon.effect_displayed ~= nil then
          if effect == nil and showing_dialog then
            attack_icon.icon_flip_sprite:set_animation("disappearing")
          else
            attack_icon.icon_flip_sprite:set_animation("flip")
          end
        else
          attack_icon.icon_flip_sprite:set_animation("appearing")
        end
        attack_icon.effect_displayed = effect
        attack_icon.sword_displayed = sword
        attack_icon.showing_dialog = showing_dialog
        attack_icon.icon_region_y = nil
        attack_icon.is_flipping = true
        need_rebuild = true
      end
    end

    -- Redraw the surface only if something has changed.
    if need_rebuild then
      attack_icon:rebuild_surface()
    end

    -- Schedule the next check.
    sol.timer.start(game, 50, function()
      attack_icon:check()
    end)
  end

  function attack_icon:rebuild_surface()
    attack_icon.surface:clear()
    
    if attack_icon.icon_region_y ~= nil then
      -- Draw the static image of the icon.
      attack_icon.icons_img:draw_region(0, attack_icon.icon_region_y, 72, 24, attack_icon.surface)
    elseif attack_icon.is_flipping then
      -- Draw the flipping sprite
      attack_icon.icon_flip_sprite:draw(attack_icon.surface, 24, 0)
    end
  end
  
  function attack_icon:set_dst_position(x, y)
    attack_icon.dst_x = x
    attack_icon.dst_y = y
  end
  
  function attack_icon:on_mouse_pressed(button, x, y)
    if game:get_value("control_scheme") == "touch_1" or game:get_value("control_scheme") == "touch_2" then
      -- Enable mouse (and thereby touch as well) control when that scheme is enabled.
      if (x > attack_icon.dst_x + 24) and (x < attack_icon.dst_x + 48) and (y > attack_icon.dst_y) and (y < attack_icon.dst_y + 24) then
        game:simulate_command_pressed("attack")
      end
    end
  end
  function attack_icon:on_mouse_released(button, x, y)
    if game:get_value("control_scheme") == "touch_1" or game:get_value("control_scheme") == "touch_2" then
      -- Enable mouse (and thereby touch as well) control when that scheme is enabled.
      if (x > attack_icon.dst_x + 24) and (x < attack_icon.dst_x + 48) and (y > attack_icon.dst_y) and (y < attack_icon.dst_y + 24) then
        game:simulate_command_released("attack")
      end
    end
  end
  
  function attack_icon:on_draw(dst_surface)
    local x, y = attack_icon.dst_x, attack_icon.dst_y
    local width, height = dst_surface:get_size()
    if x < 0 then
      x = width + x
    end
    if y < 0 then
      y = height + y
    end
    
    attack_icon.surface:draw(dst_surface, x, y)
  end
  
  attack_icon:initialize()
  
  return attack_icon
end

return attack_icon_builder