-- Snow manager script.
-- Author: Diarandor (Solarus Team).
-- License: GPL v3-or-later.
-- Donations: solarus-games.org, diarandor at gmail dot com.

--[[   Instructions:
To add this script to your game, call from game_manager script:
    require("scripts/weather/snow_manager")

The functions here defined are:
    game:get_snow_mode()
    game:set_snow_mode(snow_mode)
    game:get_world_snow_mode(world)
    game:set_world_snow_mode(world, snow_mode)

snow modes: "snow", "snowstorm", nil (no snow).
--]]

local snow_manager = {}

local game_meta = sol.main.get_metatable("game")
local map_meta = sol.main.get_metatable("map")

-- Assets: sounds and sprites.
local flake_sprite = sol.sprite.create("weather/snow")

-- Default settings. Change these for testing.
local snow_speed, snowstorm_speed = 60, 140 -- In pixels per second.
local flake_min_distance, flake_max_distance = 40, 300
local flake_min_zigzag_distance, flake_max_zigzag_distance = 10, 250
local snow_flake_delay, snowstorm_flake_delay = 10, 5 -- In milliseconds.
local snow_darkness, snowstorm_darkness = 50, 90 -- Opacity during snowstorm.
local current_darkness = 0 -- Opacity (transparent = 0, opaque = 255).
local color_darkness = {100, 100, 255} -- Used for full darkness.
local max_num_flakes_snow, max_num_flakes_snowstorm = 100, 200
local flake_min_opacity, flake_max_opacity = 50, 255
local sx, sy = 0, 0 -- Scrolling shifts for flake positions.

-- Main variables.
local snow_surface, dark_surface, flake_surface
local flake_list, splash_list, timers, num_flakes, num_splashes
local current_game, current_map, current_snow_mode, previous_snow_mode
local previous_world, current_world, is_scrolling

-- Get/set current snow mode in the current map.
function game_meta:get_snow_mode() return current_snow_mode end
function game_meta:set_snow_mode(snow_mode)
  previous_world = current_world
  snow_manager:start_snow_mode(snow_mode)
end
-- Get/set the snow mode for a given world.
function game_meta:get_world_snow_mode(world)
  return world and self:get_value("snow_mode_" .. world) or nil
end
function game_meta:set_world_snow_mode(world, snow_mode)
  self:set_value("snow_mode_" .. world, snow_mode)
  if current_world == world then self:set_snow_mode(snow_mode) end
end

-- Initialize snow manager.
game_meta:register_event("on_started", function(game)
  current_game = game
  snow_manager:on_created()
end)
-- Initialize snow on maps when necessary.
game_meta:register_event("on_map_changed", function(game)
  snow_manager:on_map_changed(game:get_map())
end)
-- Allow to draw surfaces (it uses the event "game.on_draw").
game_meta:register_event("on_draw", function(game, dst_surface)
  snow_manager:on_draw(dst_surface)
end)

-- Create snow and dark surfaces.
function snow_manager:on_created()
  -- Create surfaces.
  local w, h = sol.video.get_quest_size()
  snow_surface = sol.surface.create(w, h)
  dark_surface = sol.surface.create(w, h)
  snow_surface:set_blend_mode("add")
  dark_surface:set_blend_mode("add")
  flake_surface = sol.surface.create(8, 8)
  -- Initialize main variables.
  current_snow_mode, previous_snow_mode, previous_world = nil, nil, nil
  num_flakes, num_splashes, current_darkness = 0, 0, 0
  flake_list, splash_list, timers = {}, {}, {}
  local num_slots = math.max(max_num_flakes_snow, max_num_flakes_snowstorm)
  for i = 0, num_slots - 1 do  
    flake_list[i] = {index = i}
    splash_list[i] = {index = i}
  end
  -- Add scrolling feature with teletransporters.
  self:initialize_scrolling_feature()
end

-- Update current_snow_mode and current_map variables.
function snow_manager:on_map_changed(map)
  local world = map:get_world()
  current_map = map
  previous_world = current_world
  current_world = world
  local snow_mode = current_game:get_world_snow_mode(world)
  self:start_snow_mode(snow_mode)
  if is_scrolling then self:finish_scrolling() end
end

-- Draw surfaces of the snow manager.
function snow_manager:on_draw(dst_surface)
  if current_snow_mode == nil then
    if previous_snow_mode == nil or previous_world ~= current_world then
      return
    end
  end
  -- Draw surfaces on the current map if necessary.
  if snow_surface and (num_flakes > 0 or num_splashes > 0) then
    self:update_snow_surface()
    snow_surface:draw(dst_surface)
  end
  if dark_surface and current_darkness > 0 then
    dark_surface:draw(dst_surface)
  end
end

-- Draw snowflake or splash on a surface with its properties (Opacity = 0 means transparent).
function snow_manager:draw_flake(dst_surface, x, y, flake, animation)
  flake_sprite:set_animation(animation)
  flake_sprite:set_direction(flake.direction or 0)
  flake_sprite:set_frame(flake.frame or 0)
  flake_surface:clear()
  flake_sprite:draw(flake_surface)
  flake_surface:set_opacity(flake.opacity)
  flake_surface:draw(dst_surface, x, y)
end

-- Update snow surface.
function snow_manager:update_snow_surface()
  if current_snow_mode == nil and previous_snow_mode == nil then
    return
  end
  snow_surface:clear()
  local camera = current_map:get_camera()
  local cx, cy, cw, ch = camera:get_bounding_box()
  -- Draw flakes on surface.
  for _, flake in pairs(flake_list) do
    if flake.exists then
      local x = (flake.init_x + flake.x - cx + sx) % cw
      local y = (flake.init_y + flake.y - cy + sy) % ch
      self:draw_flake(snow_surface, x, y, flake, "flake")
    end
  end
  -- Draw splashes on surface.
  for _, splash in pairs(splash_list) do
    if splash.exists then
      local x = (splash.x - cx + sx) % cw
      local y = (splash.y - cy + sy) % ch
      self:draw_flake(snow_surface, x, y, splash, "flake_splash")
    end
  end
end

-- Create properties list for a new water flake at random position.
function snow_manager:create_flake(deviation)
  -- Prepare next slot.
  local max_num_flakes = max_num_flakes_snow
  if current_snow_mode == "snowstorm" then max_num_flakes = max_num_flakes_snowstorm end
  local index, flake = 0, flake_list[0]
  while index < max_num_flakes and flake.exists do
    index = index + 1
    flake = flake_list[index]
  end
  if flake == nil or flake.exists then return end
  -- Set properties for new flake.
  local map = current_map
  local cx, cy, cw, ch = map:get_camera():get_bounding_box()
  flake.init_x = cx + cw * math.random()
  flake.init_y = cy + ch * math.random()
  flake.x, flake.y, flake.frame = 0, 0, 0
  flake.speed = (current_snow_mode == "snow") and snow_speed or snowstorm_speed
  local num_dir = flake_sprite:get_num_directions("flake")
  flake.direction = math.random(0, num_dir - 1) -- Sprite direction.
  local inverted_angle = (math.random(0,1) == 1)
  flake.angle = 7 * math.pi / 5 + (deviation or 0)
  if inverted_angle then flake.angle = math.pi - flake.angle end
  flake.max_distance = math.random(flake_min_distance, flake_max_distance)
  flake.zigzag_dist = math.random(flake_min_zigzag_distance, flake_max_zigzag_distance)
  flake.opacity = 255
  flake.target_opacity = math.random(flake_min_opacity, flake_max_opacity)
  num_flakes = num_flakes + 1
  flake.exists = true
end

-- Create splash effect and put it in the list.
function snow_manager:create_splash(index)
  -- Diable associated flake.
  local flake = flake_list[index]
  num_flakes = num_flakes - 1
  -- Do nothing if there is no space for a new splash.
  local splash = splash_list[index]
  if splash.exists then return end
  -- Create splash.
  splash.x = flake.init_x + flake.x
  splash.y = flake.init_y + flake.y
  splash.opacity = flake.opacity
  num_splashes = num_splashes + 1
  splash.exists = true
end

-- Destroy the timers whose names appear in the list.
function snow_manager:stop_timers(timers_list)
  for _, key  in pairs(timers_list) do
    local t = timers[key]
    if t then t:stop() end
    timers[key] = nil
  end
end

-- Start a snow mode in the current map.
function snow_manager:start_snow_mode(snow_mode)
  -- Update snow modes.
  previous_snow_mode = current_snow_mode
  current_snow_mode = snow_mode
  -- Stop creating flakes (timer delays differ on each mode).
  self:stop_timers({"flake_creation_timer"})
  -- Update darkness (fade-out effects included).
  self:update_darkness()
  -- Nothing more to do if there is no snow.
  if snow_mode == nil then return end
  --Initialize flake parameters (used by "snow_manager.create_flake").
  local game = current_game
  local current_flake_delay
  if snow_mode == "snow" then current_flake_delay = snow_flake_delay
  elseif snow_mode == "snowstorm" then current_flake_delay = snowstorm_flake_delay
  elseif snow_mode ~= nil then error("Invalid snow mode.") end
  -- Initialize flake creation timer.
  timers["flake_creation_timer"] = sol.timer.start(game, current_flake_delay, function()
    -- Random angle deviation in case of snowstorm.
    local flake_deviation = 0
    if snow_mode == "snowstorm" then
      flake_deviation = math.random(-1, 1) * math.random() * math.pi / 8
    end
    snow_manager:create_flake(flake_deviation)
    return true -- Repeat loop.
  end)
  -- Initialize flake position timer.
  if timers["flake_position_timer"] == nil then
    local dt = 10 -- Timer delay.
    timers["flake_position_timer"] = sol.timer.start(game, dt, function()
      for index, flake in pairs(flake_list) do
        if flake.exists then
          local distance_increment = flake.speed * (dt / 1000)
          flake.x = flake.x + distance_increment * math.cos(flake.angle)
          flake.y = flake.y + distance_increment * math.sin(flake.angle) * (-1)
          local distance = math.sqrt((flake.x)^2 + (flake.y)^2)
          if distance > flake.zigzag_dist then
            local d = math.random(flake_min_zigzag_distance, flake_max_zigzag_distance)
            flake.zigzag_dist = flake.zigzag_dist + d
            flake.angle = math.pi - flake.angle -- Reflected angle.
          end      
          if distance >= flake.max_distance then
            -- Disable flake and create flake splash.
            flake.exists = false
            snow_manager:create_splash(index)
          end
        end
      end
      return true
    end)
  end
  -- Update snow frames for all flakes at once.
  if timers["flake_frame_timer"] == nil then
    timers["flake_frame_timer"] = sol.timer.start(game, 250, function()
      for _, flake in pairs(flake_list) do
        if flake.exists then
          flake.frame = (flake.frame + 1) % 4
        end
      end
      return true
    end)
  end
  -- Update splash frames for all splashes at once.
  if timers["flake_opacity_timer"] == nil then
    timers["flake_opacity_timer"] = sol.timer.start(game, 10, function()
      for _, flake in pairs(flake_list) do
        if flake.exists then
          -- Modify opacity towards the target opacity.
          if flake.opacity == flake.target_opacity then
            flake.target_opacity = math.random(flake_min_opacity, flake_max_opacity)
          else
            local d = (flake.opacity < flake.target_opacity) and 1 or -1
            flake.opacity = flake.opacity + d
          end
        end
      end
      for _, splash in pairs(splash_list) do
        if splash.exists then
          -- Disable splash when transparent.
          splash.opacity = math.max(0, splash.opacity - 1)
          if splash.opacity == 0 then
            splash.exists = false
            num_splashes = num_splashes - 1
          end
        end
      end
      return true
    end)
  end
  -- Do not suspend snow when paused.
  timers["flake_creation_timer"]:set_suspended_with_map(false)
  timers["flake_position_timer"]:set_suspended_with_map(false)
  timers["flake_frame_timer"]:set_suspended_with_map(false)
  timers["flake_opacity_timer"]:set_suspended_with_map(false)
end

-- Fade in/out dark surface for snowstorm mode. Parameter (opacity) is optional.
function snow_manager:update_darkness()
  -- Define next darkness value.
  local darkness = 0
  if current_snow_mode == "snow" then
    darkness = snow_darkness
  elseif current_snow_mode == "snowstorm" then
    darkness = snowstorm_darkness
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
function snow_manager:initialize_scrolling_feature()
  local tele_meta = sol.main.get_metatable("teletransporter")
  tele_meta:register_event("on_activated", function(tele)
    local dir = tele:get_scrolling_direction()
    if dir then snow_manager:start_scrolling(dir) end
  end)
end

-- Start scrolling feature: shift 5 pixels each 10 milliseconds (like the engine).
function snow_manager:start_scrolling(direction)
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
function snow_manager:finish_scrolling()
  local map = current_map
  map:register_event("on_opening_transition_finished", function(map)
    is_scrolling = false
  end)
end

-- Return snow manager.
return snow_manager