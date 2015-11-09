local item = ...
local game = item:get_game()

function item:on_created()
  self:set_savegame_variable("i1827")
  self:set_amount_savegame_variable("i1828")
  self:set_max_amount(99)
end