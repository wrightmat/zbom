-- Script that creates a head-up display for a game.

local hud_manager = {}

-- Creates and runs a HUD for the specified game.
function hud_manager:create(game)

  -- Set up the HUD.
  local hud = {
    enabled = false,
    showing_dialog = false,
    top_left_opacity = 255,
    elements = {},
    custom_command_effects = {},
  }

  -- Returns the current customized effect of the action or attack command.
  -- nil means the built-in effect.
  function game:get_custom_command_effect(command)
    return hud.custom_command_effects[command]
  end
  -- Overrides the effect of the action or attack command.
  -- Set the effect to nil to restore the built-in effect.
  function game:set_custom_command_effect(command, effect)
    hud.custom_command_effects[command] = effect
  end 

  -- Create each element of the HUD.
  local floor_builder = require("scripts/hud/floor")
  local rupees_builder = require("scripts/hud/rupees")
  local hearts_builder = require("scripts/hud/hearts")
  local item_icon_builder = require("scripts/hud/item_icon")
  local magic_bar_builder = require("scripts/hud/magic_bar")
  local pickables_builder = require("scripts/hud/pickables")
  local pause_icon_builder = require("scripts/hud/pause_icon")
  local small_keys_builder = require("scripts/hud/small_keys")
  local stamina_bar_builder = require("scripts/hud/stamina_bar")
  local attack_icon_builder = require("scripts/hud/attack_icon")
  local action_icon_builder = require("scripts/hud/action_icon")
  local clock_builder = require("scripts/hud/clock")
  local hero_condition_builder = require("scripts/hud/hero_condition")

  local hearts = hearts_builder:new(game)
  hearts:set_dst_position(-104, 6)
  hud.elements[#hud.elements + 1] = hearts

  local magic_bar = magic_bar_builder:new(game)
  magic_bar:set_dst_position(-104, 27)
  hud.elements[#hud.elements + 1] = magic_bar

  local stamina_bar = stamina_bar_builder:new(game)
  stamina_bar:set_dst_position(-104, 34)
  hud.elements[#hud.elements + 1] = stamina_bar

  local hero_condition = hero_condition_builder:new(game)
  hero_condition:set_dst_position(-130, 20)
  hud.elements[#hud.elements + 1] = hero_condition

  local rupees = rupees_builder:new(game)
  rupees:set_dst_position(8, -20)
  hud.elements[#hud.elements + 1] = rupees

  local pickables = pickables_builder:new(game)
  pickables:set_dst_position(-255, -30)
  hud.elements[#hud.elements + 1] = pickables

  local small_keys = small_keys_builder:new(game)
  small_keys:set_dst_position(8, -40)
  hud.elements[#hud.elements + 1] = small_keys

  local floor = floor_builder:new(game)
  floor:set_dst_position(5, 70)
  hud.elements[#hud.elements + 1] = floor

  local pause_icon = pause_icon_builder:new(game)
  pause_icon:set_dst_position(0, 7)
  hud.elements[#hud.elements + 1] = pause_icon

  local item_icon_1 = item_icon_builder:new(game, 1)
  item_icon_1:set_dst_position(11, 29)
  hud.elements[#hud.elements + 1] = item_icon_1

  local item_icon_2 = item_icon_builder:new(game, 2)
  item_icon_2:set_dst_position(63, 29)
  hud.elements[#hud.elements + 1] = item_icon_2

  local attack_icon = attack_icon_builder:new(game)
  attack_icon:set_dst_position(13, 29)
  hud.elements[#hud.elements + 1] = attack_icon

  local action_icon = action_icon_builder:new(game)
  action_icon:set_dst_position(26, 51)
  hud.elements[#hud.elements + 1] = action_icon

  local clock = clock_builder:new(game)
  clock:set_dst_position(0, -50)
  hud.elements[#hud.elements + 1] = clock

  -- Destroys the HUD.
  function hud:quit()
    if hud:is_enabled() then
      -- Stop all HUD elements.
      hud:set_enabled(false)
    end
  end

  -- Function called regularly to update the opacity and the position
  -- of HUD elements depending on various factors.
  local function check_hud()
    local map = game:get_map()
    if map ~= nil then
      -- If the hero is below the top-left icons, make them semi-transparent.
      local hero = map:get_entity("hero")
      local hero_x, hero_y = hero:get_position()
      local camera_x, camera_y = map:get_camera():get_position()
      local x = hero_x - camera_x
      local y = hero_y - camera_y
      local opacity = nil

      if hud.top_left_opacity == 255
          and not game:is_suspended()
          and x < 88
          and y < 80 then
        opacity = 96
      elseif hud.top_left_opacity == 96
          and (game:is_suspended()
          or x >= 88
          or y >= 80) then
        opacity = 255
      end

      if opacity ~= nil then
        hud.top_left_opacity = opacity
        item_icon_1.surface:set_opacity(opacity)
        item_icon_2.surface:set_opacity(opacity)
        pause_icon.surface:set_opacity(opacity)
        attack_icon.surface:set_opacity(opacity)
        action_icon.surface:set_opacity(opacity)
      end

      -- During a dialog, move the action icon and the sword icon.
      if not hud.showing_dialog and
          game:is_dialog_enabled() then
        hud.showing_dialog = true
        action_icon:set_dst_position(0, 54)
        attack_icon:set_dst_position(0, 29)
      elseif hud.showing_dialog and
          not game:is_dialog_enabled() then
        hud.showing_dialog = false
        action_icon:set_dst_position(26, 51)
        attack_icon:set_dst_position(13, 29)
      end
    end

    sol.timer.start(game, 50, check_hud)
  end

  -- Call this function to notify the HUD that the current map has changed.
  function hud:on_map_changed(map)
    if hud:is_enabled() then
      for _, menu in ipairs(hud.elements) do
        if menu.on_map_changed ~= nil then
          menu:on_map_changed(map)
        end
      end
    end
  end

  -- Call this function to notify the HUD that the game was just paused.
  function hud:on_paused()
    if hud:is_enabled() then
      for _, menu in ipairs(hud.elements) do
        if menu.on_paused ~= nil then
          menu:on_paused()
        end
      end
    end
  end

  -- Call this function to notify the HUD that the game was just unpaused.
  function hud:on_unpaused()
    if hud:is_enabled() then
      for _, menu in ipairs(hud.elements) do
        if menu.on_unpaused ~= nil then
          menu:on_unpaused()
        end
      end
    end
  end

  -- Returns whether the HUD is currently enabled.
  function hud:is_enabled()
    return hud.enabled
  end

  -- Enables or disables the HUD.
  function hud:set_enabled(enabled)
    if enabled ~= hud.enabled then
      hud.enabled = enabled

      for _, menu in ipairs(hud.elements) do
        if enabled then
          -- Start each HUD element.
          sol.menu.start(game, menu)
        else
          -- Stop each HUD element.
          sol.menu.stop(menu)
        end
      end
    end
  end

  -- Start the HUD.
  hud:set_enabled(true)

  -- Update it regularly.
  check_hud()

  -- Return the HUD.
  return hud
end

return hud_manager