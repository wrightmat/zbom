local enemy = ...
local behavior = require("enemies/generic/toward_hero")

-- Red Helmasaur.

local properties = {
  sprite = "enemies/helmasaur_blue",
  life = 8,
  damage = 12,
  normal_speed = 32,
  faster_speed = 48,
}

behavior:create(enemy, properties)