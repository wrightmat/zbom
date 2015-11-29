local enemy = ...
local behavior = require("enemies/generic/waiting_hero")

-- Stal: small skull which can only be destroyed with the hammer.

local properties = {
  sprite = "enemies/stal",
  life = 1,
  damage = 4,
  normal_speed = 32,
  faster_speed = 40,
  hurt_style = "monster",
  asleep_animation = "immobilized",
  awaking_animation = "shaking",
  normal_animation = "walking",
  obstacle_behavior = "flying",
  waking_distance = 50,
  movement_create = function()
    local m = sol.movement.create("target")
    return m
  end
}
behavior:create(enemy, properties)

enemy:set_invincible()
enemy:set_attack_hammer(1)