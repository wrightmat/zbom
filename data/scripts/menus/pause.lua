local game = ...

local inventory_builder = require("scripts/menus/pause_inventory")
local map_builder = require("scripts/menus/pause_map")
local quest_status_builder = require("scripts/menus/pause_quest_status")
local options_builder = require("scripts/menus/pause_options")
local joy_avoid_repeat = {-2, -2}

function game:start_pause_menu()
  self.pause_submenus = {
    inventory_builder:new(self),
    map_builder:new(self),
    quest_status_builder:new(self),
    options_builder:new(self),
  }

  local submenu_index = self:get_value("pause_last_submenu") or 1
  if submenu_index <= 0 or submenu_index > #self.pause_submenus then
    submenu_index = 1
  end
  self:set_value("pause_last_submenu", submenu_index)

  sol.audio.play_sound("pause_open")
  sol.menu.start(game, self.pause_submenus[submenu_index], true)
  game.hud:set_enabled(false)
  game.hud:set_enabled(true)  -- Refresh the HUD so it stays on top of the menu.
end

function game:stop_pause_menu()
  sol.audio.play_sound("pause_closed")
  local submenu_index = self:get_value("pause_last_submenu")
  sol.menu.stop(self.pause_submenus[submenu_index])
  self.pause_submenus = {}
  self:set_custom_command_effect("action", nil)
  self:set_custom_command_effect("attack", nil)
end

function game:on_joypad_axis_moved(axis, state)
  local handled = joy_avoid_repeat[axis % 2] == state
  joy_avoid_repeat[axis % 2] = state
  
  return handled
end