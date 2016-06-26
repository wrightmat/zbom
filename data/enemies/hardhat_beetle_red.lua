local enemy = ...
local behavior = require("enemies/generic/toward_hero")

-- Red Hardhat Beetle.

local properties = {
  sprite = "enemies/hardhat_beetle_red",
  life = 5,
  damage = 4,
  normal_speed = 32,
  faster_speed = 48,
  push_hero_on_sword = true
}
behavior:create(enemy, properties)