local enemy = ...
local behavior = require("enemies/generic/toward_hero")

-- Hinox.

local properties = {
  sprite = "enemies/hinox",
  life = 10,
  damage = 8,
  normal_speed = 40,
  faster_speed = 48
}

behavior:create(enemy, properties)