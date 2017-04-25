local enemy = ...
local behavior = require("enemies/generic/toward_hero")

-- Lizalfos.

local properties = {
  main_sprite = "enemies/lizalfos_yellow",
  life = 10,
  damage = 8,
  normal_speed = 48,
  faster_speed = 72,
}

behavior:create(enemy, properties)