-- Weather script: enable/disable different scripts for weather.
-- Author: Diarandor (Solarus Team).
-- License: GPL v3-or-later.
-- Donations: solarus-games.org, diarandor at gmail dot com.

local rain_manager_enabled = true
local snow_manager_enabled = true
local hail_manager_enabled = true
local leaf_manager_enabled = true

local game_meta = sol.main.get_metatable("game")

if rain_manager_enabled then
  require("scripts/weather/rain_manager")
else -- Redefine methods to avoid errors.
  function game_meta:get_rain_mode() return nil end
  function game_meta:set_rain_mode(rain_mode) end
  function game_meta:get_world_rain_mode(world) return nil end
  function game_meta:set_world_rain_mode(world, rain_mode) end
end
if snow_manager_enabled then
  require("scripts/weather/snow_manager")
else -- Redefine methods to avoid errors.
  function game_meta:get_snow_mode() return nil end
  function game_meta:set_snow_mode(snow_mode) end
  function game_meta:get_world_snow_mode(world) return nil end
  function game_meta:set_world_snow_mode(world, snow_mode) end
end
if hail_manager_enabled then
  require("scripts/weather/hail_manager")
else -- Redefine methods to avoid errors.
  function game_meta:get_hail_mode() return nil end
  function game_meta:set_hail_mode(hail_mode) end
  function game_meta:get_world_hail_mode(world) return nil end
  function game_meta:set_world_hail_mode(world, hail_mode) end
end
if leaf_manager_enabled then
  require("scripts/weather/leaf_manager")
else -- Redefine methods to avoid errors.
  function game_meta:get_leaf_mode() return nil end
  function game_meta:set_leaf_mode(leaf_mode) end
  function game_meta:get_world_leaf_mode(world) return nil end
  function game_meta:set_world_leaf_mode(world, leaf_mode) end
end