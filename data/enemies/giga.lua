local enemy = ...

-- Giga - undead Goron.

sol.main.load_file("enemies/generic_towards_hero")(enemy)
enemy:set_properties({
  sprite = "enemies/giga",
  life = 2,
  damage = 4
})
