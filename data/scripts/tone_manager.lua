-- Tone Manager
-- Manage time system tones and also light effects.

local tone_manager = {}

local effects = {
  torch = sol.sprite.create("entities/torch_light"),
  torch_tile = sol.sprite.create("entities/torch_light_tile"),
  torch_hero = sol.sprite.create("entities/torch_light_hero")
}

function tone_manager:create(game)
  local tone_menu = {}
  
  local mr, mg, mb, ma = nil
  local cr, cg, cb = nil  -- Create the current tone
  local tr, tg, tb = nil  -- Create the target tone
  local minute = 0
  local d = 0
  
  effects.torch:set_blend_mode("blend")
	effects.torch_tile:set_blend_mode("blend")
	effects.torch_hero:set_blend_mode("blend")
  
  -- Shadow surface -> Draw tones
  shadow = sol.surface.create(320, 240)
  shadow:set_blend_mode("multiply")
	
	-- Light surface -> Draw light effects
	light = sol.surface.create(320, 240)
  light:set_blend_mode("add")
  
  function game:restart_tone_system()
    sol.menu.stop(tone_manager)
    sol.menu.start(game, tone_manager)
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
  
  function game:set_time_flow(int)
    time_flow = int
    self:restart_tone_system()
  end
  
  function tone_menu:on_map_changed()
    if game:get_map() ~= nil then
      local map = game:get_map()
      game:on_tone_system_saving()
      
      mr, mg, mb, ma = nil, nil, nil, nil
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
  end

  function game:set_map_tone(r,g,b,a)
    mr, mg, mb, ma = r, g, b, a
  end
  function game:get_map_tone()
    return mr, mg, mb, ma
  end
  
  function tone_menu:set_new_tone(r, g, b)
    tr = r
    tg = g
    tb = b
    game:set_value("tr", r)
    game:set_value("tg", g)
    game:set_value("tb", b)
    game:set_value("cr", r)
    game:set_value("cg", g)
    game:set_value("cb", b)
  end
  
  -- Checks if the tone need to be updated and updates it if necessary.
  function tone_menu:check()
    local need_rebuild = false
    
    if not game:is_suspended() then minute = minute + 1 end
    if minute >= 60 then 
      game:set_value("hour_of_day", (game:get_value("hour_of_day") + 1) % 24) 
      minute = 0 
    end
    
    if minute == 0 or minute == 30 then
      need_rebuild = true
    end
    
    if need_rebuild then
      self:get_new_tone()
      need_rebuild = false
    end 
  end
  
  function tone_menu:get_new_tone(hour, minute)
    local hour = game:get_value("hour_of_day")
    if minute == nil then minute = 0 end
    
    if hour == 4 and minute < 30 then
      self:set_new_tone(120, 120, 190)
  	elseif hour == 4 and minute >= 30 then
       self:set_new_tone(140, 125, 170)
  	elseif hour == 5 and minute < 30 then
      self:set_new_tone(155, 130, 140)
  	elseif hour == 5 and minute >= 30 then
      self:set_new_tone(170, 130, 100)
  	elseif hour == 6 and minute < 30 then
  	  game:set_value("time_of_day", "dawn")
      self:set_new_tone(210, 180, 180)
  	elseif hour == 6 and minute >= 30 then
      self:set_new_tone(240, 240, 230)
  	elseif hour == 7 and minute < 30 then
      self:set_new_tone(255, 255, 255)
      game:set_value("time_of_day","day")
      for entity in game:get_map():get_entities("night_") do
        entity:set_enabled(false)
      end
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
  	  self:set_new_tone(120, 105, 160)	 
      for entity in game:get_map():get_entities("night_") do
        entity:set_enabled(true)
      end
  	elseif hour == 19 and minute >= 30 then
  	  self:set_new_tone(90, 90, 190)
  	elseif hour == 3 and minute >= 30 then
  	  self:set_new_tone(80, 80, 230)
    else
      self:set_new_tone(40, 60, 180)
  	end
  	
  	if game.raining then
  	  self:set_new_tone(150, 150, 255)
  	end
    
    d = 1800
  end
  
  function tone_menu:on_finished()
    sol.timer.stop_all(self)
    game:on_tone_system_saving()
  end
  
  function tone_menu:on_draw(dst_surface)
    if game:get_map() ~= nil then
      local map = game:get_map()
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
      
      if map:get_id() == "202" then
        mr, mg, mb, ma = 32, 64, 128, 128
      end
      
      -- Fill the Tone Surface
      if mr ~= nil then
        -- We are in a map where tone is defined
        shadow:fill_color{mr, mg, mb, ma}
      elseif game:is_in_outside_world() then
        shadow:clear()
        shadow:fill_color{cr, cg, cb, 255}
      else
        shadow:fill_color{255, 255, 255, 255}
      end
      
      -- Rebuild the light surface
      light:clear()
      
      -- Don't draw lights when the map is scrolling, or they scroll also.
      if teletransporter_scrolling ~= true then
        -- Next, this section is about entities.
        for e in map:get_entities("torch_") do
          if e:is_enabled() and e:get_sprite():get_animation() == "lit" and e:get_distance(hero) <= 300 then
            local xx,yy = e:get_position()
            effects.torch:draw(light, xx - cam_x - 32, yy - cam_y - 32)
          end
        end
        for e in map:get_entities("night_") do
          if e:is_enabled() and e:get_distance(hero) <= 300 then
            if e.is_street_light then
      		    local xe, ye = e:get_position()
      		    effects.torch:draw(light, xe - cam_x - 24, ye - cam_y - 24)
      		  else
      		    local xx,yy = e:get_position()
              effects.torch:draw(light, xx - cam_x - 24, yy - cam_y - 24)
      		  end
          end
        end
        for e in map:get_entities("lava_") do
          if e:is_enabled() and e:get_distance(hero) <= 300 then
            local xx,yy = e:get_position()
      	    effects.torch_tile:draw(light, xx - cam_x - 8, yy - cam_y - 8)
          end
        end
        for e in map:get_entities("warp_") do
          if e:is_enabled() and e:get_distance(hero) <= 300 then
            local xx,yy = e:get_position()
      	    effects.torch_tile:draw(light, xx - cam_x - 8, yy - cam_y - 8)
          end
        end
        for e in map:get_entities("b15") do -- Prefix used by Ocarina warp tiles.
          if e:is_enabled() and e:get_distance(hero) <= 300 then
            local xx,yy = e:get_position()
      	    effects.torch:draw(light, xx - cam_x - 32, yy - cam_y - 32)
          end
        end
        for e in map:get_entities("switch_") do
          if e:get_distance(hero) <= 300 then
            local xx,yy = e:get_position()
      	    effects.torch_tile:draw(light, xx - cam_x - 8, yy - cam_y - 8)
          end
        end
        for e in map:get_entities("poe_") do
          if e:is_enabled() and e:get_distance(hero) <= 300 then
            local xx,yy = e:get_position()
      	    effects.torch:draw(light, xx - cam_x - 32, yy - cam_y - 32)
          end
        end
        if game:has_item("lamp") and game:get_magic() > 0 then
          if game:get_time_of_day() == "night" or map:get_id() == "202" then
            effects.torch_hero:draw(light, x - cam_x - 64, y - cam_y - 68)
          end
      	end
      end
      
      if screen_overlay ~= nil then
        screen_overlay:draw(dst_surface)
      end
      
      light:draw(shadow)
      shadow:draw(dst_surface)
    end
  end
  
  sol.menu.start(game, tone_menu, false)

  -- Schedule the next check.
  sol.timer.start(game, game.time_flow, function()
    tone_menu:check()
    return true
  end)
  
  return tone_menu
end

return tone_manager