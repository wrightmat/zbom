local enemy = ...
local behavior = require("enemies/generic/lizalfos")

-- Lizalfos.

local properties = {
  main_sprite = "enemies/lizalfos_yellow",
  life = 10,
  damage = 8,
  normal_speed = 48,
  faster_speed = 72,
}

behavior:create(enemy, properties)

function enemy:on_attacking_hero(hero)
  if not hero:is_invincible() then
    hero:start_electrocution(1500)
    hero:set_invincible(true, 3000)
  end
end