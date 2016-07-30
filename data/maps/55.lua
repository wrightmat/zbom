local map = ...
local game = map:get_game()

--------------------------------------------------
-- Outside World E5 (Septen Heights/Tower Entr) --
--------------------------------------------------

local ordona_speaking = false
local shadow = sol.surface.create(1120, 1120)
local lights = sol.surface.create(1120, 1120)
shadow:fill_color({32,64,128,255})
shadow:set_blend_mode("multiply")
lights:set_blend_mode("add")

function map:on_started(destination)
  if game:get_value("b1150") then stone_pile:remove() end -- Tower construction over after Snowpeak Caverns beat.
  if game:get_value("b1170") and game:get_value("i1910") < 7 then
    torch_1:get_sprite():set_animation("lit")
    sol.timer.start(1000, function()
      hero:freeze()
      ordona_speaking = true
      if not game:get_value("b1033") then  -- If player has not done Ruins, suggest that before Lost Woods.
        game:start_dialog("ordona.7.septen_2", game:get_player_name(), function()
          sol.timer.start(500, function() ordona_speaking = false end)
          hero:unfreeze()
          game:add_max_stamina(100)
          game:set_stamina(game:get_max_stamina())
          torch_1:get_sprite():set_animation("unlit")
          game:set_value("i1910", 7)
        end)
      else
        game:start_dialog("ordona.7.septen", game:get_player_name(), function()
          torch_overlay:fade_out(50)
          sol.timer.start(2000, function() torch_overlay = nil end)
          hero:unfreeze()
          game:add_max_stamina(100)
          game:set_stamina(game:get_max_stamina())
          torch_1:get_sprite():set_animation("unlit")
          game:set_value("i1910", 7)
        end)
      end
    end)
  end

  -- Activate any night-specific dynamic tiles.
  if game:get_time_of_day() == "night" then
    for entity in game:get_map():get_entities("night_") do
      entity:set_enabled(true)
    end
  end
end

function sensor_change_layer:on_activated()
  -- If walking forward on low level, change to intermediate level.
  if layer ~= 1 and hero:get_direction() == 1 then
    local x, y, layer = hero:get_position()
    hero:set_position(x, y, layer+1)
  end

  -- If walking down on intermediate level, changle to low level.
  if layer ~= 0 and hero:get_direction() == 3 then
    local x, y, layer = hero:get_position()
    hero:set_position(x, y, layer-1)
  end
end

if game:get_time_of_day() ~= "night" and ordona_speaking then
  function map:on_draw(dst_surface)
    -- Show torch overlay for Ordona dialog
    local x,y = game:get_map():get_camera():get_position()
    local w,h = game:get_map():get_camera():get_size()
    local xx, yy = map:get_entity("torch_5"):get_position()
    local sp = sol.sprite.create("entities/torch_light")
    sp:set_blend_mode("blend")
    sp:draw(lights, xx-32, yy-32)
    lights:draw_region(x,y,w,h,shadow,x,y)
    shadow:draw_region(x,y,w,h,dst_surface)
  end
end