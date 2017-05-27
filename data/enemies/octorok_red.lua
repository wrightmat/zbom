local enemy = ...
local behavior = require("enemies/generic/octorok")

-- Octorok, Red.

local properties = {
  main_sprite = "enemies/octorok_red",
  life = 2,
  damage = 3,
  normal_speed = 48,
  faster_speed = 56,
  projectile ="projectiles/rock_small",
}

behavior:create(enemy, properties)