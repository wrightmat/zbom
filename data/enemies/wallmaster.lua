local enemy = ...
local map = enemy:get_map()
local hero = map:get_hero()
local sprite
local shadow
local grabbed_hero

-- Wallmaster: Falling hand that teleports the hero back to the entrance.

function enemy:on_created()
  self:set_life(10); self:set_damage(0)
  sprite = self:create_sprite("enemies/wallmaster")
  self:set_size(16, 16); self:set_origin(8, 13)
  self:set_obstacle_behavior("flying")
  self:set_can_hurt_hero_running(true)
  self:set_layer_independent_collisions(true)
  self:set_optimization_distance(0)
  sprite:set_animation("sleeping")
  self:set_pushed_back_when_hurt(false)
  self:set_attack_arrow(5)
end

function enemy:on_restarted()
  if shadow ~= nil then
    shadow:remove()
  end
  grabbed_hero = false
  sprite:set_animation("sleeping")

  sol.timer.start(enemy, math.random(10)*2000, function()
    if not enemy:is_in_same_region(hero) then
      return true
    end

    local hero_x, hero_y, hero_layer = hero:get_position()
    enemy:set_position(hero_x, hero_y, 2)
    local distance = 240  -- Make sure that we start outside the visible screen.
    sprite:set_xy(0, -distance)  -- Display the sprite with an offset.

    -- Move the sprite toward the hero.
    local movement = sol.movement.create("straight")
    movement:set_speed(192)
    movement:set_angle(3 * math.pi / 2)
    movement:set_ignore_obstacles(true)
    movement:set_max_distance(distance)
    movement:start(sprite)

    function movement:on_finished()
      sol.timer.start(enemy, 500, function()
        sprite:set_animation("closed")
      end)
    end

    sprite:set_animation("walking")

    -- Create a shadow below the hero.
    -- The hand is above, this is why we need two entities.
    shadow = map:create_custom_entity({
      x = hero_x,
      y = hero_y,
      width = 32,
      height = 8,
      layer = hero_layer,
      direction = 0,
    })
    local shadow_sprite = shadow:create_sprite("enemies/wallmaster")
    shadow_sprite:set_animation("shadow")

    sol.timer.start(enemy, 500, function()
      sol.audio.play_sound("jump")
    end)

    -- Go back.
    sol.timer.start(enemy, 3000, function()
      if not grabbed_hero then
        movement:set_angle(math.pi / 2)
        movement:set_speed(192)
        movement:start(sprite)
        function movement:on_finished()
          enemy:restart()
        end
      end
    end)
  end)
end

-- Function called when overlapping the hero.
function enemy:on_attacking_hero(hero, enemy_sprite)
  local movement = sprite:get_movement()
  if movement ~= nil and movement:get_speed() ~= 0 then
    -- Currently moving: don't grab the hero now.
    return
  end

  if enemy_sprite ~= sprite then
    -- Not the hand sprite but the shadow.
    return
  end

  if sprite:get_animation() ~= "closed" then
    -- Not the hand grabbing.
    return
  end

  if enemy:get_distance(hero) > 8 then
    -- The hero overlaps the hand but is still far enough from the center.
    return
  end

  -- Teleport the hero.
  grabbed_hero = true
  hero:freeze()
  hero:set_invincible(true, 500)
  sol.timer.start(hero, 500, function()
    sol.audio.play_sound("hero_hurt")
    hero:set_animation("hurt")
    local game = hero:get_game()
    hero:teleport(game:get_starting_location())

    -- When teleporting to the same room, restart the hand while the screen is black.
    sol.timer.start(game, 600, function()
      if enemy:exists() then
        enemy:restart()
      end
    end)
  end)
end

function enemy:on_removed()
  if shadow ~= nil then
    shadow:remove()
  end
end