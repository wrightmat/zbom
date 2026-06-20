local entity = ...
local game = entity:get_game()
local map = entity:get_map()
local sprite
entity.can_burn = false


function entity:on_created()
  entity:remove_sprite()
  sprite = entity:create_sprite("entities/stone_ocean_" .. math.random(3))
  if sprite:get_num_frames() > 1 then
    sprite:set_frame(math.random(1, sprite:get_num_frames() - 1))
  end
  entity:set_drawn_in_y_order()
  entity:set_traversable_by(false)
end
