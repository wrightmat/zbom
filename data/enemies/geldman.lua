local enemy = ...
local behavior = require("enemies/generic/waiting_hero")

-- Geldman: a basic desert enemy.

local properties = {
  sprite = "enemies/geldman",
  life = 3,
  damage = 2,
  normal_speed = 40,
  faster_speed = 48,
  waking_distance = 80
}
behavior:create(enemy, properties)