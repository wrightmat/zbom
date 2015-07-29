local enemy = ...

-- Blue knight soldier.

sol.main.load_file("enemies/generic_soldier")(enemy)
enemy:set_properties({
  main_sprite = "enemies/knight_blue",
  sword_sprite = "enemies/knight_blue_sword",
  life = 6,
  damage = 4,
  play_hero_seen_sound = true
})