local map = ...
local game = map:get_game()

function map:on_started(destination)
  game:set_value("i1025", 200)
  game:set_value("i1024", 200)

  hero:teleport("1", "from_intro", "fade")
end
