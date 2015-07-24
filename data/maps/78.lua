local map = ...
local game = map:get_game()

------------------------------------------------------------------
-- Outside World D10 (Desert/Lake Hylia) - Great Fairy Entrance --
------------------------------------------------------------------

function map:on_started(destination)
  if destination == from_fairy then
    sol.audio.play_music("field")
  end
end