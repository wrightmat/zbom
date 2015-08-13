local game = ...

-- This script handles global properties of a particular savegame.

-- Include the various game features.
sol.main.load_file("hud/hud")(game)
sol.main.load_file("menus/pause")(game)
sol.main.load_file("menus/game_over")(game)
sol.main.load_file("menus/dialog_box")(game)
sol.main.load_file("scripts/dungeons")(game)
sol.main.load_file("scripts/equipment")(game)
sol.main.load_file("scripts/particles")(game)
local camera_manager = require("scripts/camera_manager")
local condition_manager = require("scripts/hero_condition")

function game:on_started()
  -- Set up the dialog box, HUD, hero conditions and effects.
  condition_manager:initialize(self)
  self:initialize_dialog_box()
  self:initialize_hud()
  camera = camera_manager:create(game)
end

function game:on_finished()
  -- Clean what was created by on_started().
  self:quit_hud()
  self:quit_dialog_box()
  camera = nil
end

-- This event is called when a new map has just become active.
function game:on_map_changed(map)
  -- Notify the hud.
  self:hud_on_map_changed(map)
end

function game:on_paused()
  self:hud_on_paused()
  self:start_pause_menu()
end

function game:on_unpaused()
  self:stop_pause_menu()
  self:hud_on_unpaused()
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
  return self:get_map():get_world() == "outside_world" or self:get_map():get_world() == "outside_north"
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