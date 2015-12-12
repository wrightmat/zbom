local map = ...
local game = map:get_game()

---------------------------------
-- Outside World B5 (Snowpeak) --
---------------------------------

function map:on_started(destination)
  -- loop through all entities starting with "bush_" and set_can_be_cut(false) if hero doesn't have at least the Forged Sword
end