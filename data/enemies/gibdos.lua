local enemy = ...

-- Gibdos (mummy)

sol.main.load_file("enemies/generic_towards_hero")(enemy)
enemy:set_properties({
  sprite = "enemies/gibdos",
  life = 6,
  damage = 2,
  normal_speed = 24,
  faster_speed = 24,
  pushed_when_hurt = false
})
