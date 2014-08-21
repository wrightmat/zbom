local enemy = ...

-- Peahat: a flying enemy that follows the hero in the air (and lands periodically)

sol.main.load_file("enemies/generic_towards_hero")(enemy)
enemy:set_properties({
  sprite = "enemies/peahat",
  life = 4,
  damage = 4,
  normal_speed = 40,
  faster_speed = 48,
  pushed_when_hurt = true,
  obstacle_behavior = "flying",
  --asleep_animation = "asleep",
  --awaking_animation = "awaking",
  --normal_animation = "walking",
  --awakening_sound  = "peahat_awake"
   movement_create = function()
     local m = sol.movement.create("random_path")
     return m
   end
})
