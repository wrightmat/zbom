local map = ...
local game = map:get_game()

------------------------------------------------------
-- Outside World F8 (Hyrule Castle) - Ordona Speaks --
------------------------------------------------------

local ordona_speaking = false
local shadow = sol.surface.create(1120, 1120)
local lights = sol.surface.create(1120, 1120)
shadow:fill_color({32,64,128,255})
shadow:set_blend_mode("multiply")
lights:set_blend_mode("add")

local function random_walk(npc)
  local m = sol.movement.create("random_path")
  m:set_speed(32)
  m:start(npc)
  npc:get_sprite():set_animation("walking")
end

function map:on_started(destination)
  -- Opening doors
  local entrance_names = { "castle" }
  for _, entrance_name in ipairs(entrance_names) do
    local sensor = map:get_entity(entrance_name .. "_door_sensor")
    local tile = map:get_entity(entrance_name .. "_door")
    sensor.on_activated_repeat = function()
      if hero:get_direction() == 1 and tile:is_enabled() and game:get_time_of_day() == "day" then
        tile:set_enabled(false)
        sol.audio.play_sound("door_open")
      end
    end
  end

  if destination == from_castle_1 and game:get_value("i1032") == 3 then
    sol.timer.start(1000, function()
      hero:freeze()
      ordona_speaking = true
      hero:set_direction(0)
      game:start_dialog("ordona.3.castle", game:get_player_name(), function()
        sol.timer.start(500, function() ordona_speaking = false end)
        hero:unfreeze()
        game:add_max_stamina(100)
        game:set_stamina(game:get_max_stamina())
        game:set_value("i1032", 4)
      end)
    end)
  end

  random_walk(npc_guard_1)
  random_walk(npc_guard_2)
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