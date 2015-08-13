local enemy = ...
local behavior = require("enemies/generic/toward_hero")

-- Pengator.

local properties = {
  main_sprite = "enemies/pengator",
  life = 4,
  damage = 4,
  normal_speed = 40,
  faster_speed = 64,
}

behavior:create(enemy, properties)