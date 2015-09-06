local map = ...
local game = map:get_game()

------------------------------------------------------
-- Outside World F8 (Hyrule Castle) - Ordona Speaks --
------------------------------------------------------

local torch_overlay = nil

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
      torch_overlay = sol.surface.create("entities/dark.png")
      torch_overlay:fade_in(50)
      hero:set_direction(0)
      game:start_dialog("ordona.3.castle", game:get_player_name(), function()
        torch_overlay:fade_out(50)
        sol.timer.start(2000, function() torch_overlay = nil end)
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
  if game:get_time_of_day() ~= "night" and torch_overlay ~= nil then
    local screen_width, screen_height = dst_surface:get_size()
    local cx, cy = map:get_camera_position()
    local tx, ty = torch_fire_2:get_center_position()
    local x = 320 - tx + cx
    local y = 240 - ty + cy
    torch_overlay:draw_region(x, y, screen_width, screen_height, dst_surface)
  end
end