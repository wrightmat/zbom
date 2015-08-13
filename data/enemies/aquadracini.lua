local enemy = ...
local behavior = require("enemies/generic/waiting_hero")

-- Aquadracini: Small flying dragon.

local properties = {
  sprite = "enemies/aquadracini",
  life = 2,
  damage = 2,
  normal_speed = 32,
  faster_speed = 40,
  asleep_animation = "immobilized",
  awaking_animation = "shaking",
  normal_animation = "walking",
  obstacle_behavior = "flying",
  waking_distance = 100
}
behavior:create(enemy, properties)