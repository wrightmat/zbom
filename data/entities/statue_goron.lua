local entity = ...

-- Goron Mausoleum Statue: special variety that contains
-- a Goron spirit which will grant you magic when it's
-- freed. Only used in the Mountaintop Mausoleum temple.

function entity:on_created()
  self:create_sprite("entities/statue_goron")
  self:set_size(32, 32)
  self:set_origin(16, 28)
end

function entity:on_interaction()
  game:start_dialog("_goron_statue")
end

function entity:on_interaction_item(item_used)
  if item_used == "bomb" then
    game:add_magic(10)
    self:remove()
  end
end
