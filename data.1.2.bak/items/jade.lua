local item = ...

function item:on_created()
  self:set_shadow("small")
  self:set_can_disappear(false)
  self:set_brandish_when_picked(false)
end

-- Obtaining Mystic Jade
function item:on_obtaining(variant, savegame_variable)
  local jade_counter = self:get_game():get_item("jade_counter")
  if jade_counter:get_variant() == 0 then
    jade_counter:set_variant(1)
  end
  jade_counter:add_amount(1)
end
