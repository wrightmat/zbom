local enemy = ...
local behavior = require("enemies/generic/soldier")

-- Lizalfos.

local properties = {
  main_sprite = "enemies/lizalfos",
  sword_sprite = "enemies/lizalfos_sword",
  life = 6,
  damage = 6,
  normal_speed = 48,
  faster_speed = 72,
}

behavior:create(enemy, properties)