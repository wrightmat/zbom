local map = ...
local game = map:get_game()

---------------------------------------------
-- Dungeon 7: Tower of the Winds (Floor 8) --
---------------------------------------------

map:register_event("on_started", function(self, destination)
  game:set_world_rain_mode("dungeon_7", "storm")
  if not game:get_value("b1168") then
    boss_helmaroc:set_enabled(false)
  else
    map:open_doors("door_boss")
  end
  if not game:get_value("b1169") then boss_heart:set_enabled(false) end
end)

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

function chest_book:on_opened(item, variant, savegame_variable)
  -- Dynamically determine book variant to give, since dungeons can be done in any order.
  local book_variant = game:get_item("book_mudora"):get_variant() + 1
  map:get_hero():start_treasure("book_mudora", book_variant)
  game:set_dungeon_finished(7)
  game:set_value("b1170", true) -- This value varies depending on the dungeon (chest save value)
end