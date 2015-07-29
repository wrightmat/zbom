local enemy = ...

-- Moblin.

sol.main.load_file("enemies/generic_soldier")(enemy)
enemy:set_properties({
  main_sprite = "enemies/moblin",
  life = 8,
  damage = 4,
  play_hero_seen_sound = true
})