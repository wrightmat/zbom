local entity = ...
local game = entity:get_game()

-- Goron Mausoleum Statue: special variety that contains
-- a Goron spirit which will grant you magic when it's
-- freed. Only used in the Mountaintop Mausoleum temple.

function entity:on_created()
  self:create_sprite("entities/statue_goron")
  self:set_size(32, 32)
  self:set_origin(16, 28)
  self:set_traversable_by(false)
  self:add_collision_test("overlapping", function(self, other)
    if other:get_type() == "explosion" then
      self:remove()
      game:start_dialog("_goron_statue_destroyed")
      game:add_magic(20)
    end
  end)
end

function entity:on_interaction()
  game:start_dialog("_goron_statue")
end