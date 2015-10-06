local enemy = ...
local initial_life = 40
local second_life = 12
local second_stage = false
local fireball_proba = 33  -- Percent.
local shadow = false
local nb_sons_created = 0

-- Belahim (Dark Tribe leader, final boss of game)
-- Behavior: Invincible as normal form, must avoid both boss and beams he throws
--       Vulnerable to only light arrows as shadow form, which he shrinks to periodically
--       Once hit with light arrows 10 times, he shows his true form and is vulnerable to sword
--       (Light sword does three times as much damage, must hit him 12 times with Forged Sword)

function enemy:on_created()
  self:set_life(initial_life); self:set_damage(8)
  local sprite = self:create_sprite("enemies/belahim")
  self:set_size(64, 64); self:set_origin(32, 57)
  self:set_optimization_distance(0)
  self:set_invincible()
  self:set_attack_arrow("custom")
  self:set_attack_consequence("sword", 1)
  self:set_pushed_back_when_hurt(false)
  self:set_push_hero_on_sword(true)
  sprite:set_animation("stopped")
end

function enemy:on_restarted()
  if self:get_game():get_map():get_id() == "218" then -- Don't want Belahim to act during the intro.
    shadow = false
    local rand = math.random(4)
print("restarted. action "..rand)
    if rand == 1 then
      self:go_shadow()
    elseif rand == 2 then
      self:go_beam()
    else
      self:go_hero()
    end
  end
end

function enemy:go_shadow()
print("go shadow")
  self:get_sprite():set_animation("shrink")
  sol.timer.start(self:get_map(), 1000, function() self:get_sprite():set_animation("shadow") end)
  shadow = true
  sol.timer.start(self:get_map(), math.random(10)*500, function() enemy:go_normal() end)
end

function enemy:go_normal()
print("go normal")
  shadow = false
  self:get_sprite():set_animation("walking")
  self:restart()
end

function enemy:go_beam()
print("throw beam")
  local sprite = self:get_sprite()
  sprite:set_animation("stopped")
  sol.timer.start(self:get_map(), 700, function() self:restart() end)

  function throw_beam()
    nb_sons_created = nb_sons_created + 1
    self:create_enemy({x = 0, y = 21, breed = "belahim_beam", name = "belahim_beam_" .. nb_sons_created})
  end

  throw_beam()
  if self:get_life() <= initial_life / 2 then
    sol.timer.start(self, 200, function()
      throw_beam()
    end)
    sol.timer.start(self, 400, function()
      throw_beam()
    end)
  end
end

function enemy:go_hero()
  local m = sol.movement.create("target")
  m:set_target(self:get_map():get_hero())
  m:set_speed(32)
  m:start(self)
print("go hero")
  sol.timer.start(self:get_map(), math.random(10)*500, function() enemy:restart() end)
end

function enemy:on_update()
  if shadow then
    self:set_attack_arrow("custom")
    self:get_sprite():set_animation("shadow")
  else
    self:set_attack_arrow("protected")
  end
end

function enemy:on_hurt(attack)
  local life = self:get_life()
  if life <= 0 and not second_stage then
    self:get_map():remove_entities("belahim_beam")
    self:set_life(second_life)
    second_stage = true
  elseif life <= initial_life / 3 then
    fireball_proba = 50
  end
end

function enemy:on_hurt_by_sword(hero, enemy_sprite)
  if self:get_game():get_ability("sword") == 3 then
    self:hurt(3)
    enemy:remove_life(3)
print("hurt by sword - 3 life points removed. life= "..self:get_life())
  else
print("hurt by sword - 1 life point removed. life= "..self:get_life())
    self:hurt(1)
    enemy:remove_life(1)
  end
end

function enemy:on_custom_attack_received(attack, sprite)
  if attack == "arrow" and self:get_game():has_item("bow_light") then
    if shadow then
print("hurt by light arrow - 6 life points removed. life= "..self:get_life())
      self:hurt(6)
      enemy:remove_life(6)
      vulnerable = false
    end
  end
end