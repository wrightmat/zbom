local enemy = ...

-- Lanmola: segmented enemy who appears from underground - this defines the
--          head segment directly then creates the body segments dynamically.

local head_present = false
local body_segment = 0

function enemy:on_created()
  self:set_life(8)
  self:set_damage(2)
  self:create_sprite("enemies/lanmola")
  self:set_hurt_style("boss")
  self:set_size(16, 16)
  self:set_origin(8, 8)
  self:set_invincible(true)
end

function enemy:go(speed)
  local hero = self:get_map():get_entity("hero")
  local m = sol.movement.create("target")
  m:set_speed(32)
  m:set_target(hero)
  m:set_ignore_obstacles(true)
  m:start(self)
  going_hero = true
end

function enemy:create_tail()
  tail = self:create_enemy{
    x = 0,
    y = -16,
    name = "lanmola_tail",
    breed = "lanmola_tail"
  }
  tail.head = self
  self:go(40)
end

function enemy:create_body()
  if body_segment < 6 then
    bx, by, bl = self:get_position()
    self:set_position(bx, by-8)
    body = self:create_enemy{
      x = 0,
      y = 8,
      name = "lanmola_body_1",
      breed = "lanmola_body"
    }
    body.head = self
    body_segment = body_segment + 1
    sol.timer.start(self, 300, function() self:create_body() end)
  elseif body_segment == 6 then
    self:create_tail()
  end
end

function enemy:create_head()
  self:get_sprite():set_animation("rocks")
  self:set_attack_consequence("sword", "protected")
  sol.timer.start(self, 1500, function()
    self:get_sprite():set_animation("walking")
    head_present = true
    self:create_body()
  end)
end

function enemy:on_enabled()
  self:create_head()
end

function enemy:on_restarted()
  if head_present then
    if body_segment < 6 then
      self:create_body()
    elseif body_segment > 6 and enemy:get_map():get_entity("lanmola_tail") == nil then
      self:create_tail()
    else
      self:go(40)
    end
  end
end

function enemy:on_obstacle_reached()
  self:go(40)
end
