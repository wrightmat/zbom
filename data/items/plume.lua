local item = ...
local game = item:get_game()

function item:on_created()
  self:set_shadow("small")
  self:set_can_disappear(false)
  self:set_brandish_when_picked(false)
end

-- Obtaining Goddess Plume
function item:on_obtaining(variant, savegame_variable)
  local plume_counter = self:get_game():get_item("plume_counter")
  if plume_counter:get_variant() == 0 then
    plume_counter:set_variant(1)
  end
  plume_counter:add_amount(1)
  game:set_value("item_plume_obtained", true)
end

function item:on_pickable_created(pickable)
  if game:get_value("item_plume_obtained") then self:set_brandish_when_picked(false) end
end