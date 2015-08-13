local enemy = ...
local behavior = require("enemies/generic/toward_hero")

-- Zola.

local properties = {
  sprite = "enemies/zola",
  life = 3,
  damage = 2,
  normal_speed = 48,
  faster_speed = 64,
}
behavior:create(enemy, properties)