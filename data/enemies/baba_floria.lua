local enemy = ...

-- Floria Baba

local in_ground = false
local shoot_timer

function enemy:on_created()
  self:set_life(4)
  self:set_damage(4)
  self:create_sprite("enemies/baba_floria")
  self:set_size(24, 32)
  self:set_origin(12, 29)
  self:set_pushed_back_when_hurt(false)
  self:set_attack_consequence("sword", "custom")
  self:set_attack_consequence("arrow", "custom")
  sol.timer.start(self, 2000, function() self:check_hero() end)
end

function enemy:on_restarted()
  self:check_hero()
end

function enemy:shoot()
  d = self:get_sprite():get_direction()
  shoot_timer = sol.timer.start(self, 100, function()
    local seed = self:create_enemy{
      breed = "baba_seed",
      direction = d
    }
    sol.timer.start(self, 2000, function()
      shoot_timer = nil
      self:check_hero()
    end)
  end)
end

function enemy:check_hero()
  local hero = self:get_map():get_entity("hero")
  local hx, hy, hl = hero:get_position()
  local ex, ey, el = self:get_position()
  local esx, esy = self:get_size()
  if not in_ground then
    sol.timer.start(self, 2000, function()
      if enemy ~= nil then self:get_sprite():set_animation("walking") end
    end)
  end
  if enemy ~= nil then
    if hy < (ey-esy) then
      self:get_sprite():set_direction(1) --up
    elseif hy > (ey+esy) then
      self:get_sprite():set_direction(3) --down
    else
      if hx < ex then
        self:get_sprite():set_direction(2) --left
      else
        self:get_sprite():set_direction(0) --right
      end
    end
  end

  if math.random(10) <= 5 then
    sol.timer.start(self, 2000, function() self:check_hero() end)
  else
    sol.timer.start(self, 2000, function() self:shoot() end)
  end
end

function enemy:on_custom_attack_received(attack, sprite)
  local hero = self:get_map():get_entity("hero")
  local hx, hy, hl = hero:get_position()
  local ex, ey, el = self:get_position()

  if attack == "sword" then
    if self:get_sprite():get_direction() == 0 then
       --right, hero can't hurt if facing left
      if hero:get_direction() ~= 2 and not in_ground then
        self:get_sprite():set_animation("hurt")
	enemy:hurt(1)
	self:remove_life(1)
	self:check_hero()
      end
    elseif self:get_sprite():get_direction() == 1 then
       --up, hero can't hurt if facing down
      if hero:get_direction() ~= 3 and not in_ground then
        self:get_sprite():set_animation("hurt")
	enemy:hurt(1)
	self:remove_life(1)
	self:check_hero()
      end
    elseif self:get_sprite():get_direction() == 2 then
       --left, hero can't hurt if facing right
      if hero:get_direction() ~= 0 and not in_ground then
        self:get_sprite():set_animation("hurt")
	enemy:hurt(1)
	self:remove_life(1)
	self:check_hero()
      end
    elseif self:get_sprite():get_direction() == 3 then
       --down, hero can't hurt if facing up
      if hero:get_direction() ~= 1 and not in_ground then
        self:get_sprite():set_animation("hurt")
	enemy:hurt(1)
	self:remove_life(1)
	self:check_hero()
      end
    end
  elseif attack == "arrow" then
    self:get_sprite():set_animation("ground")
    in_ground = true
    sol.timer.start(self:get_map(), 3000, function()
      in_ground = false
      self:get_sprite():set_animation("emerging")
      self:restart()
    end)
  end
end

function enemy:on_movement_changed(movement)
  local direction4 = movement:get_direction4()
  local sprite = self:get_sprite()
  sprite:set_direction(direction4)
end
