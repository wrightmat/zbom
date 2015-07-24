local entity = ...
local game = entity:get_game()
local map = entity:get_map()

-- Soft soil: special entity that the hero uses the
-- shovel on to dig up treasure.

function entity:on_created()
  self:create_sprite("entities/soil")
  self:set_size(16, 16)
  self:set_origin(8, 13)
  self:set_traversable_by(false)
end

function entity:on_interaction()
  game:start_dialog("_soft_soil")
end

function entity:on_interaction_item(item_used)
  if item_used == "shovel" then
    local sx, sy, sl = self:get_position()
    self:remove()
    map:create_pickable({
      layer = sl,
      x = sx,
      y = sy,
      treasure_name = "random"
    })
  end
end