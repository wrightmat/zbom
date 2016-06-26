local enemy = ...
local state = "stopped"
local timer

-- Fire Keese (bat): Basic flying enemy, but also on fire!

function enemy:on_created()
  self:set_life(2); self:set_damage(4)
  local sprite = self:create_sprite("enemies/keese_fire")
  self:set_size(16, 16); self:set_origin(8, 13)
  self:set_hurt_style("monster")
  self:set_pushed_back_when_hurt(true)
  self:set_push_hero_on_sword(false)
  self:set_obstacle_behavior("flying")
  self:set_layer_independent_collisions(true)
  self:set_attack_consequence("fire", "protected")
  sprite:set_animation("stopped")
end

function enemy:on_update()
  local sprite = self:get_sprite()
  local hero = self:get_map():get_entity("hero")
  -- Check whether the hero is close.
  if self:get_distance(hero) <= 96 and state ~= "going" then
    if sprite == "enemies/keese_fire" then sprite:set_animation("walking") end
    local m = sol.movement.create("target")
    m:set_speed(64)
    m:start(self)
    state = "going"
  elseif self:get_distance(hero) > 96 and state ~= "random" then
    if sprite == "enemies/keese_fire" then sprite:set_animation("walking") end
    local m = sol.movement.create("random")
    m:set_speed(56)
    m:start(self)
    state = "random"
  elseif self:get_distance(hero) > 144 then
    if sprite == "enemies/keese_fire" then sprite:set_animation("stopped") end
    state = "stopped"
    self:stop_movement()
  end
end