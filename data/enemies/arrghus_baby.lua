local enemy = ...

-- Stone Arrghus: Miniboss who creates small rocks and has to be hit in the eye to be hurt
-- These are the small rocks - each direction turns a different color

sol.main.load_file("enemies/generic_towards_hero")(enemy)
enemy:set_properties({
  sprite = "enemies/arrghus_baby",
  life = 1,
  damage = 2,
  normal_speed = 24,
  faster_speed = 32,
  hurt_style = "monster",
  --set_attack_consequence("arrow", "protected"),
  movement_create = function()
    return sol.movement.create("random")
  end
})