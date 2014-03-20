local map = ...
local game = map:get_game()

------------------------------------------------------------------------
-- Outside World D7 (Kakariko City) - Houses, Ampitheater, Fireworks! --
------------------------------------------------------------------------

sunset_overlay = sol.surface.create(320, 240)
sunset_overlay:set_opacity(0.4 * 255)
sunset_overlay:fill_color{187, 33, 21}

local function random_walk(npc)
  local m = sol.movement.create("random_path")
  m:set_speed(32)
  m:start(npc)
  npc:get_sprite():set_animation("walking")
end

local function fireworks_shower_start()
  fireworks_shower:get_sprite():set_animation("ground")
  sol.timer.start(4000, function()
    fireworks_shower:get_sprite():set_animation("stopped")
    sol.timer.start(math.random(10)*1000, fireworks_shower_start)
  end)
end

function map:on_started(destination)
  fireworks_shower:get_sprite():set_animation("stopped")
  local fire_show = math.random(10)*500
  sol.timer.start(fire_show, fireworks_shower_start)

  -- Opening doors
  local entrance_names = {
    "house_5", "house_6", "house_7", "house_8", "house_9", "house_10"
  }
  for _, entrance_name in ipairs(entrance_names) do
    local sensor = map:get_entity(entrance_name .. "_door_sensor")
    local tile = map:get_entity(entrance_name .. "_door")
    sensor.on_activated_repeat = function()
      if hero:get_direction() == 1
	  and tile:is_enabled() then
	tile:set_enabled(false)
	sol.audio.play_sound("door_open")
      end
    end
  end
end

function npc_warun:on_interaction()
  game:start_dialog("warun.0")
end

function game:on_map_changed(map)
  function map:on_draw(dst_surface)
    if map:get_world() ~= "inside_world" then sunset_overlay:draw(dst_surface) end
  end
end
