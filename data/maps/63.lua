local map = ...
local game = map:get_game()
local spoken = 0

--------------------------------------------------------------
-- Outside World E6 (Death Mountain) - Great Fairy Entrance --
--------------------------------------------------------------

function npc_goron:on_interaction()
  if spoken <= 2 then
    game:start_dialog("goron."..spoken..".death_mountain")
    spoken = spoken + 1
  else
    game:start_dialog("goron.1.death_mountain")
  end
end