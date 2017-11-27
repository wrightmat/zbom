-- Rain manager script.
-- Author: Diarandor (Solarus Team).
-- License: GPL v3-or-later.
-- Donations: solarus-games.org, diarandor at gmail dot com.

--[[   Instructions:
To add this script to your game, call from game_manager script:
    require("scripts/weather/rain_manager")

The functions here defined are:
    game:get_rain_mode()
    game:set_rain_mode(rain_mode)
    game:get_world_rain_mode(world)
    game:set_world_rain_mode(world, rain_mode)

Rain modes: "rain", "storm", nil (no rain).
--]]

local rain_manager = {}

local game_meta = sol.main.get_metatable("game")
local map_meta = sol.main.get_metatable("map")

-- Assets: sounds and sprites.
local drop_sprite = sol.sprite.create("weather/rain")
local thunder_sounds = {"thunder1", "thunder2", "thunder3", "thunder_far", "thunder_double"}

-- Default settings. Change these for testing.
local rain_speed, storm_speed = 140, 220 -- In pixels per second.
local drop_min_distance, drop_max_distance = 40, 300
local rain_drop_delay, storm_drop_delay = 10, 5 -- In milliseconds.
local lightning_duration = 800 -- In milliseconds.
local max_lightning_opacity = 255 -- (Opaque = 255).
local min_lightning_delay, max_lightning_delay = 3000, 15000
local min_thunder_delay, max_thunder_delay = 500, 2500 
local min_darkness, max_darkness = 120, 200 -- Opacity during storm.
local current_darkness = 0 -- Opacity (transparent = 0, opaque = 255).
local color_darkness = {150, 150, 240} -- Used for full darkness.
local max_num_drops_rain, max_num_drops_storm = 120, 300
local sx, sy = 0, 0 -- Scrolling shifts for drop positions.

-- Main variables.
local rain_surface, flash_surface, dark_surface, draw_flash_surface
local drop_list, splash_list, timers, num_drops, num_splashes
local current_game, current_map, current_rain_mode, previous_rain_mode
local previous_world, current_world, is_scrolling

-- Get/set current rain mode in the current map.
function game_meta:get_rain_mode() return current_rain_mode end
function game_meta:set_rain_mode(rain_mode)
  previous_world = current_world
  rain_manager:start_rain_mode(rain_mode)
end
-- Get/set the rain mode for a given world.
function game_meta:get_world_rain_mode(world)
  return world and self:get_value("rain_mode_" .. world) or nil
end
function game_meta:set_world_rain_mode(world, rain_mode)
  self:set_value("rain_mode_" .. world, rain_mode)
  if current_world == world then self:set_rain_mode(rain_mode) end
end

-- Initialize rain manager.
game_meta:register_event("on_started", function(game)
  current_game = game
  rain_manager:on_created()
end)
-- Initialize rain on maps when necessary.
game_meta:register_event("on_map_changed", function(game)
  rain_manager:on_map_changed(game:get_map())
end)
-- Allow to draw surfaces (it uses the event "game.on_draw").
game_meta:register_event("on_draw", function(game, dst_surface)
  rain_manager:on_draw(dst_surface)
end)

-- Create rain, dark and lightning surfaces.
function rain_manager:on_created()
  -- Create surfaces.
  local w, h = sol.video.get_quest_size()
  rain_surface = sol.surface.create(w, h)
  dark_surface = sol.surface.create(w, h)
  flash_surface = sol.surface.create(w, h)
  dark_surface:set_blend_mode("multiply")
  flash_surface:fill_color({250, 250, 250})
  flash_surface:set_blend_mode("add")
  -- Initialize main variables.
  current_rain_mode, previous_rain_mode, previous_world = nil, nil, nil
  num_drops, num_splashes, current_darkness = 0, 0, 0
  draw_flash_surface = false
  drop_list, splash_list, timers = {}, {}, {}
  local num_slots = math.max(max_num_drops_rain, max_num_drops_storm)
  for i = 0, num_slots - 1 do  
    drop_list[i] = {index = i}
    splash_list[i] = {index = i}
  end
  -- Add scrolling feature with teletransporters.
  self:initialize_scrolling_feature()
end

-- Update current_rain_mode and current_map variables.
function rain_manager:on_map_changed(map)
  local world = map:get_world()
  current_map = map
  previous_world = current_world
  current_world = world
  local rain_mode = current_game:get_world_rain_mode(world)
  self:start_rain_mode(rain_mode)
  if is_scrolling then self:finish_scrolling() end
end

-- Draw surfaces of the rain manager.
function rain_manager:on_draw(dst_surface)
  if current_rain_mode == nil then
    if previous_rain_mode == nil or previous_world ~= current_world then
      return
    end
  end
  -- Draw surfaces on the current map if necessary.
  if rain_surface and (num_drops > 0 or num_splashes > 0) then
    self:update_rain_surface()
    rain_surface:draw(dst_surface)
  end
  if dark_surface and current_darkness > 0 then
    dark_surface:draw(dst_surface)
  end
  if draw_flash_surface and flash_surface then
    flash_surface:draw(dst_surface)
  end
end

-- Update rain surface.
function rain_manager:update_rain_surface()
  if current_rain_mode == nil and previous_rain_mode == nil then
    return
  end
  rain_surface:clear()
  local camera = current_map:get_camera()
  local cx, cy, cw, ch = camera:get_bounding_box()
  -- Draw drops on surface.
  drop_sprite:set_animation("drop")
  for _, drop in pairs(drop_list) do
    if drop.exists then
      drop_sprite:set_frame(drop.frame)
      local x = (drop.init_x + drop.x - cx + sx) % cw
      local y = (drop.init_y + drop.y - cy + sy) % ch
      drop_sprite:draw(rain_surface, x, y)
    end
  end
  -- Draw splashes on surface.
  drop_sprite:set_animation("drop_splash")
  for _, splash in pairs(splash_list) do
    if splash.exists then
      drop_sprite:set_frame(splash.frame)
      local x = (splash.x - cx + sx) % cw
      local y = (splash.y - cy + sy) % ch
      drop_sprite:draw(rain_surface, x, y)
    end
  end
end

-- Create properties list for a new water drop at random position.
function rain_manager:create_drop(deviation)
  -- Prepare next slot.
  local max_num_drops = max_num_drops_rain
  if current_rain_mode == "storm" then max_num_drops = max_num_drops_storm end
  local index, drop = 0, drop_list[0]
  while index < max_num_drops and drop.exists do
    index = index + 1
    drop = drop_list[index]
  end
  if drop == nil or drop.exists then return end
  -- Set properties for new drop.
  local map = current_map
  local cx, cy, cw, ch = map:get_camera():get_bounding_box()
  drop.init_x = cx + cw * math.random()
  drop.init_y = cy + ch * math.random()
  drop.x, drop.y, drop.frame = 0, 0, 0
  drop.speed = (current_rain_mode == "rain") and rain_speed or storm_speed
  drop.angle = 7 * math.pi / 5 + (deviation or 0)
  drop.max_distance = math.random(drop_min_distance, drop_max_distance)
  num_drops = num_drops + 1
  drop.exists = true
end

-- Create splash effect and put it in the list.
function rain_manager:create_splash(index)
  -- Diable associated drop.
  local drop = drop_list[index]
  num_drops = num_drops - 1
  -- Do nothing if there is no space for a new splash.
  local splash = splash_list[index]
  if splash.exists then return end
  -- Create splash.
  splash.x = drop.init_x + drop.x
  splash.y = drop.init_y + drop.y
  splash.frame = 0
  num_splashes = num_splashes + 1
  splash.exists = true
end

-- Destroy the timers whose names appear in the list.
function rain_manager:stop_timers(timers_list)
  for _, key  in pairs(timers_list) do
    local t = timers[key]
    if t then t:stop() end
    timers[key] = nil
  end
end

-- Start a rain mode in the current map.
function rain_manager:start_rain_mode(rain_mode)
  -- Update rain modes.
  previous_rain_mode = current_rain_mode
  current_rain_mode = rain_mode
  -- Stop creating drops and lightnings (timer delays differ on each mode).
  self:stop_timers({"drop_creation_timer", "lightning_creation_timer"})
  -- Update darkness (fade-out effects included).
  self:update_darkness()
  -- Nothing more to do if there is no rain.
  if rain_mode == nil then return end
  --Initialize drop parameters (used by "rain_manager.create_drop").
  local game = current_game
  local current_drop_delay
  if rain_mode == "rain" then current_drop_delay = rain_drop_delay
  elseif rain_mode == "storm" then current_drop_delay = storm_drop_delay
  elseif rain_mode ~= nil then error("Invalid rain mode.") end
  -- Start lightnings if necessary.
  if rain_mode == "storm" then self:start_lightnings() end
  -- Initialize drop creation timer.
  timers["drop_creation_timer"] = sol.timer.start(game, current_drop_delay, function()
    -- Random angle deviation in case of storm.
    local drop_deviation = 0
    if rain_mode == "storm" then
      drop_deviation = math.random(-1, 1) * math.random() * math.pi / 8
    end
    rain_manager:create_drop(drop_deviation)
    return true -- Repeat loop.
  end)
  -- Initialize drop position timer.
  if timers["drop_position_timer"] == nil then
    local dt = 10 -- Timer delay.
    timers["drop_position_timer"] = sol.timer.start(game, dt, function()
      for index, drop in pairs(drop_list) do
        if drop.exists then
          local distance_increment = drop.speed * (dt / 1000)
          drop.x = drop.x + distance_increment * math.cos(drop.angle)
          drop.y = drop.y + distance_increment * math.sin(drop.angle) * (-1)
          local distance = math.sqrt((drop.x)^2 + (drop.y)^2)
          if distance >= drop.max_distance then
            -- Disable drop and create drop splash.
            drop.exists = false
            rain_manager:create_splash(index)
          end
        end
      end
      return true
    end)
  end
  -- Update rain frames for all drops at once.
  if timers["drop_frame_timer"] == nil then
    timers["drop_frame_timer"] = sol.timer.start(game, 75, function()
      for _, drop in pairs(drop_list) do
        if drop.exists then
          drop.frame = (drop.frame + 1) % 3
        end
      end
      return true
    end)
  end
  -- Update splash frames for all splashes at once.
  if timers["splash_frame_timer"] == nil then
    timers["splash_frame_timer"] = sol.timer.start(game, 100, function()
      for index, splash in pairs(splash_list) do
        if splash.exists then
          splash.frame = splash.frame + 1
          if splash.frame >= 4 then
            -- Disable splash after last frame.
            splash.exists = false
            num_splashes = num_splashes - 1
          end
        end
      end
      return true
    end)
  end
  -- Do not suspend rain when paused.
  timers["drop_creation_timer"]:set_suspended_with_map(false)
  timers["drop_position_timer"]:set_suspended_with_map(false)
  timers["drop_frame_timer"]:set_suspended_with_map(false)
  timers["splash_frame_timer"]:set_suspended_with_map(false)
end

-- Start lightnings in the current map.
function rain_manager:start_lightnings()
  -- Play thunder sound after a random delay.
  if timers["lightning_creation_timer"] ~= nil then return end
  local game = current_game
  local function create_next_lightning()
    flash_surface:set_opacity(255)
    local lightning_delay = math.random(min_lightning_delay, max_lightning_delay)
    timers["lightning_creation_timer"] = sol.timer.start(game, lightning_delay, function()
      -- Create lightning flash.
      draw_flash_surface = true
      local dt = 0 -- Time.
      timers["lightning_duration_timer"] = sol.timer.start(game, 10, function()
        dt = dt + 10
        -- Decrease lightning brightness with a quadratic curve.
        local op = max_lightning_opacity * (1 - (dt / lightning_duration)^2)
        op = math.max(0, math.floor(op))
        flash_surface:set_opacity(op)
        if op == 0 then
          draw_flash_surface = false -- Stop drawing lightning flash.
          return
        end
        return true
      end)
      timers["lightning_duration_timer"]:set_suspended_with_map(false)
      -- Play random thunder sound after a delay.
      local thunder_delay = math.random(min_thunder_delay, max_thunder_delay)
      sol.timer.start(game, thunder_delay, function()
        local random_index = math.random(1, #thunder_sounds)
        local sound_id = thunder_sounds[random_index]
        sol.audio.play_sound(sound_id)
      end)
      -- Start next loop of lightnings.
      create_next_lightning()
    end)
    -- Do not suspend timer when paused.
    timers["lightning_creation_timer"]:set_suspended_with_map(false)
  end
  -- Start loop of lightnings.
  create_next_lightning()
end

-- Fade in/out dark surface for storm mode. Parameter (opacity) is optional.
function rain_manager:update_darkness()
  -- Define next darkness value.
  local darkness = 0
  if current_rain_mode == "storm" then
    darkness = math.random(min_darkness, max_darkness)
  end
  local d = 0 -- Increment/decrement for opacity.
  if darkness > current_darkness then d = 1
  elseif darkness < current_darkness then d = -1 end
  self:stop_timers({"darkness_timer"}) -- Destroy old timer.
  -- Start modifying darkness towards the next value.
  timers["darkness_timer"] = sol.timer.start(current_game, 15, function()
    if dark_surface == nil then return end
    current_darkness = current_darkness + d
    local r = 255 - math.floor(color_darkness[1] * (current_darkness / 255))
    local g = 255 - math.floor(color_darkness[2] * (current_darkness / 255))
    local b = 255 - math.floor(color_darkness[3] * (current_darkness / 255))
    dark_surface:clear()
    dark_surface:fill_color({r, g, b})
    if darkness == current_darkness then -- Darkness reached.
      if current_rain_mode == "storm" then -- Storm mode.
        self:update_darkness() -- Repeat process with new random darkness value.
      end
      return false
    end
    return true -- Keep modifying darkness value.
  end)
  timers["darkness_timer"]:set_suspended_with_map(false)
end

-- Add scrolling features to teletransporters.
function rain_manager:initialize_scrolling_feature()
  local tele_meta = sol.main.get_metatable("teletransporter")
  tele_meta:register_event("on_activated", function(tele)
    local dir = tele:get_scrolling_direction()
    if dir then rain_manager:start_scrolling(dir) end
  end)
end

-- Start scrolling feature: shift 5 pixels each 10 milliseconds (like the engine).
function rain_manager:start_scrolling(direction)
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
function rain_manager:finish_scrolling()
  local map = current_map
  map:register_event("on_opening_transition_finished", function(map)
    is_scrolling = false
  end)
end

-- Return rain manager.
return rain_manager