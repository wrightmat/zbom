local enemy = ...
local behavior = require("enemies/generic/tektite")

-- Tektite: a jumping enemy which moves toward the hero.

local properties = {
  main_sprite = "enemies/tektite_blue",
  life = 3,
  damage = 4,
  normal_speed = 48,
  faster_speed = 72,
  max_height = 24
}

behavior:create(enemy, properties)