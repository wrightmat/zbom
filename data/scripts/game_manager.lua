local game = ...

-- This script handles global properties of a particular savegame.

-- Include the various game features.
sol.main.load_file("scripts/menus/warp")(game)
sol.main.load_file("scripts/menus/pause")(game)
sol.main.load_file("scripts/menus/credits")(game)
sol.main.load_file("scripts/menus/game_over")(game)
sol.main.load_file("scripts/menus/dialog_box")(game)
sol.main.load_file("scripts/hud/hud")(game)
sol.main.load_file("scripts/dungeons")(game)
sol.main.load_file("scripts/equipment")(game)
sol.main.load_file("scripts/custom_interactions.lua")(game)
sol.main.load_file("scripts/collision_test_manager.lua")(game)
local hud_manager = require("scripts/hud/hud")
local camera_manager = require("scripts/camera_manager")
local condition_manager = require("scripts/hero_condition")
game.save_between_maps = require("scripts/save_between_maps")
game.independent_entities = {}

function game:on_started()
  -- Set up the dialog box, HUD, hero conditions and effects.
  condition_manager:initialize(self)
  self:initialize_dialog_box()
  self.hud = hud_manager:create(game)
  camera = camera_manager:create(game)
end

function game:on_finished()
  -- Clean what was created by on_started().
  self.hud:quit()
  self:quit_dialog_box()
  camera = nil
end

-- This event is called when a new map has just become active.
function game:on_map_changed(map)
  -- Notify the hud.
  self.hud:on_map_changed(map)

  game:set_custom_command_effect("action", nil) -- Reset. To avoid problems with custom_interactions.lua.
  game.save_between_maps:load_map(map) -- Create saved and carried entities.
end

function game:on_paused()
  self.hud:on_paused()
  self:start_pause_menu()
end

function game:on_unpaused()
  self:stop_pause_menu()
  self.hud:on_unpaused()
end

function game:get_player_name()
  return self:get_value("player_name")
end

function game:set_player_name(player_name)
  self:set_value("player_name", player_name)
end

-- Returns whether the current map is in the inside world.
function game:is_in_inside_world()
  return self:get_map():get_world() == "inside_world"
end

-- Returns whether the current map is in the outside world.
function game:is_in_outside_world()
  return self:get_map():get_world() == "outside_world" or
         self:get_map():get_world() == "outside_north" or
         self:get_map():get_world() == "outside_subrosia"
end

-- Returns whether the current map is in a dungeon.
function game:is_in_dungeon()
  return self:get_dungeon() ~= nil
end

-- Returns/sets the current time of day
function game:get_time_of_day()
  if game:get_value("time_of_day") == nil then game:set_value("time_of_day", "day") end
  return game:get_value("time_of_day")
end
function game:set_time_of_day(tod)
  if tod == "day" or tod == "night" then
    game:set_value("time_of_day", tod)
  end
  return true
end
function game:switch_time_of_day()
  if game:get_value("time_of_day") == "day" then
    game:set_value("time_of_day", "night")
  else
    game:set_value("time_of_day", "day")
  end
  return true
end

-- Run the game.
sol.main.game = game
game:start()