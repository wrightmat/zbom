local enemy = ...
local initial_life = 22
local second_life = 12
local second_stage = false
local fireball_proba = 33  -- Percent.
local shadow = false
local timers = {}

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
  self:set_pushed_back_when_hurt(false)
  self:set_push_hero_on_sword(true)
  sprite:set_animation("stopped")
end

function enemy:on_restarted()
  if self:get_game():get_map():get_id() ~= "0" then -- Don't want Belahim to act during the intro.
    shadow = false
    for _, t in ipairs(timers) do t:stop() end
    local rand = math.random(3)
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
  self:get_sprite():set_animation("shrink")
  sol.timer.start(self, 1000, function() self:get_sprite():set_animation("shadow") end)
  shadow = true
  timers[#timers + 1] = sol.timer.start(self:get_map(), math.random(10)*500, function() enemy:go_normal() end)
end

function enemy:go_normal()
  shadow = false
  self:get_sprite():set_animation("walking")
end

function enemy:go_beam()
  local sprite = self:get_sprite()
  local sound, breed
  sprite:set_animation("stopped")
  if sound ~= nil then sol.audio.play_sound(sound) end

  timers[#timers + 1] = sol.timer.start(self, 700, function() self:restart() end)

  function throw_beam()
    nb_sons_created = nb_sons_created + 1
    self:create_enemy({x = 0, y = 21, breed = "belahim_beam", name = "belahim_beam_" .. nb_sons_created})
  end

  throw_beam()
  if self:get_life() <= initial_life / 2 then
    timers[#timers + 1] = sol.timer.start(self, 200, function()
      throw_beam()
    end)
    timers[#timers + 1] = sol.timer.start(self, 400, function()
      throw_beam()
    end)
  end
end

function enemy:go_hero()
  local m = sol.movement.create("target")
  m:set_speed(32)
  m:start(self)
  sol.timer.start(enemy, math.random(10)*500, function() enemy:restart() end)
end

function enemy:on_hurt(attack)
  local life = self:get_life()
  if life <= 0 then
    self:get_map():remove_entities("belahim_beam")
    self:set_life(second_life)
    second_stage = true
  elseif life <= initial_life / 3 then
    fireball_proba = 50
  end
end

function enemy:on_update()
  if shadow then
    self:set_attack_arrow("custom")
  else
    self:set_attack_arrow("protected")
  end
end

function enemy:on_custom_attack_received(attack, sprite)
  if sprite == "arrow_light" and shadow then
    self:hurt(4)
  end
end