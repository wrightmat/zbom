local map = ...
local game = map:get_game()

---------------------------------------------------------------------------
-- Outside World M2 (Nabooru Town) - Gerudo of the north, Gerutones band --
---------------------------------------------------------------------------

local band_playing = game:get_value("b1231")
if game:get_value("i1230") == nil then game:set_value("i1230", 0) end

function map:on_started()
  if game:get_value("i1230") >= 1 then
    npc_band_gruce:get_sprite():set_animation("guitar")
    npc_band_guitar:get_sprite():set_animation("guitar")
  else
    npc_band_gruce:remove()
    npc_band_guitar:remove()
    npc_band_drums:remove()
    sensor_band_start:remove()
    sensor_band_1:remove()
    sensor_band_2:remove()
    sensor_band_3:remove()
  end

  -- Activate any night-specific dynamic tiles.
  if game:get_time_of_day() == "night" then
    for entity in game:get_map():get_entities("night_") do
      entity:set_enabled(true)
    end
  end
end

function sensor_band_start:on_activated()
  game:start_dialog("gruce.0.band")
  band_playing = true
  sol.audio.play_music("gerutones", function()
    npc_gruce:get_sprite():set_animation("guitar")
    sol.audio.play_music("north")
  end)
  sol.timer.start(self, 1500, function() npc_band_gruce:get_sprite():set_animation("strum") end)
  sol.timer.start(self, 1650, function() npc_band_gruce:get_sprite():set_animation("strumming") end)
  sol.timer.start(self, 9800, function() npc_band_guitar:get_sprite():set_animation("strumming") end)
end

function sensor_band_1:on_activated()
  local first_volume = 100
  local second_volume = 1
  if band_playing then
    npc_band_gruce:get_sprite():set_animation("guitar")
    sol.timer.start(map, 50, function()
      band_playing = false
      sol.audio.set_music_volume(first_volume)
      first_volume = first_volume - 2  -- Fade music out by decreasing volume slowly (this is for the song).
      if first_volume <= 2 then return false else return true end
    end)
    sol.timer.start(self, 3000, function() sol.audio.play_music("north")
      sol.timer.start(map, 50, function()
        sol.audio.set_music_volume(second_volume)
        second_volume = second_volume + 2  -- Fade music in by increasing volume slowly (this is for the map music).
        if second_volume >= 100 then return false else return true end
      end)
    end)
  end
end
function sensor_band_2:on_activated()
  sensor_band_1:on_activated()
end
function sensor_band_3:on_activated()
  sensor_band_1:on_activated()
end

function map:on_finished()
  game:set_value("b1231", band_playing)
end