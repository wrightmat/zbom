local enemy = ...

-- Ice Keese (bat): Basic flying enemy, but also frozen!

local state = "stopped"
local timer

function enemy:on_created()
  self:set_life(2)
  self:set_damage(2)
  self:create_sprite("enemies/keese_ice")
  self:set_hurt_style("monster")
  self:set_pushed_back_when_hurt(true)
  self:set_push_hero_on_sword(false)
  self:set_obstacle_behavior("flying")
  self:set_layer_independent_collisions(true)
  self:set_size(16, 16)
  self:set_origin(8, 13)
  self:get_sprite():set_animation("stopped")
end

function enemy:on_update()
  local hero = self:get_map():get_entity("hero")
  -- Check whether the hero is close.
  if self:get_distance(hero) <= 96 and state ~= "going" then
    self:get_sprite():set_animation("walking")
    local m = sol.movement.create("target")
    m:set_ignore_obstacles(true)
    m:set_speed(64)
    m:start(self)
    state = "going"
  elseif self:get_distance(hero) > 96 and state ~= "random" then
    self:get_sprite():set_animation("walking")
    local m = sol.movement.create("random")
    m:set_speed(56)
    m:start(self)
    state = "random"
  elseif self:get_distance(hero) > 144 then
    self:get_sprite():set_animation("stopped")
    state = "stopped"
    self:stop_movement()
  end
end

function enemy:on_attacking_hero(hero)
  if not hero:is_invincible() then
    -- Hero is frozen.
    hero:start_hurt(2)
    hero:start_frozen(2000)
    hero:set_invincible(true, 3000)
  end
end
