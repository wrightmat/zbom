local item = ...
local game = item:get_game()

function item:on_created()
  self:set_shadow("small")
  self:set_can_disappear(false)
end

-- Obtaining a carrot.
function item:on_obtaining(variant, savegame_variable)
  local carrot_counter = self:get_game():get_item("carrot_counter")
  if carrot_counter:get_variant() == 0 then
    carrot_counter:set_variant(1)
  end
  carrot_counter:add_amount(1)
  self:get_game():set_value("item_carrot_obtained", true)
end

function item:on_pickable_created(pickable)
  if game:get_value("item_carrot_obtained") then self:set_brandish_when_picked(false) end
end