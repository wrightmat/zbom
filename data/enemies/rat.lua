local enemy = ...
local behavior = require("enemies/generic/toward_hero")

-- Rat: a basic enemy.

local properties = {
  sprite = "enemies/rat",
  life = 1,
  damage = 2,
  normal_speed = 32,
  faster_speed = 48,
}
behavior:create(enemy, properties)