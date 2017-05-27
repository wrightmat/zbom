local enemy = ...
local behavior = require("enemies/generic/chuchu")

-- Red ChuChu: a basic overworld enemy that follows the hero.
-- The red variety can disappear into the ground.

local properties = {
  sprite = "enemies/chuchu_red",
  life = 2,
  damage = 4,
  normal_speed = 32,
  faster_speed = 40
}
behavior:create(enemy, properties)
enemy:set_attack_consequence("fire", "protected")