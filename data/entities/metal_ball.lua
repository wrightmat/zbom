local entity = ...
sol.main.load_file("entities/generic_portable")(entity)

-- This function is called after the on_created function of the generic_portable entity.
function entity:on_custom_created()
  self.sound = "throw" -- Change the default bouncing sound.
  self.can_push_buttons = true
  self.moved_on_platform = false
  self.hurt_damage = 2
end