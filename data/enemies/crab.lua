local enemy = ...
local behavior = require("enemies/generic/toward_hero")

-- Crab: a basic enemy.

local properties = {
  sprite = "enemies/crab",
  life = 2,
  damage = 2,
  normal_speed = 32,
  faster_speed = 40,
}
behavior:create(enemy, properties)