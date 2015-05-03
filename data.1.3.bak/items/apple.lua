local item = ...

-- Obtaining an apple
function item:on_obtaining(variant, savegame_variable)
  local apple_counter = self:get_game():get_item("apple_counter")
  if apple_counter:get_variant() == 0 then
    apple_counter:set_variant(1)
  end
  apple_counter:add_amount(1)
end
