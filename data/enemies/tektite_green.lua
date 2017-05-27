local enemy = ...
local behavior = require("enemies/generic/tektite")

-- Tektite: a jumping enemy which moves toward the hero.

local properties = {
  main_sprite = "enemies/tektite_green",
  life = 1,
  damage = 2,
  normal_speed = 48,
  faster_speed = 72,
}

behavior:create(enemy, properties)