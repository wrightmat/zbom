local game = ...

-- This script handles global properties of a particular savegame.

-- Include the various game features.
sol.main.load_file("scripts/menus/warp")(game)
sol.main.load_file("scripts/menus/pause")(game)
sol.main.load_file("scripts/menus/credits")(game)
sol.main.load_file("scripts/menus/game_over")(game)
sol.main.load_file("scripts/menus/dialog_box")(game)
sol.main.load_file("scripts/dungeons")(game)
sol.main.load_file("scripts/equipment")(game)
local tone_manager = require("scripts/tone_manager")
local hud_manager = require("scripts/hud/hud")
local camera_manager = require("scripts/camera_manager")
local condition_manager = require("scripts/hero_condition")
game.save_between_maps = require("scripts/save_between_maps")
game.independent_entities = {}
game.time_flow = 1000 -- One second is one minute in-game (so one hour in-game is one hour).

game:register_event("on_started", function(game)
  -- Set up the dialog box, HUD, hero conditions and effects.
  condition_manager:initialize(game)
  game:initialize_dialog_box()
  game.hud = hud_manager:create(game)
  camera = camera_manager:create(game)
  tone = tone_manager:create(game)
  
  -- Load the sprite of the tunic last equipped.
  -- Note that we don't access the tunic entity itself:
  -- This game has its own tunic ability management
  -- based on the variable "tunic_equipped", the ability
  -- built into the engine doesn't support choosing
  -- between different tunics and is thus just used
  -- to provide the different sprites.
  local equipped = game:get_value("tunic_equipped")
  local hero = game:get_hero()
  hero:set_tunic_sprite_id("hero/tunic" .. equipped)

  -- Set any previously set shader
  if game:get_value("video_shader") ~= nil then
    local shader = sol.shader.create(game:get_value("video_shader"))
    sol.video.set_shader(shader)
  end
  
  -- Measure the time played.
  if game:get_value("time_played") == nil then game:set_value("time_played", 0) end
  chron_timer = sol.timer.start(1000, function()
    game:set_value("time_played", game:get_value("time_played") + 1)
    return true  -- Repeat the timer.
  end)
  chron_timer:set_suspended_with_map(false)
  game:calculate_percent_complete()
end)

function game:on_finished()
  -- Clean what was created by on_started().
  self.hud:quit()
  self:quit_dialog_box()
  camera = nil
  -- Ensure the hero always has a sword when they start a new game (possible to lost it permanantly if cursed).
  if (game:get_ability("sword") == 0 and game:get_value("i1821")) then
    game:set_ability("sword", game:get_value("i1821"))
  end
  -- Print amount of time played
  local time = game:get_value("time_played")
  local hours = math.floor(time / 3600)
  local minutes = math.floor((time % 3600) / 60)
  local seconds = time - (hours * 3600) - (minutes * 60)
  print(hours .. ":" .. minutes .. ":" .. seconds)
end

-- This event is called when a new map has just become active.
game:register_event("on_map_changed", function(game)
  -- Notify the hud.
  game.hud:on_map_changed(game:get_map())
  tone:on_map_changed(game:get_map())
  game.save_between_maps:load_map(game:get_map()) -- Create saved and carried entities.
end)

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
  if self:get_map() ~= nil then
    return self:get_map():get_world() == "outside_world" or
         self:get_map():get_world() == "outside_north" or
         self:get_map():get_world() == "outside_subrosia"
  else
    return false
  end
end

-- Returns whether the current map is in a dungeon.
function game:is_in_dungeon()
  return self:get_dungeon() ~= nil
end

function game:set_time(hour)  
  if (hour >= 7 and hour < 17) then
    game:set_value("time_of_day", "day")
  elseif hour >= 20 or hour < 5 then
    game:set_value("time_of_day", "night")
  end
  game:set_value("hour_of_day", hour)
  
  d = 1
  cr = tr
  cg = tg
  cb = tb
  game:restart_tone_system()	
end

function game:get_time()
  return game:get_value("hour_of_day")
end

-- Returns the current time of day
function game:get_time_of_day()
  if game:get_value("time_of_day") == nil then game:set_value("time_of_day", "day") end
  return game:get_value("time_of_day")
end
  
function game:switch_time_of_day()
  -- Function called when sleeping.
  -- Sleeping during day takes player to 2000 (8pm) and sleeping at night takes us to 0800 (8am).
  if game:get_time_of_day() == "day" then
    game:set_value("time_of_day", "night")
    game:set_time(20)
    minute = 0
    for entity in game:get_map():get_entities("night_") do
      entity:set_enabled(true)
    end
  else
    game:set_value("time_of_day", "day")
    game:set_time(8)
    minute = 0
    for entity in game:get_map():get_entities("night_") do
      entity:set_enabled(false)
    end
  end
  return true
end

local function apply_game_fixes(game)
  -- Issue with savegame variable of wrong type, introduced in 1.1 and fixed in 1.2
  if game:get_value("i1808") == true or game:get_value("i1808") == false then game:set_value("i1808", 1) end
  -- For savegames before 1.3, change this variable to an integer (for new quest system).
  if game:get_value("b1612") then game:set_value("i1612", 1) end
  -- For savegames before 1.3, change this variable (for new quest system).
  if game:get_value("i1926") ~= nil then
    if game:get_value("i1926") >= 3 then game:set_value("i1651", 5) end
  end
end

function game:calculate_percent_complete()
  if game:get_value("i1602")==nil then game:set_value("i1602", 0) end
  if game:get_value("i1603")==nil then game:set_value("i1603", 0) end
  if game:get_value("i1604")==nil then game:set_value("i1604", 0) end
  if game:get_value("i1605")==nil then game:set_value("i1605", 0) end
  if game:get_value("i1606")==nil then game:set_value("i1606", 0) end
  if game:get_value("i1607")==nil then game:set_value("i1607", 0) end
  if game:get_value("i1608")==nil then game:set_value("i1608", 0) end
  if game:get_value("i1609")==nil then game:set_value("i1609", 0) end
  if game:get_value("i1615")==nil then game:set_value("i1615", 0) end
  if game:get_value("i1631")==nil then game:set_value("i1631", 0) end
  if game:get_value("i1822")==nil then game:set_value("i1822", 0) end
  if game:get_value("i1823")==nil then game:set_value("i1823", 0) end
  if game:get_value("i1840")==nil then game:set_value("i1840", 0) end
  if game:get_value("i1841")==nil then game:set_value("i1841", 0) end

  -- 100 total values = 100 percent.
  -- 32 values for heart pieces, 12 for trading sequence, 16 for warp points, 30 for misc. sidequests/items, 10 for misc.
  local percent_complete = (game:get_value("b1701") and 1 or 0) +
    (game:get_value("b1702") and 1 or 0) + (game:get_value("b1703") and 1 or 0) + 
    (game:get_value("b1704") and 1 or 0) + (game:get_value("b1705") and 1 or 0) + 
    (game:get_value("b1706") and 1 or 0) + (game:get_value("b1707") and 1 or 0) + 
    (game:get_value("b1708") and 1 or 0) + (game:get_value("b1709") and 1 or 0) + 
    (game:get_value("b1710") and 1 or 0) + (game:get_value("b1711") and 1 or 0) + 
    (game:get_value("b1712") and 1 or 0) + (game:get_value("b1713") and 1 or 0) + 
    (game:get_value("b1714") and 1 or 0) + (game:get_value("b1715") and 1 or 0) + 
    (game:get_value("b1716") and 1 or 0) + (game:get_value("b1717") and 1 or 0) + 
    (game:get_value("b1718") and 1 or 0) + (game:get_value("b1719") and 1 or 0) + 
    (game:get_value("b1720") and 1 or 0) + (game:get_value("b1721") and 1 or 0) + 
    (game:get_value("b1722") and 1 or 0) + (game:get_value("b1723") and 1 or 0) + 
    (game:get_value("b1724") and 1 or 0) + (game:get_value("b1725") and 1 or 0) + 
    (game:get_value("b1726") and 1 or 0) + (game:get_value("b1727") and 1 or 0) + 
    (game:get_value("b1728") and 1 or 0) + (game:get_value("b1729") and 1 or 0) + 
    (game:get_value("b1730") and 1 or 0) + (game:get_value("b1731") and 1 or 0) + 
    (game:get_value("b1732") and 1 or 0) +
    (game:get_value("i1840") - 1 ) + --  Heart Pieces above here. Trading here.

    (game:get_value("b1500") and 1 or 0) + (game:get_value("b1501") and 1 or 0) +
    (game:get_value("b1502") and 1 or 0) + (game:get_value("b1503") and 1 or 0) +
    (game:get_value("b1504") and 1 or 0) + (game:get_value("b1505") and 1 or 0) +
    (game:get_value("b1506") and 1 or 0) + (game:get_value("b1507") and 1 or 0) +
    (game:get_value("b1508") and 1 or 0) + (game:get_value("b1509") and 1 or 0) +
    (game:get_value("b1510") and 1 or 0) + (game:get_value("b1511") and 1 or 0) +
    (game:get_value("b1512") and 1 or 0) + (game:get_value("b1513") and 1 or 0) +
    (game:get_value("b1514") and 1 or 0) + (game:get_value("b1515") and 1 or 0) -- Warp points above here. Sidequests below here.

    if game:get_value("i1602") >= 6 then percent_complete = percent_complete + 1 end  -- Gaira/Deacon
    if game:get_value("i1603") >= 5 then percent_complete = percent_complete + 2 end  -- Great Fairy Mystic Jade
    if game:get_value("i1604") >= 5 then percent_complete = percent_complete + 2 end  -- Great Fairy Goron Amber
    if game:get_value("i1605") >= 5 then percent_complete = percent_complete + 2 end  -- Great Fairy Alchemy Stone
    if game:get_value("i1606") >= 5 then percent_complete = percent_complete + 2 end  -- Great Fairy Goddess Plume
    if game:get_value("i1607") >= 5 then percent_complete = percent_complete + 2 end  -- Great Fairy Subrosian Ore
    if game:get_value("i1608") >= 5 then percent_complete = percent_complete + 2 end  -- Great Fairy Magic Crystal
    if game:get_value("i1609") >= 50 then percent_complete = percent_complete + 1 end  -- Cave of Ordeals
    if game:get_value("i1810") ~= nil then percent_complete = percent_complete + 2 end  -- Bottle 1 (Rudy)
    if game:get_value("i1811") ~= nil then percent_complete = percent_complete + 2 end  -- Bottle 2 (Relic Collector)
    if game:get_value("i1812") ~= nil then percent_complete = percent_complete + 2 end  -- Bottle 3 (Kakariko Thief)
    if game:get_value("i1813") ~= nil then percent_complete = percent_complete + 2 end  -- Bottle 4 (Goron Market)
    if game:get_value("i1838") ~= nil then percent_complete = percent_complete + 2 end  -- Shovel
    if game:get_value("i1839") ~= nil then percent_complete = percent_complete + 2 end  -- Hammer
    if game:get_value("b1699") then percent_complete = percent_complete + 2 end  -- Main Quest

    -- Last 10% is misc.
    percent_complete = percent_complete + (game:get_value("i1822") - 1) * 2  -- Tunics (up to 6 points possible for 3 additional tunics)
    if game:get_value("i1615") >= 13 then percent_complete = percent_complete + 2 end  -- Books fetch quest
    if game:get_value("i1631") >= 16 then percent_complete = percent_complete + 2 end  -- Plants fetch quest
    if game:get_value("i1823") >= 3 then percent_complete = percent_complete + 1 end  -- Fully upgraded world map
    if game:get_value("i1841") >= 4 then percent_complete = percent_complete + 1 end  -- Master Ore obtained

  game:set_value("percent_complete", percent_complete)
  return percent_complete
end

-- Run the game.
sol.main.game = game
apply_game_fixes(game)
game:start()