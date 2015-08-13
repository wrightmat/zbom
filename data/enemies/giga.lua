local enemy = ...
local behavior = require("enemies/generic/toward_hero")

-- Giga: undead Goron.

local properties = {
  sprite = "enemies/giga",
  life = 6,
  damage = 4,
  normal_speed = 24,
  faster_speed = 32,
  pushed_when_hurt = false
}
behavior:create(enemy, properties)

enemy:set_attack_consequence("fire", "protected")
enemy:set_attack_consequence("arrow", "protected")
enemy:set_attack_consequence("explosion", "protected")
enemy:set_attack_consequence("boomerang", "protected")
enemy:set_attack_consequence("thrown_item", "protected")