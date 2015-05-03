local item = ...

function item:on_created()
  self:set_savegame_variable("i1829")
  self:set_amount_savegame_variable("i1830")
  self:set_max_amount(99)
end
