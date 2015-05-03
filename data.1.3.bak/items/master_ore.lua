local item = ...

function item:on_created()
  self:set_shadow("big")
  self:set_can_disappear(false)
  self:set_brandish_when_picked(true)
  self:set_savegame_variable("b1851")
end
