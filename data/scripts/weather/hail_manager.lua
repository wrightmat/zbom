-- Hail manager script.
-- Author: Diarandor (Solarus Team).
-- License: GPL v3-or-later.
-- Donations: solarus-games.org, diarandor at gmail dot com.

--[[   Instructions:
To add this script to your game, call from game_manager script:
    require("scripts/weather/hail_manager")

The functions here defined are:
    game:get_hail_mode()
    game:set_hail_mode(hail_mode)
    game:get_world_hail_mode(world)
    game:set_world_hail_mode(world, hail_mode)

hail modes: "hail", "hailstorm", nil (no hail).
--]]

local hail_manager = {}

local game_meta = sol.main.get_metatable("game")
local map_meta = sol.main.get_metatable("map")

-- Assets: sounds and sprites.
-- [Nothing]

-- Default settings. Change these for testing.
local hail_speed, hailstorm_speed = 200, 230 -- In pixels per second.
local stone_min_distance, stone_max_distance = 40, 300
local splash_min_distance, splash_max_distance = 10, 20
local splash_min_height, splash_max_height = 8, 16
local splash_min_duration, splash_max_duration = 100, 300
local splash_min_num_bounces, splash_max_num_bounces = 1, 3
local hail_stone_delay, hailstorm_stone_delay = 10, 5 -- In milliseconds.
local falling_angle = 3 * math.pi / 2
local hail_darkness, hailstorm_darkness = 40, 90 -- Opacity during hailstorm.
local current_darkness = 0 -- Opacity (transparent = 0, opaque = 255).
local color_darkness = {100, 100, 255} -- Used for full darkness.
local max_num_stones_hail, max_num_stones_hailstorm = 120, 300
local sx, sy = 0, 0 -- Scrolling shifts for stone positions.

-- Main variables.
local hail_surface, dark_surface, stone_surface
local stone_list, splash_list, timers, num_stones, num_splashes
local current_game, current_map, current_hail_mode, previous_hail_mode
local previous_world, current_world, is_scrolling

-- Get/set current hail mode in the current map.
function game_meta:get_hail_mode() return current_hail_mode end
function game_meta:set_hail_mode(hail_mode)
  previous_world = current_world
  hail_manager:start_hail_mode(hail_mode)
end
-- Get/set the hail mode for a given world.
function game_meta:get_world_hail_mode(world)
  return world and self:get_value("hail_mode_" .. world) or nil
end
function game_meta:set_world_hail_mode(world, hail_mode)
  self:set_value("hail_mode_" .. world, hail_mode)
  if current_world == world then self:set_hail_mode(hail_mode) end
end

-- Initialize hail manager.
game_meta:register_event("on_started", function(game)
  current_game = game
  hail_manager:on_created()
end)
-- Initialize hail on maps when necessary.
game_meta:register_event("on_map_changed", function(game)
  hail_manager:on_map_changed(game:get_map())
end)
-- Allow to draw surfaces (it uses the event "game.on_draw").
game_meta:register_event("on_draw", function(game, dst_surface)
  hail_manager:on_draw(dst_surface)
end)

-- Create hail and dark surfaces.
function hail_manager:on_created()
  -- Create surfaces.
  local w, h = sol.video.get_quest_size()
  hail_surface = sol.surface.create(w, h)
  dark_surface = sol.surface.create(w, h)
  stone_surface = sol.surface.create(2, 2)
  stone_surface:fill_color({255, 255, 255})
  dark_surface:set_blend_mode("add")
  hail_surface:set_blend_mode("add")
  -- Initialize main variables.
  current_hail_mode, previous_hail_mode, previous_world = nil, nil, nil
  num_stones, num_splashes, current_darkness = 0, 0, 0
  stone_list, splash_list, timers = {}, {}, {}
  local num_slots = math.max(max_num_stones_hail, max_num_stones_hailstorm)
  for i = 0, num_slots - 1 do  
    stone_list[i] = {index = i}
    splash_list[i] = {index = i}
  end
  -- Add scrolling feature with teletransporters.
  self:initialize_scrolling_feature()
end

-- Update current_hail_mode and current_map variables.
function hail_manager:on_map_changed(map)
  local world = map:get_world()
  current_map = map
  previous_world = current_world
  current_world = world
  local hail_mode = current_game:get_world_hail_mode(world)
  self:start_hail_mode(hail_mode)
  if is_scrolling then self:finish_scrolling() end
end

-- Draw surfaces of the hail manager.
function hail_manager:on_draw(dst_surface)
  if current_hail_mode == nil then
    if previous_hail_mode == nil or previous_world ~= current_world then
      return
    end
  end
  -- Draw surfaces on the current map if necessary.
  if hail_surface and (num_stones > 0 or num_splashes > 0) then
    self:update_hail_surface()
    hail_surface:draw(dst_surface)
  end
  if dark_surface and current_darkness > 0 then
    dark_surface:draw(dst_surface)
  end
end

-- Update hail surface.
function hail_manager:update_hail_surface()
  if current_hail_mode == nil and previous_hail_mode == nil then
    return
  end
  hail_surface:clear()
  local camera = current_map:get_camera()
  local cx, cy, cw, ch = camera:get_bounding_box()
  -- Draw stones on surface.
  for _, stone in pairs(stone_list) do
    if stone.exists then
      local x = (stone.init_x + stone.x - cx + sx) % cw
      local y = (stone.init_y + stone.y - cy + sy) % ch
      stone_surface:set_opacity(255)
      stone_surface:draw(hail_surface, x, y)
    end
  end
  -- Draw splashes on surface.
  for _, splash in pairs(splash_list) do
    if splash.exists then
      local height = splash.height
      local x = (splash.init_x + splash.x - cx + sx) % cw
      local y = (splash.init_y + splash.y + height - cy + sy) % ch
      local opacity = splash.opacity or 255
      stone_surface:set_opacity(opacity or 255)
      stone_surface:draw(hail_surface, x, y)
    end
  end
end

-- Create properties list for a new water stone at random position.
function hail_manager:create_stone(deviation)
  -- Prepare next slot.
  local max_num_stones = max_num_stones_hail
  if current_hail_mode == "hailstorm" then max_num_stones = max_num_stones_hailstorm end
  local index, stone = 0, stone_list[0]
  while index < max_num_stones and stone.exists do
    index = index + 1
    stone = stone_list[index]
  end
  if stone == nil or stone.exists then return end
  -- Set properties for new stone.
  local map = current_map
  local cx, cy, cw, ch = map:get_camera():get_bounding_box()
  stone.init_x = cx + cw * math.random()
  stone.init_y = cy + ch * math.random()
  stone.x, stone.y = 0, 0
  stone.speed = (current_hail_mode == "hail") and hail_speed or hailstorm_speed
  stone.angle = falling_angle + (deviation or 0)
  stone.max_distance = math.random(stone_min_distance, stone_max_distance)
  num_stones = num_stones + 1
  stone.exists = true
end

-- Create splash effect and put it in the list.
function hail_manager:create_splash(index)
  -- Diable associated stone.
  local stone = stone_list[index]
  num_stones = num_stones - 1
  -- Do nothing if there is no space for a new splash.
  local splash = splash_list[index]
  if splash.exists then return end
  -- Create splash.
  splash.init_x = stone.init_x + stone.x
  splash.init_y = stone.init_y + stone.y
  splash.x, splash.y = 0, 0
  splash.angle = 2 * math.pi * math.random()
  splash.height, splash.time, splash.bounce = 0, 0, 0
  splash.opacity = 255
  splash.num_bounces = math.random(splash_min_num_bounces, splash_max_num_bounces)
  splash.max_distance = math.random(splash_min_distance, splash_max_distance)
  splash.max_height = math.random(splash_min_height, splash_max_height)
  splash.max_time = math.random(splash_min_duration, splash_max_duration)
  num_splashes = num_splashes + 1
  splash.exists = true
end

-- Destroy the timers whose names appear in the list.
function hail_manager:stop_timers(timers_list)
  for _, key  in pairs(timers_list) do
    local t = timers[key]
    if t then t:stop() end
    timers[key] = nil
  end
end

-- Start a hail mode in the current map.
function hail_manager:start_hail_mode(hail_mode)
  -- Update hail modes.
  previous_hail_mode = current_hail_mode
  current_hail_mode = hail_mode
  -- Stop creating stones (timer delays differ on each mode).
  self:stop_timers({"stone_creation_timer"})
  -- Update darkness (fade-out effects included).
  self:update_darkness()
  -- Nothing more to do if there is no hail.
  if hail_mode == nil then return end
  --Initialize stone parameters (used by "hail_manager.create_stone").
  local game = current_game
  local current_stone_delay
  if hail_mode == "hail" then current_stone_delay = hail_stone_delay
  elseif hail_mode == "hailstorm" then current_stone_delay = hailstorm_stone_delay
  elseif hail_mode ~= nil then error("Invalid hail mode.") end
  -- Initialize stone creation timer.
  timers["stone_creation_timer"] = sol.timer.start(game, current_stone_delay, function()
    -- Random angle deviation in case of hailstorm.
    local stone_deviation = 0
    if hail_mode == "hailstorm" then
      stone_deviation = math.random(-1, 1) * math.random() * math.pi / 8
    end
    hail_manager:create_stone(stone_deviation)
    return true -- Repeat loop.
  end)
  -- Initialize stone position timer.
  if timers["stone_position_timer"] == nil then
    local dt = 10 -- Timer delay.
    timers["stone_position_timer"] = sol.timer.start(game, dt, function()
      -- Move stones.
      for index, stone in pairs(stone_list) do
        if stone.exists then
          local distance_increment = stone.speed * (dt / 1000)
          stone.x = stone.x + distance_increment * math.cos(stone.angle)
          stone.y = stone.y + distance_increment * math.sin(stone.angle) * (-1)
          local distance = math.sqrt((stone.x)^2 + (stone.y)^2)
          if distance >= stone.max_distance then
            -- Disable stone and create stone splash.
            stone.exists = false
            hail_manager:create_splash(index)
          end
        end
      end
      -- Move splashes.
      for _, splash in pairs(splash_list) do
        if splash.exists then
          -- Move splashes that exist and are not disappearing.
          if (not splash.disappear) then
            -- Bounce movement.
            local speed = splash.max_distance / splash.max_time
            splash.time = splash.time + dt
            splash.x = speed * splash.time * math.cos(splash.angle)
            splash.y = speed * splash.time * math.sin(splash.angle) * (-1)
            local tn = splash.time / splash.max_time -- Time proportion.
            splash.height = 4 * splash.max_height * tn * (1 - tn)
            -- Prepare for next bounce and disappear after last one.
            if splash.time >= splash.max_time then
              if splash.bounce < splash.num_bounces then
                -- Next bounce.
                local deviation = (math.random() - 1/2) * math.pi
                splash.angle = splash.angle + deviation
                splash.bounce = splash.bounce + 1
                splash.max_height = 2 * splash.max_height / 3
                splash.max_distance = 3 * splash.max_distance / 4
                splash.max_time = (1.25) * splash.max_time
                splash.init_x = splash.init_x + splash.x
                splash.init_y = splash.init_y + splash.y
                splash.x, splash.y, splash.height, splash.time = 0, 0, 0, 0
              elseif splash.bounce == splash.num_bounces then
                -- Disappear. Add semitransparency.
                splash.bounce = splash.bounce + 1
                splash.opacity = 255
                splash.height = 0
                splash.disappear = true
              end
            end
          else -- Destroy stone after disappearing.
            splash.opacity = math.max(0, splash.opacity - 1)
            if splash.opacity <= 0 then
              splash.disappear = nil
              splash.exists = false
              num_splashes = num_splashes - 1
            end
          end
        end
      end
      return true
    end)
  end
  -- Do not suspend hail when paused.
  timers["stone_creation_timer"]:set_suspended_with_map(false)
  timers["stone_position_timer"]:set_suspended_with_map(false)
end

-- Fade in/out dark surface for hailstorm mode. Parameter (opacity) is optional.
function hail_manager:update_darkness()
  -- Define next darkness value.
  local darkness = 0
  if current_hail_mode == "hail" then
    darkness = hail_darkness
  elseif current_hail_mode == "hailstorm" then
    darkness = hailstorm_darkness
  end
  local d = 0 -- Increment/decrement for opacity.
  if darkness > current_darkness then d = 1
  elseif darkness < current_darkness then d = -1 end
  self:stop_timers({"darkness_timer"}) -- Destroy old timer.
  -- Start modifying darkness towards the next value.
  timers["darkness_timer"] = sol.timer.start(current_game, 40, function()
    if dark_surface == nil then return end
    current_darkness = current_darkness + d
    local r = math.floor(color_darkness[1] * (current_darkness / 255))
    local g = math.floor(color_darkness[2] * (current_darkness / 255))
    local b = math.floor(color_darkness[3] * (current_darkness / 255))
    dark_surface:clear()
    dark_surface:fill_color({r, g, b})
    if darkness == current_darkness then -- Darkness reached.
      return false
    end
    return true -- Keep modifying darkness value.
  end)
  timers["darkness_timer"]:set_suspended_with_map(false)
end

-- Add scrolling features to teletransporters.
function hail_manager:initialize_scrolling_feature()
  local tele_meta = sol.main.get_metatable("teletransporter")
  tele_meta:register_event("on_activated", function(tele)
    local dir = tele:get_scrolling_direction()
    if dir then hail_manager:start_scrolling(dir) end
  end)
end

-- Start scrolling feature: shift 5 pixels each 10 milliseconds (like the engine).
function hail_manager:start_scrolling(direction)
  is_scrolling = true
  local dx = {[0] = -1, [1] = 0, [2] = 1, [3] = 0}
  local dy = {[0] = 0, [1] = -1, [2] = 0, [3] = 1}
  dx, dy = dx[direction], dy[direction]
  self:stop_timers({"scrolling"}) -- Needed in case of consecutive teleportation.
  timers["scrolling"] = sol.timer.start(current_game, 10, function()
    sx, sy = sx + 5 * dx, sy - 5 * dy
    if is_scrolling then return true
    else timers["scrolling"] = nil end
  end)
  timers["scrolling"]:set_suspended_with_map(false)
end
-- Stop scrolling feature.
function hail_manager:finish_scrolling()
  local map = current_map
  map:register_event("on_opening_transition_finished", function(map)
    is_scrolling = false
  end)
end

-- Return hail manager.
return hail_manager