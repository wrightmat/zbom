local enemy = ...
local behavior = require("enemies/generic/lizalfos")

-- Lizalfos.

local properties = {
  main_sprite = "enemies/lizalfos_blue",
  sword_sprite = "enemies/lizalfos_spear",
  life = 12,
  damage = 10,
  normal_speed = 48,
  faster_speed = 72,
}

behavior:create(enemy, properties)