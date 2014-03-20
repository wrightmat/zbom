local item = ...

function item:on_created()
  self:set_shadow("small")
  self:set_can_disappear(false)
  self:set_brandish_when_picked(false)
end

-- Obtaining Deku Stick
function item:on_obtaining(variant, savegame_variable)
  local stick_counter = self:get_game():get_item("stick_counter")
  if stick_counter:get_variant() == 0 then
    stick_counter:set_variant(1)
  end
  stick_counter:add_amount(1)
end
