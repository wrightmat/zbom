local enemy = ...

-- Giga - undead Goron.

sol.main.load_file("enemies/generic_towards_hero")(enemy)
enemy:set_properties({
  sprite = "enemies/giga",
  life = 6,
  damage = 4,
  normal_speed = 24,
  faster_speed = 32,
  pushed_when_hurt = false
})
