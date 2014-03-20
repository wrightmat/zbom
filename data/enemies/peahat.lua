local enemy = ...

-- Peahat: a flying enemy that follows the hero in the air (and lands periodically)

sol.main.load_file("enemies/generic_waiting_for_hero")(enemy)
enemy:set_properties({
  sprite = "enemies/peahat",
  life = 2,
  damage = 3,
  normal_speed = 32,
  faster_speed = 48,
  pushed_when_hurt = true,
  asleep_animation = "asleep",
  awaking_animation = "awaking",
  normal_animation = "walking",
  obstacle_behavior = "flying",
  awakening_sound  = "peahat_awake"
})
