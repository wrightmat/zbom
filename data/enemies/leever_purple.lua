local enemy = ...
local behavior = require("enemies/generic/waiting_hero")

-- Leever: a basic desert enemy.

local properties = {
  sprite = "enemies/leever_purple",
  life = 5,
  damage = 3,
  normal_speed = 40,
  faster_speed = 48,
  waking_distance = 150
}
behavior:create(enemy, properties)