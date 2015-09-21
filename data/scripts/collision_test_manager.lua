local game = ...

--[[ 
This script is used as a workaround to be able to delete only one collision test on a custom entity. 

To use it write the following in the game manager:
sol.main.load_file("scripts/collision_test_manager.lua")(game)

To stop all collision tests with the possibility of restarting them later, use first 
entity:clear_collision_tests(), and later game:restart_collision_tests(entity)
--]]

-- Add a collision test to an entity. Assign a name to reference to it, in case we need to stop it later.
function game:add_collision_test(entity, name, collision_test, callback)
  -- Create the list of collision tests if necessary.
  if not entity.collision_tests then entity.collision_tests = {} end
  -- Store the info of the collision test.
  local info = {collision_test = collision_test, callback = callback}
  entity.collision_tests[name] = info
  -- Create the collision test (the engine does it).
  entity:add_collision_test(collision_test, callback)
end

-- Restart custom collision tests.
function game:restart_collision_tests(entity)
  -- Stop all collision tests (done by the engine).
  entity:clear_collision_tests()
  -- Re-create all the collision tests stored on the list.
  for _, info in pairs(entity.collision_tests) do 
    entity:add_collision_test(info.collision_test, info.callback)
  end
end

-- Remove a collision test of an entity of a given reference name.
function game:clear_collision_test(entity, name)
  -- Remove info of the collision test from the list.
  entity.collision_tests[name] = nil
  -- Restart collision tests.
  game:restart_collision_tests(entity)
end

-- Remove all collision tests of an entity.
function game:clear_collision_tests(entity)
  -- Stop all collision tests (done by the engine).
  entity:clear_collision_tests()
  -- Remove info of all the collision tests from the list.
  entity.collision_tests = {}
end

-- Boolean function. True if the collision test exists.
function game:has_collision_test(entity, name)
  if not entity.collision_tests then return nil
  else return entity.collision_tests[name] ~= nil
  end
end
