local enemy = ...
local rock = false
local rock_timer

-- Deadrock: a basic enemy.

function enemy:on_created()
  self:set_life(6); self:set_damage(2)
  self:create_sprite("enemies/deadrock")
  self:set_size(16, 16); self:set_origin(8, 13)
  self:set_attack_consequence("explosion", 3)
  self:set_attack_consequence("sword", "custom")
  self:go_random()
end

function enemy:go_random()
  local sprite = self:get_sprite()
  if sprite:get_animation_set() == "enemies/deadrock" then sprite:set_animation("walking") end
  local m = sol.movement.create("path_finding")
  m:set_speed(40); m:start(self)
end

function enemy:on_custom_attack_received(attack, sprite)
  if not rock then
    rock = true
    if self:get_movement() then self:get_movement():stop() end
    if self:get_sprite():get_animation() == "immobilized" then
      self:get_sprite():set_animation("immobilized_hurt")
    else
      self:get_sprite():set_animation("immobilized")
    end
    rock_timer = sol.timer.start(self, 8000, function()
      self:get_sprite():set_animation("shaking")
      sol.timer.start(self, 3000, function()
        rock = false; self:go_random()
      end)
    end)
  else
    if attack == "sword" then
      sol.audio.play_sound("sword_tapping")
    end
  end
end

function enemy:on_hurt()
  rock = false
  self:go_random()
end

function enemy:on_movement_changed(movement)
  local direction4 = movement:get_direction4()
  self:get_sprite():set_direction(direction4)
end

function enemy:on_update()
  local sprite = self:get_sprite()
  if rock then
    if sprite:get_animation_set() == "enemies/deadrock" and sprite:get_animation() ~= "shaking" then
      sprite:set_animation("immobilized")
    end
  elseif not rock and not self:get_movement() then self:go_random() end
end