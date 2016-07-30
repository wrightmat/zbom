local map = ...
local game = map:get_game()

-----------------------------------------------------------------
-- Outside World M5 (Ancient Library) - Library, Ordona Speaks --
-----------------------------------------------------------------

local ordona_speaking = false
local shadow = sol.surface.create(1120, 1120)
local lights = sol.surface.create(1120, 1120)
shadow:fill_color({32,64,128,255})
shadow:set_blend_mode("multiply")
lights:set_blend_mode("add")

function map:on_started(destination)
  if game:get_value("i1032") == 1 then
    sol.timer.start(1500, function() torch_ordona:get_sprite():set_animation("lit") end)
    sol.timer.start(2000, function()
      hero:freeze()
      ordona_speaking = true
      game:start_dialog("ordona.2.library", game:get_player_name(), function()
        sol.timer.start(500, function() ordona_speaking = false end)
        hero:unfreeze()
        game:add_max_stamina(100)
        game:set_stamina(game:get_max_stamina())
        torch_ordona:get_sprite():set_animation("unlit")
        game:set_value("i1032", 2)
      end)
    end)
  elseif game:get_value("i1032") >= 2 then door:set_enabled(false) end

  -- Activate any night-specific dynamic tiles.
  if game:get_time_of_day() == "night" then
    for entity in game:get_map():get_entities("night_") do
      entity:set_enabled(true)
    end
  end
end

function map:on_draw(dst_surface)
  -- Show torch overlay for Ordona dialog
  if game:get_time_of_day() ~= "night" and ordona_speaking then
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