local item = ...

function item:on_created()
  self:set_savegame_variable("i1841")
end

function item:on_obtained(variant, savegame_variable)
  -- There are 3 variants of this to obtain in the pyramid - do I need to do anything here?
end