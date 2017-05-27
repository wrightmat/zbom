local enemy = ...
local behavior = require("enemies/generic/chuchu")

-- White ChuChu: a basic overworld enemy that follows the hero.
-- The white variety will freeze the hero on touch.

local properties = {
  sprite = "enemies/chuchu_white",
  life = 4,
  damage = 8,
  normal_speed = 32,
  faster_speed = 40
}
behavior:create(enemy, properties)

function enemy:on_attacking_hero(hero, enemy_sprite)
  if not hero:is_invincible() then
    hero:start_hurt(4)
    hero:start_frozen(2000)
    hero:set_invincible(true, 3000)
  end
end