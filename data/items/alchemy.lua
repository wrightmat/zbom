local item = ...
local game = item:get_game()

function item:on_created()
  self:set_shadow("small")
  self:set_can_disappear(false)
end

-- Obtaining Alchemy Stone
function item:on_obtaining(variant, savegame_variable)
  local alchemy_counter = self:get_game():get_item("alchemy_counter")
  if alchemy_counter:get_variant() == 0 then
    alchemy_counter:set_variant(1)
  end
  alchemy_counter:add_amount(1)
  game:set_value("item_alchemy_obtained", true)
end

function item:on_pickable_created(pickable)
  if game:get_value("item_alchemy_obtained") then self:set_brandish_when_picked(false) end
end