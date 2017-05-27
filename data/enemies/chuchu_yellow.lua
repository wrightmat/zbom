local enemy = ...
local behavior = require("enemies/generic/chuchu")

-- Yellow ChuChu: a basic overworld enemy that follows the hero.
-- The yellow variety can disappear into the ground and also try to electrocute the hero.

local properties = {
  sprite = "enemies/chuchu_yellow",
  life = 5,
  damage = 10,
  normal_speed = 32,
  faster_speed = 40
}
behavior:create(enemy, properties)

function enemy:on_attacking_hero(hero, enemy_sprite)
  if not hero:is_invincible() then
    hero:start_hurt(5)
    hero:start_electrocution(2000)
    hero:set_invincible(true, 3000)
  end
end