local enemy = ...
local behavior = require("enemies/generic/waiting_hero")

-- Leever: a basic desert enemy.

local properties = {
  sprite = "enemies/leever_green",
  life = 2,
  damage = 2,
  normal_speed = 40,
  faster_speed = 48,
  waking_distance = 200
}
behavior:create(enemy, properties)