local entity = ...
local map = entity:get_map()
local hero = map:get_entity("hero")

-- Quicksand: entity which slows the hero until
-- he finally falls in

function entity:on_created()
  self:create_sprite("entities/quicksand")
  self:set_size(32, 32)
  self:set_origin(16, 16)
  ex, ey, el, = self:get_position()
end

function entity:on_update()
  self:add_collision_test("overlapping", function()
    hero:set_walking_speed(hero:get_walking_speed()-1)
    m = sol.movement.create("target")
    m:set_target(ex, ey)
    m:start(hero)
  end)
end
