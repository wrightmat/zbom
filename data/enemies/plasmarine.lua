local enemy = ...

-- Plasmarine: a boss which floats around shooting
--       electricity balls in order to electricute hero.
-- TODO: Fix movement (placeholder based on bari)
--	 Shoot balls of electricity
--	 Create baris?

function enemy:on_created()
  self:set_life(10)
  self:set_damage(4)
  self:create_sprite("enemies/plasmarine_blue")
  self:set_size(32, 32)
  self:set_origin(16, 28)
end

function enemy:on_restarted()
  local m = sol.movement.create("path_finding")
  m:set_speed(32)
  m:start(self)
end
