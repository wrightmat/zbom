local enemy = ...
local behavior = require("enemies/generic/keese")

-- Ice Keese (bat): Basic flying enemy, but also frozen!

local properties = {
  sprite = "enemies/keese_ice",
  life = 3,
  damage = 6,
  normal_speed = 56,
  faster_speed = 64
}
behavior:create(enemy, properties)

function enemy:on_attacking_hero(hero)
  if not hero:is_invincible() then
    hero:start_hurt(3)
    hero:start_frozen(2000)
    hero:set_invincible(true, 3000)
  end
end