local item = ...

function item:on_created()
  self:set_savegame_variable("i1840")
end

function item:on_obtained(variant, savegame_variable)
  if variant == 13 then
    hero:start_treasure("feather")
  end
end