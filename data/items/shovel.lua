local item = ...

function item:on_created()
  self:set_savegame_variable("i1838")
  self:set_assignable(true)
end

function item:on_variant_changed(variant)

end