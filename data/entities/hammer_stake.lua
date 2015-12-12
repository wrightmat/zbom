local stake = ...
local game = stake:get_game()
local hero = game:get_hero()

-- Initially, the stake is an obstacle for any entity.
stake:set_traversable_by(false)

local function test_collision_with_hero_hammer(stake, entity)
  if entity:get_type() ~= "hero" then
    -- Ignore collisions with entities other than the hero.
    return false
  end

  if hero:get_animation() ~= "hammer" then
    -- Don't bother testing collisions if the hero is not currently using the hammer.
    return false
  end

  -- The hero is using the hammer. Determine the exact point to test.
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

  -- Test if this point is inside the stake.
  return stake:overlaps(x, y)
end

stake:add_collision_test(test_collision_with_hero_hammer, function(stake, entity)
  -- Change the animation to down.
  stake:get_sprite():set_animation("down")

  -- Tell the hammer it has just successfully pushed something.
  game:get_item("hammer"):set_pushed_stake(true)

  -- Allow entities to traverse this.
  stake:set_traversable_by(true)

  -- Disable collision detection, this is no longer needed.
  stake:clear_collision_tests()

  -- Notify people.
  if stake.on_pushed ~= nil then stake:on_pushed() end
end)