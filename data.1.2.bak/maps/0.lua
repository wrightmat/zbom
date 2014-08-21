local map = ...
local game = map:get_game()

function map:on_started(destination)
  hero:teleport("1", "from_intro", "fade")
end
