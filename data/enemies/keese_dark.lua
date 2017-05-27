local enemy = ...
local behavior = require("enemies/generic/keese")

-- Dark Keese (bat): Basic flying enemy, but also curses the hero.

local properties = {
  sprite = "enemies/keese_dark",
  life = 5,
  damage = 10,
  normal_speed = 56,
  faster_speed = 64
}
behavior:create(enemy, properties)

function enemy:on_attacking_hero(hero)
  if not hero:is_invincible() then
    hero:start_hurt(5)
    hero:start_cursed(3000)
    hero:set_invincible(true, 3500)
  end
end