local enemy = ...
local behavior = require("enemies/generic/tektite")

-- Tektite: a jumping enemy which moves toward the hero.

local properties = {
  main_sprite = "enemies/tektite_red",
  life = 2,
  damage = 3,
  normal_speed = 48,
  faster_speed = 72,
}

behavior:create(enemy, properties)