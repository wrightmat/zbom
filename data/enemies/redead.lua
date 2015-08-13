local enemy = ...
local behavior = require("enemies/generic/toward_hero")

-- Redead: an undead enemy.

local properties = {
  sprite = "enemies/redead",
  life = 6,
  damage = 4,
  normal_speed = 32,
  faster_speed = 40,
}
behavior:create(enemy, properties)

enemy:set_attack_consequence("arrow", "protected")
enemy:set_attack_consequence("boomerang", "protected")
enemy:set_attack_consequence("thrown_item", "protected")