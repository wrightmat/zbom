local enemy = ...
local behavior = require("enemies/generic/toward_hero")

-- Red Helmasaur.

local properties = {
  sprite = "enemies/helmasaur_purple",
  life = 10,
  damage = 16,
  normal_speed = 32,
  faster_speed = 48,
}

behavior:create(enemy, properties)