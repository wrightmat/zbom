local enemy = ...
local behavior = require("enemies/generic/toward_hero")

-- Ropa.

local properties = {
  sprite = "enemies/ropa",
  life = 8,
  damage = 4,
  normal_speed = 32,
  faster_speed = 40,
}
behavior:create(enemy, properties)