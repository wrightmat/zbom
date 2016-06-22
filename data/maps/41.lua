local map = ...
local game = map:get_game()

--------------------------------------
-- Outside World E9 (Lon Lon Ranch) --
--------------------------------------

if game:get_value("i1929")==nil then game:set_value("i1929", 0) end --Marryn

function map:on_started(destination)
  npc_marryn:get_sprite():set_animation("singing")
  local entrance_names = { "ranch" }
  for _, entrance_name in ipairs(entrance_names) do
    local sensor = map:get_entity(entrance_name .. "_door_sensor")
    local tile = map:get_entity(entrance_name .. "_door")
    sensor.on_activated_repeat = function()
      if hero:get_direction() == 1 and tile:is_enabled() then
        tile:set_enabled(false)
        sol.audio.play_sound("door_open")
      end
    end
  end
  -- Activate any night-specific dynamic tiles.
  if game:get_time_of_day() == "night" then
    for entity in game:get_map():get_entities("night_") do
      entity:set_enabled(true)
    end
  end
end

function npc_marryn:on_interaction()
  local first_volume = 100
  local second_volume = 1
  if game:get_value("i1929") > 1 then game:set_value("i1929, 1) end
  game:start_dialog("marryn."..game:get_value("i1929")..".ranch", function()
    sol.timer.start(map, 50, function()
      sol.audio.set_music_volume(first_volume)
      first_volume = first_volume - 1  -- Fade music out by decreasing volume slowly (this is for the ranch).
      if first_volume == 1 then return false else return true end
    end)
    sol.audio.play_music("ballad", function()
      sol.timer.start(map, 50, function()
        sol.audio.set_music_volume(first_volume)
        first_volume = first_volume - 1  -- Fade music out by decreasing volume slowly (this is for the ballad).
        if first_volume == 1 then return false else return true end
      end)
      sol.audio.play_music("ranch")
      sol.timer.start(map, 50, function()
        sol.audio.set_music_volume(second_volume)
        second_volume = second_volume + 1  -- Fade music in by increasing volume slowly (this is for the ranch).
        if second_volume >= 100 then return false else return true end
      end)
    end)
    sol.timer.start(map, 50, function()
      sol.audio.set_music_volume(second_volume)
      second_volume = second_volume + 1  -- Fade music in by increasing volume slowly (this is for the ballad).
      if second_volume >= 100 then return false else return true end
    end)
    game:set_value("i1929", game:get_value("i1929")+1)
  end)
end

function sensor_singing:on_left()
  local volume = 1
  sol.audio.play_music("ranch")
  sol.timer.start(map, 50, function()
    sol.audio.set_music_volume(volume)
    volume = volume + 1  -- Fade music in by increasing volume slowly (this is for the ranch).
    if volume >= 100 then return false else return true end
  end)
end