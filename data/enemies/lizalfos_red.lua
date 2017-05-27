local enemy = ...
local behavior = require("enemies/generic/lizalfos")

-- Lizalfos.

local properties = {
  main_sprite = "enemies/lizalfos_red",
  life = 8,
  damage = 8,
  normal_speed = 48,
  faster_speed = 72,
}

behavior:create(enemy, properties)