local enemy = ...

-- Stone Arrghus: Miniboss who creates small rocks and has to be hit in the eye to be hurt
-- These are the small rocks - each direction turns a different color

function enemy:on_created()
  self:set_life(1)
  self:set_damage(1)
  self:create_sprite("enemies/arrghus_baby")
  self:set_size(24, 24)
  self:set_origin(12, 21)
  self:set_hurt_style("monster")
end

function enemy:on_update()
  local hero = self:get_map():get_entity("hero")
  local hx, hy, hl = hero:get_position()
  local dir = self:get_direction8_to(hx, hy)
  local m = sol.movement.create("jump")
  m:set_distance(30)
  m:set_direction8(dir)
  m:start(self)
end
