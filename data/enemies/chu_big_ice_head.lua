local enemy = ...

-- Big Ice Chu: A large gelatinous miniboss who tries to either squish or freeze our hero.
-- This is the head, which can't be hurt but reacts to the base being hurt.

local initial_xy = {}

function enemy:on_created()
  base = self:get_map():get_entity("miniboss_chu")
  self:set_life(1); self:set_damage(6)
  self:set_size(48, 48); self:set_origin(24, 43)
  self:set_invincible()
  self:set_can_hurt_hero_running(true)

  initial_xy.x, initial_xy.y = self:get_position()

  -- go to the intermediate layer
  self:set_layer_independent_collisions(true)
  self:set_position(initial_xy.x, initial_xy.y, 1)

  local sprite = self:create_sprite("enemies/chu_big_ice_head")
  function sprite:on_animation_finished(animation)
    if animation == "hurt" then
       self:set_animation("walking")
    end
  end
end