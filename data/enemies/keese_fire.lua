local enemy = ...
local behavior = require("enemies/generic/keese")

-- Fire Keese (bat): Basic flying enemy, but also on fire!

local properties = {
  sprite = "enemies/keese_fire",
  life = 2,
  damage = 4,
  normal_speed = 56,
  faster_speed = 64
}
behavior:create(enemy, properties)
enemy:set_attack_consequence("fire", "protected")