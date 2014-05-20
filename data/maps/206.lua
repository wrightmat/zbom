local map = ...
local game = map:get_game()

---------------------------------------
-- Dungeon 5: Lakebed Lair (Floor 1) --
---------------------------------------

function map:on_started(destination)

end

function map:on_obtained_treasure(treasure_item, treasure_variant, treasure_savegame_variable)
  if treasure_name == book_mudora and treasure_variant == 4 then
    game:set_dungeon_finished(5)
  end
end
