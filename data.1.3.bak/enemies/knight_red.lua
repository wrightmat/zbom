local enemy = ...

-- Red knight soldier.

sol.main.load_file("enemies/generic_soldier")(enemy)
enemy:set_properties({
  main_sprite = "enemies/knight_red",
  sword_sprite = "enemies/knight_red_sword",
  life = 4,
  damage = 2,
  play_hero_seen_sound = true
})