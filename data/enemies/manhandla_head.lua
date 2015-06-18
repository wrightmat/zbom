local enemy = ...

-- Manhandla: boss with multiple heads to attack - this file defines the head segments.

function enemy:on_created()
  self:set_life(1)
  self:set_damage(1)
  self:create_sprite("enemies/manhandla_head")
  self:set_hurt_style("monster")
  self:set_size(24, 24)
  self:set_origin(12, 12)
  self:set_attack_consequence("arrow", "protected")
end

function enemy:on_update()
  local body = self:get_map():get_entity("boss_manhandla")
  local bx, by, bl = body:get_position()
  -- Keep the heads attached to the body!
  -- Each head color has a different position on the body.
  if self.color == "blue" then
    self:set_position(bx+21, by)
    if self:get_sprite():get_animation() == "walking" then self:get_sprite():set_direction(0) end
  elseif self.color == "purple" then
    self:set_position(bx, by-24)
    if self:get_sprite():get_animation() == "walking" then self:get_sprite():set_direction(1) end
  elseif self.color == "green" then
    self:set_position(bx-21, by)
    if self:get_sprite():get_animation() == "walking" then self:get_sprite():set_direction(2) end
  elseif self.color == "red" then
    self:set_position(bx, by+21)
    if self:get_sprite():get_animation() == "walking" then self:get_sprite():set_direction(3) end
  end
end
