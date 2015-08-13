local enemy = ...
local behavior = require("enemies/generic/toward_hero")

-- Rope (snake): fast moving basic enemy.

local properties = {
  sprite = "enemies/rope",
  life = 1,
  damage = 2,
  normal_speed = 48,
  faster_speed = 64,
  movement_create = function()
    local m = sol.movement.create("path_finding")
    return m
  end
}
behavior:create(enemy, properties)