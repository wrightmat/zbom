local item = ...

function item:on_created()
  self:set_shadow("small")
  self:set_can_disappear(false)
  self:set_brandish_when_picked(false)
end

-- Obtaining Subrosian Ore
function item:on_obtaining(variant, savegame_variable)
  local ore_counter = self:get_game():get_item("ore_counter")
  if ore_counter:get_variant() == 0 then
    ore_counter:set_variant(1)
  end
  ore_counter:add_amount(1)
end
