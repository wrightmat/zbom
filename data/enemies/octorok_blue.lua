local enemy = ...
local behavior = require("enemies/generic/octorok")

-- Octorok, Blue.

local properties = {
  main_sprite = "enemies/octorok_blue",
  life = 4,
  damage = 6,
  normal_speed = 64,
  faster_speed = 72,
  projectile ="projectiles/rock_small"
}

behavior:create(enemy, properties)