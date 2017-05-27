local enemy = ...
local behavior = require("enemies/generic/wizzrobe")

-- Wizzrobe: Electric magic enemy which shoots beams at the hero.

local properties = {
  main_sprite = "enemies/wizzrobe_elec",
  life = 10,
  damage = 16,
  normal_speed = 48,
  faster_speed = 72,
  type = "elec"
}

behavior:create(enemy, properties)