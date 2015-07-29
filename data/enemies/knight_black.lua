local enemy = ...

-- Black knight soldier (Leader).

sol.main.load_file("enemies/generic_leader")(enemy)
enemy:set_properties({
  main_sprite = "enemies/knight_black",
  sword_sprite = "enemies/knight_black_sword",
  life = 8,
  damage = 4,
  play_hero_seen_sound = true
})