local map = ...
local game = map:get_game()

---------------------------------------------
-- Dungeon 7: Tower of the Winds (Floor 8) --
---------------------------------------------

function map:on_started(destination)

end

function map:on_obtained_treasure(item, variant, savegame_variable)
  if item:get_name() == "book_mudora" then
    game:set_dungeon_finished(7)
  end
end