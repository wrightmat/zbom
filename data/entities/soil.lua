local soil = ...
local game = soil:get_game()
local hero = game:get_hero()
local map = soil:get_map()

-- Soft soil: special entity that the hero uses the
-- shovel on to dig up treasures.

soil:set_traversable_by(false)

function soil:on_interaction()
  game:start_dialog("_soft_soil")
end

local function test_collision_with_hero_shovel(soil, entity)
  if entity:get_type() ~= "hero" then
    -- Ignore collisions with entities other than the hero.
    return false
  end

  if hero:get_animation() ~= "shovel" then
    -- Don't bother testing collisions if the hero is not currently using the shovel.
    return false
  end

  -- The hero is using the shovel. Determine the exact point to test.
  local hero_direction = entity:get_direction()
  local x, y = entity:get_center_position()
  if hero_direction == 0 then
    x = x + 12     -- Right.
  elseif hero_direction == 1 then
    y = y - 12     -- Up.
  elseif hero_direction == 2 then
    x = x - 12     -- Left.
  else
    y = y + 12    -- Down.
  end

  -- Test if this point is inside the soil.
  return soil:overlaps(x, y)
end

soil:add_collision_test(test_collision_with_hero_shovel, function(soil, entity)
  -- Remove the soil pile and leave several treasures.
  local sx, sy, sl = soil:get_position()
  if map:get_world() == "outside_subrosia" then
    map:create_pickable({ layer = sl, x = sx, y = sy, treasure_name = "random_subrosia" })
  else
    map:create_pickable({ layer = sl, x = sx, y = sy, treasure_name = "random" })
  end
  sol.timer.start(soil, 100, function() -- Delay causes multiple treasures to be created.
    soil:remove()
  end)

  -- Notify people.
  if soil.on_dug ~= nil then soil:on_dug() end
end)