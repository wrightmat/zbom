local enemy = ...
local behavior = require("enemies/generic/toward_hero")

-- Skeletor.

local properties = {
  sprite = "enemies/skeletor",
  life = 3,
  damage = 2,
}
behavior:create(enemy, properties)