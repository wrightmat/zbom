local entity = ...
local game = entity:get_game()
apple_created = false

-- Apple Tree

function entity:on_created()
  self:create_sprite("entities/tree_apple")
  self:set_size(64, 56)
  self:set_origin(32, 56)
  self:set_traversable_by(false)
  self:set_drawn_in_y_order(true)
  self:add_collision_test("touching", function(self, other)
    ex, ey, el = entity:get_position()
    if other:get_type() == "explosion" and not apple_created then
      -- Explosions dislodges an apple.
      entity:get_map():create_pickable({ layer = el, x = ex + 16, y = ey + 16, treasure_name = "apple" })
      apple_created = true
    elseif other:get_type() == "hero" and game:get_hero():get_state() == "running" and not apple_created then
      -- Link dashing into the tree dislodgess an apple.
      entity:get_map():create_pickable({ layer = el, x = ex + 16, y = ey + 16, treasure_name = "apple" })
      apple_created = true
    end
  end)
end