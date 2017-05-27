local enemy = ...
local behavior = require("enemies/generic/wizzrobe")

-- Wizzrobe: Ice magic enemy which shoots beams at the hero.

local properties = {
  main_sprite = "enemies/wizzrobe_ice",
  life = 8,
  damage = 12,
  normal_speed = 48,
  faster_speed = 72,
  type = "ice"
}

behavior:create(enemy, properties)