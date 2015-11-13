local enemy = ...
local main_sprite = nil
local claw_sprite = nil
local nb_sons_created = 0
local initial_life = 7

-- Helmaroc Rex: giant bird, boss of Wind Tower.

function enemy:on_created()
  self:set_life(initial_life); self:set_damage(2)
  main_sprite = self:create_sprite("enemies/helmaroc_rex")
  claw_sprite = self:create_sprite("enemies/helmaroc_rex")
  claw_sprite:set_animation("claw")
  self:set_size(16, 16); self:set_origin(8, 13)
  self:set_obstacle_behavior("flying")
  self:set_layer_independent_collisions(true)
  self:set_invincible()
  self:set_attack_arrow("protected")
  self:set_attack_hookshot("protected")
  self:set_attack_consequence("sword", "protected")
  self:set_attack_consequence("boomerang", "protected")
  self:set_attack_arrow_sprite(claw_sprite, 1)
  self:set_pushed_back_when_hurt(false)
  self:set_push_hero_on_sword(true)
end

function enemy:on_restarted()
  claw_sprite:set_animation("claw")
  local m = sol.movement.create("random")
  m:set_speed(32)
  m:start(self)
  sol.timer.start(self, math.random(20)*1000, function() self:prepare_wind() end)
end

function enemy:prepare_wind()
  local prefix = self:get_name() .. "_son_"
  local life_lost = initial_life - self:get_life()
  local nb_to_create = 3 + life_lost

  function repeat_throw_wind()
    nb_sons_created = nb_sons_created + 1
    local son_name = prefix .. nb_sons_created
    self:create_enemy{ name = son_name, breed = "whirlwind", x = 0, y = -16, layer = 0, treasure_name = "arrow" }
    nb_to_create = nb_to_create - 1
    if nb_to_create > 0 then
      sol.timer.start(self, 200, repeat_throw_wind)
    end
  end
  repeat_throw_wind()

  sol.timer.start(self, math.random(4000, 6000), function()
    self:prepare_wind()
  end)
end

function enemy:on_hurt(attack, life_lost)
  if self:get_life() <= 0 then
    self:get_map():remove_entities(self:get_name() .. "_son_")
  end
end