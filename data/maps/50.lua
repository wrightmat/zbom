local map = ...
local game = map:get_game()

----------------------------------------------------------------
-- Outside World E7 (Kakariko City) - Houses, Bomb Shop, etc. --
----------------------------------------------------------------

sunset_overlay = sol.surface.create(320, 240)
if hero:get_direction() == 0 or hero:get_direction() == 3 then
  -- If coming from left side of town or out of house, show the
  -- sunset overlay. If coming from field (facing up or left), don't.
  sunset_overlay:set_opacity(0.4 * 255)
else
  sunset_overlay:set_opacity(0)
end
sunset_overlay:fill_color{187, 33, 21}

local function random_walk(npc)
  local m = sol.movement.create("random_path")
  m:set_speed(32)
  m:start(npc)
  npc:get_sprite():set_animation("walking")
end

function map:on_started(destination)
  random_walk(npc_ildus)

  -- Opening doors
  local entrance_names = {
    "house_1", "house_2", "house_3", "house_4"
  }
  for _, entrance_name in ipairs(entrance_names) do
    local sensor = map:get_entity(entrance_name .. "_door_sensor")
    local tile = map:get_entity(entrance_name .. "_door")
    sensor.on_activated_repeat = function()
      if hero:get_direction() == 1 and tile:is_enabled() then
	tile:set_enabled(false)
	sol.audio.play_sound("door_open")
      elseif hero:get_direction() == 3 then
	-- Special case on this map to play kakariko music when coming out of houses
	-- so house music doesn't continue. Map doesn't specify music.
	sol.audio.play_music("kakariko")
      end
    end
  end
end

function sensor_enter_kakariko:on_activated()
  sol.audio.play_music("kakariko")
  sunset_overlay:set_opacity(0.1*255)
  sensor_enter_field:set_enabled(false)
  sol.timer.start(sensor_enter_kakariko,2000,function()
    sensor_enter_field:set_enabled(true)
    sunset_overlay:set_opacity(0.2*255)
    sol.timer.start(sensor_enter_kakariko,2000,function()
      sunset_overlay:set_opacity(0.3*255)
    end)
  end)
end
function sensor_enter_field:on_activated()
  sol.audio.play_music("field")
  sunset_overlay:set_opacity(0.3*255)
  sensor_enter_kakariko:set_enabled(false)
  sol.timer.start(sensor_enter_field,2000,function()
    sensor_enter_kakariko:set_enabled(true)
    sunset_overlay:set_opacity(0.2*255)
    sol.timer.start(sensor_enter_field,2000,function()
      sunset_overlay:set_opacity(0.1*255)
      sol.timer.start(sensor_enter_field,2000,function()
        sunset_overlay:set_opacity(0)
      end)
    end)
  end)
end

function game:on_map_changed(map)
  function map:on_draw(dst_surface)
    if map:get_world() ~= "inside_world" then sunset_overlay:draw(dst_surface) end
  end
end
