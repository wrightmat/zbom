local enemy = ...

-- Rope (snake): fast moving basic enemy.

sol.main.load_file("enemies/generic_towards_hero")(enemy)
enemy:set_properties({
  sprite = "enemies/rope",
  life = 1,
  damage = 2,
  normal_speed = 48,
  faster_speed = 64,
  hurt_style = "monster",
  push_hero_on_sword = false,
  movement_create = function()
    local m = sol.movement.create("path_finding")
    return m
  end
})
