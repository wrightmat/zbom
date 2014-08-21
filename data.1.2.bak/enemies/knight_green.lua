local enemy = ...

-- Green knight soldier.

sol.main.load_file("enemies/generic_soldier")(enemy)
enemy:set_properties({
  main_sprite = "enemies/knight_green",
  sword_sprite = "enemies/knight_green_sword",
  life = 2,
  damage = 2,
  play_hero_seen_sound = true
})