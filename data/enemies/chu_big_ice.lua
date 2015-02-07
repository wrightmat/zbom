local enemy = ...
local map = enemy:get_map()

-- Big Ice Chu: A large gelatinous miniboss who
-- tries to freeze our hero.

local head = nil
local current_xy = {}
local freezing = false
local going_hero = false
local freeze_timer = nil

function enemy:on_created()
  self:set_life(8)
  self:set_damage(4)
  self:create_sprite("enemies/chu_big_ice")
  self:set_size(48, 48)
  self:set_origin(24, 43)
  self:set_hurt_style("boss")
  self:set_pushed_back_when_hurt(false)
  self:set_push_hero_on_sword(true)
  self:set_attack_consequence("explosion", "custom")
--end

--function enemy:on_enabled()
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
    print('restarted: not freezing')
    if going_hero then
      self:freeze()
    else
      self:go_random()
      self:check_hero()
    end
  else
    print('restarted: freezing')
  end
  current_xy.x, current_xy.y = self:get_position()
end

function enemy:on_movement_finished(movement)
  self:restart()
end

function enemy:on_obstacle_reached(movement)
  self:restart()
end

function enemy:on_position_changed(x, y)
  if head ~= nil then
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
    print('freezing the hero on attack')
    if not freeze_timer then
      map:get_hero():start_hurt(2)
      map:get_hero():start_frozen(3000)
    end
    freeze_timer = sol.timer.start(self, 4000, function() freeze_timer = nil end)
  end
end

function enemy:on_hurt(attack)
  print('hurt')
  -- The head wobbles when hurt.
  head:stop_movement()
  head:get_sprite():set_animation("hurt")

  sol.timer.start(self, 1000, function() self:go_random() end)
end

function enemy:on_custom_attack_received(attack, sprite)
  -- If the enemy is frozen, then freeze the hero.
  -- A bomb explosion gets rid of the freezing ice.
  if attack == "sword" then
    print('custom attack received: sword')
    if not freeze_timer then
      map:get_hero():start_hurt(2)
      map:get_hero():start_frozen(3000)
    end
    freeze_timer = sol.timer.start(self, 4000, function() freeze_timer = nil end)
  elseif attack == "explosion" then
    print('custom attack received: explosion')
    freezing = false
    sol.audio.play_sound("ice_shatter")
    self:get_sprite():set_animation("walking")
    self:set_attack_consequence("sword", 1)
    self:check_hero()
  end
end

function enemy:on_dying()
  print('dying')
  sol.timer.start(self:get_map(), 1000, function()
    head:set_life(0)
  end)
end

function enemy:on_update()
  if freezing then
    self:get_sprite():set_animation("ice")
    self:set_attack_consequence("sword", "custom")
  else
    self:get_sprite():set_animation("walking")
    self:set_attack_consequence("sword", 1)
  end
end

function enemy:check_hero()
  if not freezing then
    local hero = self:get_map():get_entity("hero")
    local _, _, layer = self:get_position()
    local _, _, hero_layer = hero:get_position()
    local near_hero = layer == hero_layer
      and self:get_distance(hero) < 200

    if near_hero then
      if math.random(2) == 1 then
	self:create_enemy{
	  name = "miniboss_chuchu",
	  breed = "chuchu_blue",
	  x = -16,
	  y = -16
	}
      else
        self:go_hero()
      end
    else
      self:go_random()
    end
    sol.timer.start(self, 5000, function() self:check_hero() end)
  end
end

function enemy:freeze()
  print('freezing')
  self:stop_movement()
  self:get_sprite():set_animation("ice")
  self:set_attack_consequence("sword", "custom")
  self:set_attack_consequence("explosion", "custom")
  freezing = true
end

function enemy:go_random()
  print('going random')
  local movement = sol.movement.create("random_path")
  movement:set_speed(32)
  movement:start(self)
  freezing = false
  going_hero = false
end

function enemy:go_hero()
  print('going hero')
  local movement = sol.movement.create("target")
  movement:set_speed(40)
  movement:start(self)
  freezing = false
  going_hero = true
end
