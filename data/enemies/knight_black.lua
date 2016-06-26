local enemy = ...

-- Black knight soldier (Leader).

sol.main.load_file("enemies/generic/leader")(enemy)
enemy:set_properties({
  main_sprite = "enemies/knight_black",
  life = 8,
  damage = 8,
  play_hero_seen_sound = true
})