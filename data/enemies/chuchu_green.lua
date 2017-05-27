local enemy = ...
local behavior = require("enemies/generic/chuchu")

-- Green ChuChu: a basic overworld enemy that follows the hero.
-- The green variety is the first discovered and easiest in this game.

local properties = {
  sprite = "enemies/chuchu_green",
  life = 1,
  damage = 2,
  normal_speed = 32,
  faster_speed = 40
}
behavior:create(enemy, properties)