local map = ...
local game = map:get_game()

-------------------------------------------------------------------
-- Outside World E15 (Faron Woods) - Mushroom (trading sequence) --
-------------------------------------------------------------------

if game:get_value("i1840")==nil then game:set_value("i1840", 0) end

function map:on_started()
  if game:get_value("i1840") > 1 then odd_mushroom:set_enabled(false) end
end