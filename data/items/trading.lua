local item = ...

function item:on_created()
  self:set_savegame_variable("i1840")
end

function item:on_obtained(variant, savegame_variable)
  -- There are 12 variants of this in the trading sequence - do I need to do anything here?
end