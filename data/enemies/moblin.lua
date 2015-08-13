local enemy = ...
local behavior = require("enemies/generic/soldier")

-- Moblin.

local properties = {
  main_sprite = "enemies/moblin",
  life = 8,
  damage = 3,
  normal_speed = 40,
  faster_speed = 48,
}

behavior:create(enemy, properties)