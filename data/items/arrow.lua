local item = ...
local game = item:get_game()

function item:on_created()
  self:set_shadow("small")
  self:set_can_disappear(true)
  self:set_brandish_when_picked(false)
end

function item:on_started()
  -- Disable pickable arrows if the player has no bow.
  -- We cannot do this from on_created() because we don't know if the bow
  -- is already created there.
  item:set_obtainable(game:has_item("bow"))
end

function item:on_obtaining(variant, savegame_variable)
  -- This function can also be called by light arrows.
  -- Obtaining arrows increases the counter of the bow.
  local amounts = { 1, 3, 5 }
  local amount = amounts[variant]
  if amount == nil then
    error("Invalid variant '" .. variant .. "' for item 'arrow'")
  end
  game:get_item("bow"):add_amount(amount)
end

function item:on_pickable_created(pickable)
  if game:has_item("bow_light") then
    -- Automatically replace the normal arrow by a light one.
    local _, variant, savegame_variable = pickable:get_treasure()
    local map = pickable:get_map()
    local x, y, layer = pickable:get_position()
    map:create_pickable{
      layer = layer,
      x = x,
      y = y,
      treasure_name = "arrow_light",
      treasure_variant = variant,
      treasure_savegame_variable = savegame_variable,
    }
    pickable:remove()
  end
end