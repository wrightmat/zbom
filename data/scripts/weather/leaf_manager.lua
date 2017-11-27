-- Leaf manager script.
-- From "snow manager" script by Diarandor (Solarus Team). Modified by froggy77.
-- License: GPL v3-or-later.
-- Donations: solarus-games.org, diarandor at gmail dot com.

--[[   Instructions:
To add this script to your game, call from game_manager script:
    require("scripts/weather/leaf_manager")

The functions here defined are:
    game:get_leaf_mode()
    game:set_leaf_mode(leaf_mode)
    game:get_world_leaf_mode(world)
    game:set_world_leaf_mode(world, leaf_mode)

fall modes: "leaf", "leaf_storm", nil (no leaves).
--]]

local leaf_manager = {}

local game_meta = sol.main.get_metatable("game")
local map_meta = sol.main.get_metatable("map")

-- Assets: sounds and sprites.
local leaf_sprite = sol.sprite.create("weather/leaf")

-- Default settings. Change these for testing.
local fall_speed, fall_storm_speed = 40, 80 -- In pixels per second.
local leaf_min_distance, leaf_max_distance = 40, 300
local leaf_min_zigzag_distance, leaf_max_zigzag_distance = 100, 300
local fall_leaf_delay, fall_storm_leaf_delay = 10, 5 -- In milliseconds.
local min_darkness, max_darkness = 60, 120 -- Opacity during fall_storm.
local current_darkness = 0 -- Opacity (transparent = 0, opaque = 255).
local color_darkness = {248, 96, 40} -- Used for full darkness.
local max_num_leaves_fall, max_num_leaves_fall_storm = 15, 30
local leaf_min_opacity, leaf_max_opacity = 128, 255
local sx, sy = 0, 0 -- Scrolling shifts for leaf positions.

-- Main variables.
local fall_surface, dark_surface, leaf_surface
local leaf_list, splash_list, timers, num_leaves, num_splashes
local current_game, current_map, current_fall_mode, previous_fall_mode
local previous_world, current_world, is_scrolling

-- Get/set current fall mode in the current map.
function game_meta:get_leaf_mode() return current_leaf_mode end
function game_meta:set_leaf_mode(fall_mode)
  previous_world = current_world
  leaf_manager:start_leaf_mode(leaf_mode)
end
-- Get/set the fall mode for a given world.
function game_meta:get_world_leaf_mode(world)
  return world and self:get_value("leaf_mode_" .. world) or nil
end
function game_meta:set_world_leaf_mode(world, leaf_mode)
  self:set_value("leaf_mode_" .. world, leaf_mode)
  if current_world == world then self:set_leaf_mode(leaf_mode) end
end

-- Initialize fall manager.
game_meta:register_event("on_started", function(game)
  current_game = game
  leaf_manager:on_created()
end)
-- Initialize fall on maps when necessary.
game_meta:register_event("on_map_changed", function(game)
  leaf_manager:on_map_changed(game:get_map())
end)
-- Allow to draw surfaces (it uses the event "game.on_draw").
game_meta:register_event("on_draw", function(game, dst_surface)
  leaf_manager:on_draw(dst_surface)
end)

-- Create fall and dark surfaces.
function leaf_manager:on_created()
  -- Create surfaces.
  local w, h = sol.video.get_quest_size()
  fall_surface = sol.surface.create(w, h)
  dark_surface = sol.surface.create(w, h)
  fall_surface:set_blend_mode("add")
  dark_surface:set_blend_mode("multiply")
  leaf_surface = sol.surface.create(8, 8)
  -- Initialize main variables.
  current_leaf_mode, previous_leaf_mode, previous_world = nil, nil, nil
  num_leaves, num_splashes, current_darkness = 0, 0, 0
  leaf_list, splash_list, timers = {}, {}, {}
  local num_slots = math.max(max_num_leaves_fall, max_num_leaves_fall_storm)
  for i = 0, num_slots - 1 do  
    leaf_list[i] = {index = i}
    splash_list[i] = {index = i}
  end
  -- Add scrolling feature with teletransporters.
  self:initialize_scrolling_feature()
end

-- Update current_fall_mode and current_map variables.
function leaf_manager:on_map_changed(map)
  local world = map:get_world()
  current_map = map
  previous_world = current_world
  current_world = world
  local leaf_mode = current_game:get_world_leaf_mode(world)
  self:start_leaf_mode(leaf_mode)
  if is_scrolling then self:finish_scrolling() end
end

-- Draw surfaces of the fall manager.
function leaf_manager:on_draw(dst_surface)
  if current_leaf_mode == nil then
    if previous_leaf_mode == nil or previous_world ~= current_world then
      return
    end
  end
  -- Draw surfaces on the current map if necessary.
  if fall_surface and (num_leaves > 0 or num_splashes > 0) then
    self:update_fall_surface()
    fall_surface:draw(dst_surface)
  end
  if dark_surface and current_darkness > 0 then
    dark_surface:draw(dst_surface)
  end
end

-- Draw a falling leaf or splash on a surface with its properties (Opacity = 0 means transparent).
function leaf_manager:draw_leaf(dst_surface, x, y, leaf, animation)
  leaf_sprite:set_animation(animation)
  leaf_sprite:set_direction(leaf.direction or 0)
  leaf_sprite:set_frame(leaf.frame or 0)
  leaf_surface:clear()
  leaf_sprite:draw(leaf_surface)
  leaf_surface:set_opacity(leaf.opacity)
  leaf_surface:draw(dst_surface, x, y)
end

-- Update fall surface.
function leaf_manager:update_fall_surface()
  if current_leaf_mode == nil and previous_leaf_mode == nil then
    return
  end
  fall_surface:clear()
  local camera = current_map:get_camera()
  local cx, cy, cw, ch = camera:get_bounding_box()
  -- Draw leaves on surface.
  for _, leaf in pairs(leaf_list) do
    if leaf.exists then
      local x = (leaf.init_x + leaf.x - cx + sx) % cw
      local y = (leaf.init_y + leaf.y - cy + sy) % ch
      self:draw_leaf(fall_surface, x, y, leaf, "leaf")
    end
  end
  -- Draw splashes on surface.
  for _, splash in pairs(splash_list) do
    if splash.exists then
      local x = (splash.x - cx + sx) % cw
      local y = (splash.y - cy + sy) % ch
      self:draw_leaf(fall_surface, x, y, splash, "leaf_splash")
    end
  end
end

-- Create properties list for a new water leaf at random position.
function leaf_manager:create_leaf(deviation)
  -- Prepare next slot.
  local max_num_leaves = max_num_leaves_fall
  if current_leaf_mode == "fall_storm" then max_num_leaves = max_num_leaves_fall_storm end
  local index, leaf = 0, leaf_list[0]
  while index < max_num_leaves and leaf.exists do
    index = index + 1
    leaf = leaf_list[index]
  end
  if leaf == nil or leaf.exists then return end
  -- Set properties for new leaf.
  local map = current_map
  local cx, cy, cw, ch = map:get_camera():get_bounding_box()
  leaf.init_x = cx + cw * math.random()
  leaf.init_y = cy + ch * math.random()
  leaf.x, leaf.y, leaf.frame = 0, 0, 0
  leaf.speed = (current_fall_mode == "fall") and fall_speed or fall_storm_speed
  local num_dir = leaf_sprite:get_num_directions("leaf")
  leaf.direction = math.random(0, num_dir - 1) -- Sprite direction.
  local inverted_angle = (math.random(0,1) == 1)
  leaf.angle = 7 * math.pi / 5 + (deviation or 0)
  if inverted_angle then leaf.angle = math.pi - leaf.angle end
  leaf.max_distance = math.random(leaf_min_distance, leaf_max_distance)
  leaf.zigzag_dist = math.random(leaf_min_zigzag_distance, leaf_max_zigzag_distance)
  leaf.opacity = 255
  leaf.target_opacity = math.random(leaf_min_opacity, leaf_max_opacity)
  num_leaves = num_leaves + 1
  leaf.exists = true
end

-- Create splash effect and put it in the list.
function leaf_manager:create_splash(index)
  -- Disable associated leaf.
  local leaf = leaf_list[index]
  num_leaves = num_leaves - 1
  -- Do nothing if there is no space for a new splash.
  local splash = splash_list[index]
  if splash.exists then return end
  -- Create splash.
  splash.x = leaf.init_x + leaf.x
  splash.y = leaf.init_y + leaf.y
  splash.opacity = leaf.opacity
  num_splashes = num_splashes + 1
  splash.direction =  leaf.direction
  splash.exists = true
end

-- Destroy the timers whose names appear in the list.
function leaf_manager:stop_timers(timers_list)
  for _, key  in pairs(timers_list) do
    local t = timers[key]
    if t then t:stop() end
    timers[key] = nil
  end
end

-- Start a fall mode in the current map.
function leaf_manager:start_leaf_mode(fall_mode)
  -- Update fall modes.
  previous_fall_mode = current_fall_mode
  current_fall_mode = fall_mode
  -- Stop creating leaves (timer delays differ on each mode).
  self:stop_timers({"leaf_creation_timer"})
  -- Update darkness (fade-out effects included).
  self:update_darkness()
  -- Nothing more to do if there is no fall.
  if leaf_mode == nil then return end
  --Initialize leaf parameters (used by "fall_manager.create_leaf").
  local game = current_game
  local current_leaf_delay
  if leaf_mode == "fall" then current_leaf_delay = fall_leaf_delay
  elseif leaf_mode == "fall_storm" then current_leaf_delay = fall_storm_leaf_delay
  elseif leaf_mode ~= nil then error("Invalid fall mode.") end
  -- Initialize leaf creation timer.
  timers["leaf_creation_timer"] = sol.timer.start(game, current_leaf_delay, function()
    -- Random angle deviation in case of fall_storm.
    local leaf_deviation = 0
    if leaf_mode == "fall_storm" then
      leaf_deviation = math.random(-1, 1) * math.random() * math.pi / 8
    end
    leaf_manager:create_leaf(leaf_deviation)
    return true -- Repeat loop.
  end)
  -- Initialize leaf position timer.
  if timers["leaf_position_timer"] == nil then
    local dt = 10 -- Timer delay.
    timers["leaf_position_timer"] = sol.timer.start(game, dt, function()
      for index, leaf in pairs(leaf_list) do
        if leaf.exists then
          local distance_increment = leaf.speed * (dt / 1000)
          leaf.x = leaf.x + distance_increment * math.cos(leaf.angle)
          leaf.y = leaf.y + distance_increment * math.sin(leaf.angle) * (-1)
          local distance = math.sqrt((leaf.x)^2 + (leaf.y)^2)
          if distance > leaf.zigzag_dist then
            local d = math.random(leaf_min_zigzag_distance, leaf_max_zigzag_distance)
            leaf.zigzag_dist = leaf.zigzag_dist + d
            leaf.angle = math.pi - leaf.angle -- Reflected angle.
          end      
          if distance >= leaf.max_distance then
            -- Disable leaf and create leaf splash.
            leaf.exists = false
            fall_manager:create_splash(index)
          end
        end
      end
      return true
    end)
  end
  -- Update fall frames for all leaves at once.
  if timers["leaf_frame_timer"] == nil then
    timers["leaf_frame_timer"] = sol.timer.start(game, 250, function()
      for _, leaf in pairs(leaf_list) do
        if leaf.exists then
          leaf.frame = (leaf.frame + 1) % 4
        end
      end
      return true
    end)
  end
  -- Update splash frames for all splashes at once.
  if timers["leaf_opacity_timer"] == nil then
    timers["leaf_opacity_timer"] = sol.timer.start(game, 10, function()
      for _, leaf in pairs(leaf_list) do
        if leaf.exists then
          -- Modify opacity towards the target opacity.
          if leaf.opacity == leaf.target_opacity then
            leaf.target_opacity = math.random(leaf_min_opacity, leaf_max_opacity)
          else
            local d = (leaf.opacity < leaf.target_opacity) and 1 or -1
            leaf.opacity = leaf.opacity + d
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
  -- Do not suspend fall when paused.
  timers["leaf_creation_timer"]:set_suspended_with_map(false)
  timers["leaf_position_timer"]:set_suspended_with_map(false)
  timers["leaf_frame_timer"]:set_suspended_with_map(false)
  timers["leaf_opacity_timer"]:set_suspended_with_map(false)
end

-- Fade in/out dark surface for fall_storm mode. Parameter (opacity) is optional.
function leaf_manager:update_darkness()
  -- Define next darkness value.
  local darkness = 0
  if current_fall_mode == "fall_storm" then
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
      if current_fall_mode == "fall_storm" then -- fall_storm mode.
        self:update_darkness() -- Repeat process with new random darkness value.
      end
      return false
    end
    return true -- Keep modifying darkness value.
  end)
  timers["darkness_timer"]:set_suspended_with_map(false)
end

-- Add scrolling features to teletransporters.
function leaf_manager:initialize_scrolling_feature()
  local tele_meta = sol.main.get_metatable("teletransporter")
  tele_meta:register_event("on_activated", function(tele)
    local dir = tele:get_scrolling_direction()
    if dir then leaf_manager:start_scrolling(dir) end
  end)
end

-- Start scrolling feature: shift 5 pixels each 10 milliseconds (like the engine).
function leaf_manager:start_scrolling(direction)
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
function leaf_manager:finish_scrolling()
  local map = current_map
  map:register_event("on_opening_transition_finished", function(map)
    is_scrolling = false
  end)
end

-- Return leaf manager.
return leaf_manager