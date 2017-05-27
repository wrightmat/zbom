local enemy = ...
local behavior = require("enemies/generic/keese")

-- Electric Keese (bat): Basic flying enemy, but also electrified!

local properties = {
  sprite = "enemies/keese_elec",
  life = 4,
  damage = 8,
  normal_speed = 56,
  faster_speed = 64
}
behavior:create(enemy, properties)

function enemy:on_attacking_hero(hero)
  if not hero:is_invincible() then
    hero:start_hurt(4)
    hero:start_electrocution(2000)
    hero:set_invincible(true, 3000)
  end
end