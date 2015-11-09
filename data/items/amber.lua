local item = ...
local game = item:get_game()

function item:on_created()
  self:set_shadow("small")
  self:set_can_disappear(false)
end

-- Obtaining Goron Amber
function item:on_obtaining(variant, savegame_variable)
  local amber_counter = self:get_game():get_item("amber_counter")
  if amber_counter:get_variant() == 0 then
    amber_counter:set_variant(1)
  end
  amber_counter:add_amount(1)
  self:get_game():set_value("item_amber_obtained", true)
end

function item:on_pickable_created(pickable)
  if game:get_value("item_amber_obtained") then self:set_brandish_when_picked(false) end
end