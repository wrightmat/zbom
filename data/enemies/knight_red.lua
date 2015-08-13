local enemy = ...
local behavior = require("enemies/generic/soldier")

-- Red knight soldier.

local properties = {
  main_sprite = "enemies/knight_red",
  sword_sprite = "enemies/knight_red_sword",
  life = 4,
  damage = 2,
  normal_speed = 40,
  faster_speed = 48,
  play_hero_seen_sound = true
}

behavior:create(enemy, properties)