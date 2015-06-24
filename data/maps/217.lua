local map = ...
local game = map:get_game()

---------------------------------------------
-- Dungeon 7: Tower of the Winds (Floor 8) --
---------------------------------------------

function map:on_started(destination)
  if not game:get_value("b1168") then boss_helmaroc:set_enabled(false) end
  if not game:get_value("b1169") then boss_heart:set_enabled(false) end
end

function sensor_boss:on_activated()
  if boss_helmaroc ~= nil then
    map:close_doors("door_boss")
    boss_helmaroc:set_enabled(true)
    sol.audio.play_music("boss")
  end
end

if boss_helmaroc ~= nil then
  function boss_helmaroc:on_dead()
    map:open_doors("door_boss")
    sol.audio.play_sound("boss_killed")
    boss_heart:set_enabled(true)
    sol.timer.start(1000, function()
      sol.audio.play_music("temple_wind")
    end)
  end
end

function map:on_obtained_treasure(item, variant, savegame_variable)
  if item:get_name() == "book_mudora" then
    game:set_dungeon_finished(7)
  end
end