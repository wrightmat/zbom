local enemy = ...
local behavior = require("enemies/generic/leader")

-- Black knight soldier.

local properties = {
  main_sprite = "enemies/knight_black",
  life = 10,
  damage = 8,
  normal_speed = 48,
  faster_speed = 64,
  play_hero_seen_sound = true,
}

behavior:create(enemy, properties)