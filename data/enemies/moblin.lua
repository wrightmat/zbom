local enemy = ...
local behavior = require("enemies/generic/toward_hero")

-- Moblin.

local properties = {
  sprite = "enemies/moblin",
  life = 8,
  damage = 4,
  normal_speed = 40,
  faster_speed = 48
}

behavior:create(enemy, properties)