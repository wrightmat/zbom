local enemy = ...

-- Stal: small skull which can only be destroyed with the hammer.

sol.main.load_file("enemies/generic/waiting_hero")(enemy)
enemy:set_properties({
  sprite = "enemies/stal",
  life = 1,
  damage = 2,
  normal_speed = 32,
  faster_speed = 40,
  hurt_style = "monster",
  asleep_animation = "immobilized",
  awaking_animation = "shaking",
  normal_animation = "walking",
  obstacle_behavior = "flying",
  movement_create = function()
    local m = sol.movement.create("target")
    return m
  end
})

enemy:set_invincible()
--enemy:set_hammer_reaction(1)