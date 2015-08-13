local enemy = ...
local behavior = require("enemies/generic/toward_hero")

-- Tentacle.

local properties = {
  sprite = "enemies/tentacle",
  life = 1,
  damage = 2,
  normal_speed = 32,
  faster_speed = 32,
  movement_create = function()
    return sol.movement.create("path_finding")
  end
}
behavior:create(enemy, properties)