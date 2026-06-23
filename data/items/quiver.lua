local item = ...
local bow, arrow

function item:on_created()
  self:set_savegame_variable("i1803")

  -- Account for the Bow of Light versus the regular bow,
  -- so we don't inadvertently replace it.
  if self:get_game():get_value("i1852") then
    bow = self:get_game():get_item("bow_light")
  else
    bow = self:get_game():get_item("bow")
  end
  arrow = self:get_game():get_item("arrow")
end

function item:on_started()
  self:on_variant_changed(self:get_variant())
end

function item:on_variant_changed(variant)
  -- The quiver determines the maximum amount of the bow.
  if variant == 0 then
    bow:set_max_amount(0)
    arrow:set_obtainable(false)
  else
    local max_amounts = {10, 30, 60}
    local max_amount = max_amounts[variant]

    -- Set the max value of the bow counter.
    bow:set_max_amount(max_amount)

    -- Unlock pickable arrows.
    arrow:set_obtainable(true)
  end
end

function item:on_obtaining(variant, savegame_variable)
  if variant > 0 then
    bow:set_amount(bow:get_max_amount())
  end
end