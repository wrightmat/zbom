local entity = ...
local map = entity:get_map()

-- Ice block: special block made of ice that must be
-- melted with the lantern (can't be moved)

function entity:on_created()
  self:set_size(16, 16)
  self:snap_to_grid()
  self:set_modified_ground("ice")
  self:set_traversable_by("hero", false)
  self:set_traversable_by("enemy", false)
  self:set_traversable_by("npc", false)
  self:create_sprite("entities/ice_block")
  
  self:add_collision_test("overlapping", function(self, other)
    if other:get_type() == "fire" then
      sol.audio.play_sound("ice_melt")
      self:remove_explode()
    elseif other:get_type() == "explosion" then
      sol.audio.play_sound("ice_melt")
      self:remove_explode()
    end
  end)
end

function entity:remove_explode()
  if self:get_sprite() == "entities/ice_block" then self:get_sprite():set_animation("destroy") end
  self:remove()
end