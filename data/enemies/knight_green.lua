local enemy = ...
local behavior = require("enemies/generic/soldier")

-- Green knight soldier.

local properties = {
  main_sprite = "enemies/knight_green",
  sword_sprite = "enemies/knight_green_sword",
  life = 2,
  damage = 2,
  normal_speed = 32,
  faster_speed = 40,
  play_hero_seen_sound = true
}

behavior:create(enemy, properties)