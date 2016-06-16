local item = ...
local game = item:get_game()

function item:on_created()
  self:set_shadow("small")
  self:set_can_disappear(false)
end

-- Obtaining an apple.
function item:on_obtaining(variant, savegame_variable)
  local apple_counter = self:get_game():get_item("apple_counter")
  if apple_counter:get_variant() == 0 then
    apple_counter:set_variant(1)
  end
  apple_counter:add_amount(1)
  self:get_game():set_value("item_apple_obtained", true)
end

function item:on_pickable_created(pickable)
  if game:get_value("item_apple_obtained") then self:set_brandish_when_picked(false) end
end