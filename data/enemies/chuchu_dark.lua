local enemy = ...
local behavior = require("enemies/generic/chuchu")

-- Dark ChuChu: a basic overworld enemy that follows the hero.
-- The dark variety will curse the hero if touched.

local properties = {
  sprite = "enemies/chuchu_dark",
  life = 6,
  damage = 12,
  normal_speed = 32,
  faster_speed = 40
}
behavior:create(enemy, properties)

function enemy:on_attacking_hero(hero)
  if not hero:is_invincible() then
    hero:start_hurt(6)
    hero:start_cursed(3000)
    hero:set_invincible(true, 3500)
  end
end