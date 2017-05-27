local enemy = ...
local behavior = require("enemies/generic/octorok")

-- Octolux: More powerful enemy who wanders and shoots rocks.

local properties = {
  main_sprite = "enemies/octolux",
  life = 6,
  damage = 12,
  normal_speed = 64,
  faster_speed = 72,
  projectile ="projectiles/rock_lux"
}

behavior:create(enemy, properties)