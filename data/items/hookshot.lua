local item = ...

-- Hookshot similar to the one of Zelda A Link to the Past.
-- Author: Christopho
--
-- It can hurt enemies, activate crystals and solid switches,
-- catch entities and transport the hero accross cliffs and bad grounds.
--
-- * Required resources:
-- - An animation "hookshot" in the hero sprites (at least for the tunic).
-- - A sprite "entities/hookshot" with animations "hookshot" (the default) and "link".
-- - A sound "hookshot".
--
-- * Hurting enemies:
-- Two new methods are available on enemies:
-- enemy:get_attack_hookshot() and enemy:set_attack_hookshot().
-- Call enemy:set_attack_hookshot() from your enemy scripts to define how they react:
-- immobilize him, hurt him, do nothing, etc.
-- The allowed values are the same as in enemy:set_attack_consequence().
--
-- * Activating mechanisms:
-- Solid switches and crystals can be activated by the hookshot.
--
-- * Catching entities:
-- You can customize which entities can be caught.
-- A list of entity types that can be caught is defined below.
-- You can also allow individual entities to be caught by defining a method
-- is_hookshot_catchable() returning true.
--
-- * Transporting the hero:
-- You can customize which entities the hookshot can hook to.
-- A list of entity types that are hookable is defined below.
-- You can also allow individual entities to be hookable by defining a method
-- is_hookshot_hook() returning true.
-- If the hero arrives inside an obstacle after the hookshot transportation,
-- his position is automatically adjusted to the last legal position along the way.

local distance = 208   -- Distance in pixels
local speed = 240   -- Speed in pixels per second.
-- What types of entities can be caught.
-- Additionally, all entities that have a method "is_hookshot_catchable(true)"
local catchable_entity_types = { "pickable" }
-- What types of entities the hookshot can attach to.
-- Additionally, all entities that have a method "is_hookshot_hook(true)"
local hook_entity_types = { "destructible" }

function item:on_created()
  self:set_savegame_variable("i1819")
  self:set_assignable(true)
end

-- Function called when the hero uses the hookshot item.
-- Creates a hookshot entity and sets up the movement.
function item:on_using()
  local going_back = false
  local sound_timer
  local direction
  local map = item:get_map()
  local hero = map:get_hero()
  local x, y, layer = hero:get_position()
  local direction = hero:get_direction()
  local hookshot 
  local hookshot_sprite
  local link_sprite
  local entities_caught = {}
  local hooked_entity
  local hooked
  local leader
  local go
  local go_back
  local hook_to_entity
  local stop

  -- Sets what can be traversed by the hookshot.
  -- Also used for the invisible leader entity used when hooked.
  local function set_can_traverse_rules(entity)
    entity:set_can_traverse("crystal", true)
    entity:set_can_traverse("crystal_block", true)
    entity:set_can_traverse("hero", true)
    entity:set_can_traverse("jumper", true)
    entity:set_can_traverse("stairs", false)  -- TODO only inner stairs should be obstacle and only when on their lowest layer.
    entity:set_can_traverse("stream", true)
    entity:set_can_traverse("switch", true)
    entity:set_can_traverse("teletransporter", true)
    entity:set_can_traverse_ground("deep_water", true)
    entity:set_can_traverse_ground("shallow_water", true)
    entity:set_can_traverse_ground("hole", true)
    entity:set_can_traverse_ground("lava", true)
    entity:set_can_traverse_ground("prickles", true)
    entity:set_can_traverse_ground("low_wall", true)  -- Needed for cliffs.
    entity.apply_cliffs = true
  end

  -- Returns if the hero would land on an obstacle at the specified coordinates.
  -- This is similar to entity:test_obstacles() but also checks layers below
  -- in case the ground is empty (because the hero will fall there).
  local function test_hero_obstacle_layers(candidate_x, candidate_y, candidate_layer)
    local hero_x, hero_y, hero_layer = hero:get_position()
    candidate_layer = candidate_layer or hero_layer
    if hero:test_obstacles(candidate_x - hero_x, candidate_y - hero_y, candidate_layer) then
      return true       -- Found an obstacle.
    end

    if candidate_layer == 0 then
      return false      -- Cannot go deeper and no obstacle was found.
    end

    -- Test if we are on empty ground.
    local origin_x, origin_y = hero:get_origin()
    local top_left_x, top_left_y = candidate_x - origin_x, candidate_y - origin_y
    local width, height = hero:get_size()
    if map:get_ground(top_left_x, top_left_y, candidate_layer) == "empty" and
        map:get_ground(top_left_x + width - 1, top_left_y, candidate_layer) == "empty" and
        map:get_ground(top_left_x, top_left_y + height - 1, candidate_layer) == "empty" and
        map:get_ground(top_left_x + width - 1, top_left_y + height - 1, candidate_layer) == "empty" then
      -- We are on empty ground: the hero will fall one layer down.
      return test_hero_obstacle_layers(candidate_x, candidate_y, candidate_layer - 1)
    end
  end

  -- Starts the hookshot movement from the hero.
  function go()
    local movement = sol.movement.create("straight")
    local angle = direction * math.pi / 2
    movement:set_speed(speed)
    movement:set_angle(angle)
    movement:set_smooth(false)
    movement:set_max_distance(distance)
    movement:start(hookshot)

    function movement:on_obstacle_reached()
      sol.audio.play_sound("sword_tapping")
      go_back()
    end

    function movement:on_finished()
      go_back()
    end

    -- Play a repeated sound.
    sound_timer = sol.timer.start(map, 150, function()
      sol.audio.play_sound("hookshot")
      return true  -- Repeat the timer.
    end)
    sol.audio.play_sound("hookshot")
  end

  -- Makes the hookshot come back to the hero.
  -- Does nothing if the hookshot is already going back.
  function go_back()
    if going_back then
      return
    end

    local movement = sol.movement.create("straight")
    local angle = (direction + 2) * math.pi / 2
    movement:set_speed(speed)
    movement:set_angle(angle)
    movement:set_smooth(false)
    movement:set_max_distance(hookshot:get_distance(hero))
    movement:set_ignore_obstacles(true)
    movement:start(hookshot)
    going_back = true

    function movement:on_position_changed()
      for _, entity in ipairs(entities_caught) do
        entity:set_position(hookshot:get_position())
      end
    end

    function movement:on_finished()
      stop()
    end
  end

  -- Attaches the hookshot to an entity and makes the hero fly there.
  function hook_to_entity(entity)
    if hooked then
      return      -- Already hooked.
    end

    hooked_entity = entity
    hooked = true
    hookshot:stop_movement()

    -- Create a new custom entity on the hero, move that entity towards the entity
    -- hooked and make the hero follow that custom entity.
    -- Using this intermediate custom entity rather than directly moving the hero
    -- allows better control on what can be traversed.
    leader = map:create_custom_entity({
      direction = direction,
      layer = layer,
      x = x,
      y = y,
      width = 16,
      height = 16,
    })
    leader:set_origin(8, 13)
    set_can_traverse_rules(leader)
    leader.apply_cliffs = true

    local movement = sol.movement.create("straight")
    local angle = direction * math.pi / 2
    movement:set_speed(speed)
    movement:set_angle(angle)
    movement:set_smooth(false)
    movement:set_max_distance(hookshot:get_distance(hero))
    movement:start(leader)

    -- Make the hero start a jump to be sure that nothing will happen
    -- if his layer is changed by a cliff or if the ground below him changes.
    -- The better solution would be a custom hero state but this is not possible yet.
    -- So we use a jump movement instead, which is close to what we want here
    -- with the hookshot (flying), and we stop that jump movement.
    hero:start_jumping(0, 100, true)
    hero:get_movement():stop()
    hero:set_animation("hookshot")
    hero:set_direction(direction)

    local past_positions = {}
    past_positions[1] = { hero:get_position() }

    function movement:on_position_changed()
      -- Teletransporters, holes, etc. are avoided because the hero is jumping.
      hero:set_position(leader:get_position())
      -- Remember all intermediate positions to find a legal place
      -- for the hero later in case he ends up in a wall.
      past_positions[#past_positions + 1] = { leader:get_position() }
    end

    function movement:on_finished()
      stop()
      if hero:test_obstacles(0, 0) then
        -- The hero ended up in a wall.
        local fixed_position = past_positions[1]  -- Initial position in case none is legal.
        for i = #past_positions, 2, -1 do
          if not test_hero_obstacle_layers(unpack(past_positions[i])) then
            -- Found a legal position.
            fixed_position = past_positions[i]
            break
          end
        end
        hero:set_position(unpack(fixed_position))
        hero:set_invincible(true, 1000)
        hero:set_blinking(true, 1000)
      end
    end
  end

  -- Destroys the hookshot and restores control to the player.
  function stop()
    hero:unfreeze()
    if hookshot ~= nil then
      sound_timer:stop()
      hookshot:remove()
    end
    if leader ~= nil then
      leader:remove()
    end
  end

  hero:freeze()  -- Block the hero.
  hero:set_animation("hookshot")

  -- Create the hookshot.
  hookshot = map:create_custom_entity({
    direction = direction,
    layer = layer,
    x = x,
    y = y,
    width = 16,
    height = 16,
  })
  hookshot:set_origin(8, 13)
  hookshot:set_drawn_in_y_order(true)

  -- Set up hookshot sprites.
  hookshot_sprite = hookshot:create_sprite("entities/hookshot")
  hookshot_sprite:set_direction(direction)
  link_sprite = sol.sprite.create("entities/hookshot")
  link_sprite:set_animation("link")

  function hookshot:on_pre_draw()
    -- Draw the links.
    local num_links = 7
    local dxy = {
      {  16,  -5 },
      {   0, -13 },
      { -16,  -5 },
      {   0,   7 }
    }
    local hero_x, hero_y = hero:get_position()
    local x1 = hero_x + dxy[direction + 1][1]
    local y1 = hero_y + dxy[direction + 1][2]
    local x2, y2 = hookshot:get_position()
    y2 = y2 - 5
    for i = 0, num_links - 1 do
      local link_x = x1 + (x2 - x1) * i / num_links
      local link_y = y1 + (y2 - y1) * i / num_links

      -- Skip the first one when going to the North because it overlaps
      -- the hero sprite and can be drawn above it sometimes.
      local skip = direction == 1 and link_x == hero_x and i == 0
      if not skip then
        map:draw_sprite(link_sprite, link_x, link_y)
      end
    end
  end

  -- Set what can be traversed by the hookshot.
  set_can_traverse_rules(hookshot)

  -- Set up collisions.
  hookshot:add_collision_test("overlapping", function(hookshot, entity)
    local entity_type = entity:get_type()
    if entity_type == "hero" then
      -- Reaching the hero while going back: stop the hookshot.
      if going_back then
        stop()
      end
    elseif entity_type == "crystal" then
      -- Activate crystals.
      if not hooked and not going_back then
        sol.audio.play_sound("switch")
        map:change_crystal_state()
        go_back()
      end
    elseif entity_type == "switch" then
      -- Activate solid switches.
      local switch = entity
      local sprite = switch:get_sprite()
      if not hooked and
          not going_back and
          sprite ~= nil and
          sprite:get_animation_set() == "entities/solid_switch" then
        if switch:is_activated() then
          sol.audio.play_sound("sword_tapping")
        else
          sol.audio.play_sound("switch")
          switch:set_activated(true)
        end
        go_back()
      end
    elseif entity.is_hookshot_catchable ~= nil and entity:is_hookshot_catchable() then
      -- Catch the entity with the hookshot.
      if not hooked and not going_back then
        entities_caught[#entities_caught + 1] = entity
        entity:set_position(hookshot:get_position())
        hookshot:set_modified_ground("traversable")  -- Don't let the caught entity fall in holes.
        go_back()
      end
    end
  end)

  local hook_point_dxy = {
    {  8,  0 },
    {  0, -9 },
    { -9,  0 },
    {  0,  8 },
  }

  -- Custom collision test for hooks: there is a collision with a hook if
  -- the facing point of the hookshot overlaps the hook's bounding box.
  -- We cannot use the built-in "facing" collision mode because it would
  -- test the facing point of the hook, not the one of of the hookshot.
  -- And we cannot reverse the test because the hook is not necessarily a custom entity.
  local function test_hook_collision(hookshot, entity)
    if hooked or going_back then
      return      -- No need to check coordinates, we are already hooked.
    end

    if entity.is_hookable == nil or not entity:is_hookable() then
      return      -- Don't bother check coordinates, we don't care about this entity.
    end

    local facing_x, facing_y = hookshot:get_center_position()
    facing_x = facing_x + hook_point_dxy[direction + 1][1]
    facing_y = facing_y + hook_point_dxy[direction + 1][2]
    return entity:overlaps(facing_x, facing_y)
  end

  hookshot:add_collision_test(test_hook_collision, function(hookshot, entity)
    if hooked or going_back then
      return
    end

    if entity.is_hookshot_hook ~= nil and entity:is_hookshot_hook() then
      hook_to_entity(entity)      -- Hook to this entity.
    end
  end)

  -- Detect enemies.
  hookshot:add_collision_test("sprite", function(hookshot, entity, hookshot_sprite, enemy_sprite)
    local entity_type = entity:get_type()
    if entity_type == "enemy" then
      local enemy = entity
      if hooked then
        return
      end
      local reaction = enemy:get_attack_hookshot(enemy_sprite)
      enemy:receive_attack_consequence("hookshot", reaction)
      go_back()
    end
  end)

  -- Start the movement.
  go()

  -- Tell the engine that we are no longer using the item.
  item:set_finished()
end

-- Initialize the metatable of appropriate entities to work with the hookshot.
local function initialize_meta()

  -- Add Lua hookhost properties to enemies.
  local enemy_meta = sol.main.get_metatable("enemy")
  if enemy_meta.get_attack_hookshot ~= nil then
    return    -- Already done.
  end

  enemy_meta.attack_hookshot = 1  -- 1 life point by default.
  enemy_meta.attack_hookshot_sprite = {}
  function enemy_meta:get_attack_hookshot(sprite)
    if sprite ~= nil and self.attack_hookshot_sprite[sprite] ~= nil then
      return self.attack_hookshot_sprite[sprite]
    end
    return self.attack_hookshot
  end

  function enemy_meta:set_attack_hookshot(reaction, sprite)
    self.attack_hookshot = reaction
  end

  function enemy_meta:set_attack_hookshot_sprite(sprite, reaction)
    self.attack_hookshot_sprite[sprite] = reaction
  end

  -- Change the default enemy:set_invincible() to also take into account the hookshot.
  local previous_set_invincible = enemy_meta.set_invincible
  function enemy_meta:set_invincible()
    previous_set_invincible(self)
    self:set_attack_hookshot("ignored")
  end
  local previous_set_invincible_sprite = enemy_meta.set_invincible_sprite
  function enemy_meta:set_invincible_sprite(sprite)
    previous_set_invincible_sprite(self, sprite)
    self:set_attack_hookshot_sprite(sprite, "ignored")
  end

  -- Set up entity types catchable with the hookshot.
  for _, entity_type in ipairs(catchable_entity_types) do
    local meta = sol.main.get_metatable(entity_type)
    function meta:is_hookshot_catchable()
      return true
    end
  end

  -- Set up entity types hookable with the hookshot.
  for _, entity_type in ipairs(hook_entity_types) do
    local meta = sol.main.get_metatable(entity_type)
    function meta:is_hookshot_hook()
      return true
    end
  end
end

initialize_meta()