local enemy = ...
local behavior = require("enemies/generic/toward_hero")

-- Gibdos: Hylian mummy.

local properties = {
  sprite = "enemies/gibdos",
  life = 6,
  damage = 2,
  normal_speed = 24,
  faster_speed = 32,
  pushed_when_hurt = false
}
behavior:create(enemy, properties)

enemy:set_attack_arrow("protected")
enemy:set_attack_hookshot("protected")
enemy:set_attack_consequence("fire", "custom")
enemy:set_attack_consequence("boomerang", "protected")
enemy:set_attack_consequence("thrown_item", "protected")

enemy:on_custom_attack_received(attack, sprite)
  if attack == "fire" then enemy:get_sprite():set_animation("fire") end
  enemy:hurt(3)
  enemy:remove_life(3)
end