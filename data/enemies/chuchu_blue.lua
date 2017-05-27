local enemy = ...
local behavior = require("enemies/generic/chuchu")

-- Blue ChuChu: a basic enemy that follows the hero.
-- The blue variety can disappear into the ground.

local properties = {
  sprite = "enemies/chuchu_blue",
  life = 3,
  damage = 6,
  normal_speed = 32,
  faster_speed = 40
}
behavior:create(enemy, properties)