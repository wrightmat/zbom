local enemy = ...

-- Big Ice Chu: A large gelatinous miniboss who
-- tries to either squish or freeze our hero.

local head = nil
local current_xy = {}
local freezing = false
local going_hero = false

function enemy:on_created()
  self:set_life(10)
  self:set_damage(2)
  self:create_sprite("enemies/chu_big_ice")
  self:set_size(48, 48)
  self:set_origin(24, 43)
  self:set_hurt_style("boss")
  self:set_pushed_back_when_hurt(false)
  self:set_push_hero_on_sword(true)

  -- Create the head.
  local my_name = self:get_name()
  head = self:create_enemy{
    name = my_name .. "_head",
    breed = "chu_big_ice_head",
    x = 0,
    y = -16
  }
  head.base = self
end

function enemy:on_restarted()
  if not freezing then
    if going_hero then
      self:go_hero()
    else
      self:go_random()
      self:check_hero()
    end
  end
  current_xy.x, current_xy.y = self:get_position()
end

function enemy:on_movement_finished(movement)
  if freezing then
    self:go_hero()
  end
end

function enemy:on_obstacle_reached(movement)
  if freezing then
    self:go_hero()
  end
end

function enemy:on_position_changed(x, y)
  if head:exists() then
    -- The base has just moved: do the same movement to the head.
    local dx = x - current_xy.x
    local dy = y - current_xy.y
    local head_x, head_y = head:get_position()
    head:set_position(head_x + dx, head_y + dy)
  end
  current_xy.x, current_xy.y = x, y
end

function enemy:on_attacking_hero(hero, enemy_sprite)
  -- If the enemy is frozen, then freeze the hero.
  if freezing then
    hero:start_frozen(3000)
  end
end

function enemy:on_hurt(attack)
  if timer ~= nil then
    timer:stop()
    timer = nil
  end

  -- The head wobbles when hurt.
  head:stop_movement()
  head:get_sprite():set_animation("hurt")

  -- If the enemy is frozen, then freeze the hero.
  -- A bomb explosion gets rid of the freezing ice.
  if freezing then
    if attack == "explosion" then
      freezing = false
      self:get_sprite():set_animation("walking")
    else
      hero:start_frozen(3000)
    end
  end
end

function enemy:on_dead()
  -- Kill the head.
  head:hurt(1)
end

function enemy:check_hero()
  local hero = self:get_map():get_entity("hero")
  local _, _, layer = self:get_position()
  local _, _, hero_layer = hero:get_position()
  local near_hero = layer == hero_layer
    and self:get_distance(hero) < 100

  if near_hero and not going_hero then
    self:go_hero()
  elseif near_hero and going_hero then
    self:freeze()
  elseif not near_hero and going_hero then
    self:go_random()
  end
  timer = sol.timer.start(self, 1000, function() self:check_hero() end)
end

function enemy:freeze()
  self:stop_movement()
  self:set_sprite():set_animation("ice")
  freezing = true
  timer = sol.timer.start(self, 10000, function()
    freezing = false
    self:get_sprite():set_animation("walking")
  end)
end

function enemy:go_random()
  local movement = sol.movement.create("random_path")
  movement:set_speed(32)
  movement:start(self)
  freezing = false
  going_hero = false
end

function enemy:go_hero()
  local movement = sol.movement.create("target")
  movement:set_speed(40)
  movement:start(self)
  freezing = false
  going_hero = true
end
