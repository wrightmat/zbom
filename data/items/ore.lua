local item = ...
local game = item:get_game()

function item:on_created()
  self:set_shadow("small")
  self:set_can_disappear(false)
end

-- Obtaining Subrosian Ore
function item:on_obtaining(variant, savegame_variable)
  local amounts = {1, 5}
  local amount = amounts[variant]
  local ore_counter = self:get_game():get_item("ore_counter")
  if ore_counter:get_variant() == 0 then ore_counter:set_variant(1) end
  if amount == nil then error("Invalid variant '" .. variant .. "' for item 'rupee'") end
  ore_counter:add_amount(amount)
  game:set_value("item_ore_obtained", true)
end

function item:on_pickable_created(pickable)
  if game:get_value("item_ore_obtained") then self:set_brandish_when_picked(false) end
end