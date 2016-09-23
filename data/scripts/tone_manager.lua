-- Tone Manager
-- Manage time system tones and also light effects.

local game = ...
local tone_manager = {}

local mr, mg, mb, ma = nil, nil, nil, nil
local cr, cg, cb = nil  -- Create the current tone
local tr, tg, tb = nil  -- Create the target tone
local minute, d

tone_manager.effects = {
  torch = sol.sprite.create("entities/torch_light"),
  torch_tile = sol.sprite.create("entities/torch_light_tile"),
  torch_hero = sol.sprite.create("entities/torch_light_hero")
}

function game:start_tone_system()
  sol.menu.start(self:get_map(), tone_manager, true)
end

function game:stop_tone_system()
  sol.menu.stop(tone_manager)
end

function game:on_tone_system_saving()
  if cr ~= nil then
    game:set_value("cr", cr)
    game:set_value("cg", cg)
    game:set_value("cb", cb)
  end
  game:set_value("tr", tr)
  game:set_value("tg", tg)
  game:set_value("tb", tb)
end

function game:set_time(hour)
  if hour == 24 then hour = 0 end
  game:set_value("hour_of_day", hour)
  minute = 0
  
  if (hour >= 8 and hour < 20) then
	  game:set_value("time_of_day", "day")
	elseif hour > 20 or hour < 7 then
	  game:set_value("time_of_day", "night")
	end
  
  --self:set_clock_enabled(false)
  --self:set_clock_enabled(self.was_clock_enabled)
	tone_manager:get_new_tone()
  
	d = 1
	cr = tr
	cg = tg
	cb = tb
	
	self:stop_tone_system()	
	self:start_tone_system()
end

function game:get_time()
  return game:get_value("hour_of_day")
end

function game:set_time_flow(int)
  self.time_flow = int
	self:stop_tone_system()
  
  self:set_clock_enabled(false)
  self:set_clock_enabled(true)
  
  self:start_tone_system()
end

-- Returns/sets the current time of day
function game:get_time_of_day()
  if game:get_value("time_of_day") == nil then game:set_value("time_of_day", "day") end
  return game:get_value("time_of_day")
end

function game:switch_time_of_day()
  -- Function called when sleeping.
  -- Sleeping during day takes player to 2100 (9pm) and sleeping at night takes us to 0800 (8am).
  if game:get_value("time_of_day") == "day" then
    game:set_time(21)
    minute = 0
  else
    game:set_time(8)
    minute = 0
  end
  return true
end

function game:set_map_tone(r,g,b,a)
  mr, mg, mb, ma = r, g, b, a
end

local item = game:get_item("lamp")
function item:set_light_animation(anim)
  tone_manager.lantern_effect:set_animation(anim)
end

function item:set_surface_opacity(opacity)
  tone_manager.shadow:set_opacity(opacity)
end

function tone_manager:on_started()
  self.effects.torch:set_blend_mode("blend")
	self.effects.torch_tile:set_blend_mode("blend")
	self.effects.torch_hero:set_blend_mode("blend")
  self.map = game:get_map()
  if minute == nil then minute = 0 end
	
	self.time_system = game:is_in_outside_world() or (self.map:get_id() == "20" or self.map:get_id() == "21" or self.map:get_id() == "22")
  -- Shadow surface -> Draw tones
  self.shadow = sol.surface.create(320, 240)
  self.shadow:set_blend_mode("multiply")
	
	-- Light surface -> Draw light effects
	self.light = sol.surface.create(320, 240)
  self.light:set_blend_mode("add")
	
	cr, cg, cb = game:get_value("cr"), game:get_value("cg"), game:get_value("cb")
  tr, tg, tb = game:get_value("tr"), game:get_value("tg"), game:get_value("tb")
  if cr == nil then game:set_value("cr", 255); cr = 255 end
  if cg == nil then game:set_value("cg", 255); cg = 255 end
  if cb == nil then game:set_value("cb", 255); cb = 255 end
  if tr == nil then game:set_value("tr", 255); tr = 255 end
  if tg == nil then game:set_value("tg", 255); tg = 255 end
  if tb == nil then game:set_value("tb", 255); tb = 255 end
  
  self:get_new_tone()
  self:check()
end

function tone_manager:set_new_tone(r, g, b)
  tr = r   
  tg = g
  tb = b   
end

-- Checks if the tone need to be updated
-- and updates it if necessary.
function tone_manager:check()
  local need_rebuild = false
  
  if not game:is_suspended() then minute = minute + 1 end
  if minute >= 60 then game:set_time(game:get_value("hour_of_day")+1) end

  if minute == 0 or minute == 30 then
    need_rebuild = true
  end
  
  if need_rebuild then
	  self:get_new_tone()
	  need_rebuild = false
  end 
  
  -- Schedule the next check.
  sol.timer.start(self, game.time_flow, function()
    self:check()
  end)
print(game:get_value("hour_of_day") .. ":" .. minute)
end

function tone_manager:get_new_tone(hour, minute)
  local hour = game:get_value("hour_of_day")
  if minute == nil then minute = 0 end
	
  if hour == 4 and minute < 30 then
    self:set_new_tone(120, 120, 190)
	elseif hour == 4 and minute >= 30 then
     self:set_new_tone(140, 125, 170)
	elseif hour == 5 and minute < 30 then
	  game:set_value("time_of_day", "dawn")
    self:set_new_tone(155, 130, 140)
	elseif hour == 5 and minute >= 30 then
    self:set_new_tone(170, 130, 100)
	elseif hour == 6 and minute < 30 then
    self:set_new_tone(210, 180, 150)
	elseif hour == 6 and minute >= 30 then
    self:set_new_tone(240, 240, 230)
	elseif hour == 7 and minute < 30 then
    self:set_new_tone(255, 255, 255) 
	elseif hour > 7 and hour <= 9 then
	  self:set_new_tone(255, 255, 255) 
	elseif hour > 9 and hour < 16 then
	  self:set_new_tone(255, 255, 225)
	elseif hour == 16 and minute < 30 then
	  self:set_new_tone(255, 230, 210)
	elseif hour == 16 and minute >= 30 then
	  self:set_new_tone(255, 210, 180)
	elseif hour == 17 and minute < 30 then
	  self:set_new_tone(255, 190, 160)
	elseif hour == 17 and minute >= 30 then
    game:set_value("time_of_day", "sunset")
	  self:set_new_tone(225, 170, 150)
	elseif hour == 18 and minute < 30 then
	  self:set_new_tone(180, 140, 120)
	elseif hour == 18 and minute >= 30 then
	  game:set_value("time_of_day", "twilight")
	  self:set_new_tone(150, 110, 100)
	elseif hour == 19 and minute < 30 then
    game:set_value("time_of_day","night")
	  self:set_new_tone(110, 105, 190)	 
	elseif hour == 19 and minute >= 30 then
	  self:set_new_tone(90, 90, 225)
	elseif hour == 3 and minute >= 30 then
	  self:set_new_tone(80, 80, 230)
  else
    self:set_new_tone(80, 80, 230)
	end
	
	if game.raining then
	  self:set_new_tone(150, 150, 255)
	end

  d = 30 or 1800
end

function tone_manager:on_finished()
  sol.timer.stop_all(self)
  game:on_tone_system_saving()
end

function tone_manager:on_draw(dst_surface)
  local hero = game:get_hero()
  local cam_x, cam_y = game:get_map():get_camera():get_position()
  local x, y = hero:get_position()
  
  -- Calculate and reach the target tone before minutes reach 30 or 0
  if (not game:is_paused() and not game:is_suspended()) then
    cr = cr ~= tr and (cr * (d - 1) + tr) / d or tr
    cg = cg ~= tg and (cg * (d - 1) + tg) / d or tg
    cb = cb ~= tb and (cb * (d - 1) + tb) / d or tb
    d = d - 1
  end
	
  -- Fill the Tone Surface
  if mr ~= nil then
    -- We are in a map where tone are defined
    --print("map defined tone: " .. mr .. ", " .. mg .. ", " .. mb .. ", " .. ma)
	  self.shadow:clear() 
    self.shadow:fill_color{mr, mg, mb, ma}
  elseif self.time_system and mr == nil then
    -- We are outside
    --print("outside tone: " .. cr .. ", " .. cg .. ", " .. cb)
    self.shadow:fill_color{cr, cg, cb, 255}
  elseif not self.time_system and mr == nil then
    -- The map has undefined tone.
    self.shadow:fill_color{255, 255, 255, 255}
  end
  
  -- Rebuild the light surface
  self.light:clear()
  
  -- Next, this section is about entities.
  local map = game:get_map()
  
  for e in map:get_entities("torch_") do
    if e:is_enabled() and e:get_sprite():get_animation() == "lit" and e:get_distance(hero) <= 300 then
      local xx,yy = e:get_position()
      self.effects.torch:draw(self.light, xx - cam_x - 32, yy - cam_y - 32)
    end
  end
  
  for e in map:get_entities("night_") do
    if e:is_enabled() and e:get_distance(hero) <= 300 then
      if e.is_street_light then
		    local xe, ye = e:get_position()
		    self.effects.torch:draw(self.light, xe - cam_x - 24, ye - cam_y - 24)
		  else
		    local xx,yy = e:get_position()
        self.effects.torch:draw(self.light, xx - cam_x - 24, yy - cam_y - 24)
		  end
    end
  end  
  
  for e in map:get_entities("lava_") do
    if e:is_enabled() and e:get_distance(hero) <= 300 then
      local xx,yy = e:get_position()
	    self.effects.torch_tile:draw(self.light, xx - cam_x - 8, yy - cam_y - 8)
    end
  end

  for e in map:get_entities("warp_") do
    if e:is_enabled() and e:get_distance(hero) <= 300 then
      local xx,yy = e:get_position()
	    self.effects.torch_tile:draw(self.light, xx - cam_x - 8, yy - cam_y - 8)
    end
  end
  
  if game:has_item("lamp") and game:get_magic() > 0 and game:get_time_of_day() == "night" then
    --self.effects.torch_lantern:set_direction(hero:get_direction())
    self.effects.torch_hero:draw(self.light, x - cam_x - 64, y - cam_y - 68)
	end
  
  self.light:draw(self.shadow)
  self.shadow:draw(dst_surface)
end

return tone_manager