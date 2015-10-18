local map = ...
local game = map:get_game()

--------------------------------------
-- Outside World F11 (Hyrule Field) --
--------------------------------------

function map:on_started(destination)
  if not game:get_value("b1117") then
    npc_bilo:remove()
  end
end