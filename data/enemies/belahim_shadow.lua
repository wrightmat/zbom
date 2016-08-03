local enemy = ...
local game = enemy:get_game()

function enemy:on_created()
  sprite = enemy:create_sprite("enemies/" .. enemy:get_breed())
  enemy:set_life(8)
  enemy:set_damage(16)
  self:set_invincible()
  self:set_attack_arrow("custom")
end

function enemy:on_restarted()
  local m = sol.movement.create("random")
  m:set_speed(40)
  self:get_sprite():set_animation("walking")
  m:start(self)
end

function enemy:on_custom_attack_received(attack, sprite)
  if attack == "arrow" and game:has_item("bow_light") then
    if belahim_second_stage then
      self:hurt(2)
    else
      self:hurt(4)
    end
  end
end

function enemy:on_dead()
  if game:get_map():get_entity("boss_belahim") then
    local belahim = game:get_map():get_entity("boss_belahim")
    if belahim_second_phase then
      belahim:set_visible(true)
      belahim:get_sprite():set_animation("hurt")
      belahim:hurt(2)
      sol.timer.start(game:get_map(), 500, function() belahim:restart() end)
    else
      belahim:set_visible(true)
      belahim:get_sprite():set_animation("hurt")
      belahim:hurt(4)
      sol.timer.start(game:get_map(), 500, function() belahim:restart() end)
    end
  end
end