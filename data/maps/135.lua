local map = ...
local band_playing = false

function map:on_started()
  npc_gruce:get_sprite():set_animation("guitar")
  npc_band_guitar:get_sprite():set_animation("guitar")
end

function sensor_band_1:on_activated()
  local first_volume = 100
  local second_volume = 1

  if not band_playing then
    --game:start_dialog("gruce")
    npc_gruce:get_sprite():set_animation("strum")
    sol.audio.play_music("gerutones", function()
      npc_gruce:get_sprite():set_animation("guitar")
      sol.audio.play_music("north_hyrule")
    end)
    sol.timer.start(self, 100, function() npc_gruce:get_sprite():set_animation("strumming") end)
  else
    npc_gruce:get_sprite():set_animation("guitar")
    sol.timer.start(map, 50, function()
      sol.audio.set_music_volume(first_volume)
      first_volume = first_volume - 1  -- Fade music out by decreasing volume slowly (this is for the song).
      if first_volume == 1 then return false else return true end
    end)
    sol.audio.play_music("north_hyrule")
    sol.timer.start(map, 50, function()
      sol.audio.set_music_volume(second_volume)
      second_volume = second_volume + 1  -- Fade music in by increasing volume slowly (this is for the map music).
      if second_volume >= 100 then return false else return true end
    end)
  end
end

function sensor_band_2:on_activated()
  sensor_band_1:on_activated()
end
function sensor_band_3:on_activated()
  sensor_band_1:on_activated()
end