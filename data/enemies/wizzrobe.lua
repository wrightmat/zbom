local enemy = ...
local behavior = require("enemies/generic/wizzrobe")

-- Wizzrobe: Magical enemy which shoots beams at the hero.

local properties = {
  main_sprite = "enemies/wizzrobe",
  life = 4,
  damage = 4,
  normal_speed = 48,
  faster_speed = 72,
}

behavior:create(enemy, properties)