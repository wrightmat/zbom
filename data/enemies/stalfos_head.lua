local enemy = ...

-- Stalfos head: a enemy that flies around randomly
--       and freezes the hero if it touches him.

function enemy:on_created()
  self:set_life(1)
  self:set_damage(2)
  self:create_sprite("enemies/stalfos_head")
  self:set_attack_consequence("hookshot", "immobilized")
  self:set_size(16, 16)
  self:set_origin(8, 13)

  local m = sol.movement.create("random")
  m:set_speed(32)
  m:start(self)
end

function enemy:on_restarted()
  local m = sol.movement.create("random")
  m:set_speed(32)
  m:start(self)
end

function enemy:on_attacking_hero(hero, enemy_sprite)
  hero:start_frozen(1500)
end
