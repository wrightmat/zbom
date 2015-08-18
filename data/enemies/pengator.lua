local enemy = ...
local behavior = require("enemies/generic/toward_hero")

-- Pengator.

local properties = {
  sprite = "enemies/pengator",
  life = 6,
  damage = 4,
  normal_speed = 32,
  faster_speed = 48
}

behavior:create(enemy, properties)