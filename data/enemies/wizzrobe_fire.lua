local enemy = ...
local behavior = require("enemies/generic/wizzrobe")

-- Wizzrobe: Fire magic enemy which shoots beams at the hero.

local properties = {
  main_sprite = "enemies/wizzrobe_fire",
  life = 6,
  damage = 8,
  normal_speed = 48,
  faster_speed = 72,
  type = "fire"
}

behavior:create(enemy, properties)