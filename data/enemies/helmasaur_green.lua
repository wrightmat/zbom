local enemy = ...
local behavior = require("enemies/generic/toward_hero")

-- Red Helmasaur.

local properties = {
  sprite = "enemies/helmasaur_green",
  life = 3,
  damage = 4,
  normal_speed = 32,
  faster_speed = 48,
}

behavior:create(enemy, properties)