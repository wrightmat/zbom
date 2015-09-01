local enemy = ...
local behavior = require("enemies/generic/toward_hero")

-- Dodongo: Dinosaur enemy that is susceptible only to bombs.

local properties = {
  sprite = "enemies/dodongo",
  life = 2,
  damage = 2,
  normal_speed = 32,
  faster_speed = 32,
  pushed_when_hurt = false
}
behavior:create(enemy, properties)

enemy:set_attack_arrow("protected")
enemy:set_attack_consequence("sword", "protected")
enemy:set_attack_consequence("thrown_item", "protected")