local item = ...

function item:on_created()
  self:set_shadow("big")
  self:set_can_disappear(true)
  self:set_brandish_when_picked(false)
end

-- Obtaining a pumpkin.
function item:on_obtaining(variant, savegame_variable)
  local pumpkin_counter = self:get_game():get_item("pumpkin_counter")
  if pumpkin_counter:get_variant() == 0 then
    pumpkin_counter:set_variant(1)
  end
  pumpkin_counter:add_amount(1)
end