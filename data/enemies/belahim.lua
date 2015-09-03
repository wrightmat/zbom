local enemy = ...
local initial_life = 20
local finished = false
local fireball_proba = 33  -- Percent.
local vulnerable = false
local timers = {}

-- Belahim (Dark Tribe leader, final boss of game)
-- THIS IS A PLACEHOLDER BASED ON CAROCK

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
  vulnerable = false
  for _, t in ipairs(timers) do t:stop() end
  local sprite = self:get_sprite()

  if not finished then
    sprite:fade_out()
    timers[#timers + 1] = sol.timer.start(self, 700, function() self:hide() end)
  else
    sprite:set_animation("hurt")
    timers[#timers + 1] = sol.timer.start(self, 500, function() self:end_dialog() end)
  end
end

function enemy:hide()
  vulnerable = false
  self:set_position(-100, -100)
  timers[#timers + 1] = sol.timer.start(self, 500, function() self:unhide() end)
end

function enemy:unhide()
  local position = (positions[math.random(#positions)])
  self:set_position(position.x, position.y)
  local sprite = self:get_sprite()
  sprite:set_direction(position.direction4)
  sprite:fade_in()
  timers[#timers + 1] = sol.timer.start(self, 1000, function() self:fire_step_1() end)
end

function enemy:fire_step_1()
  local sprite = self:get_sprite()
  sprite:set_animation("arms_up")
  timers[#timers + 1] = sol.timer.start(self, 1000, function() self:fire_step_2() end)
end

function enemy:fire_step_2()
  local sprite = self:get_sprite()
  if math.random(100) <= fireball_proba then
    sprite:set_animation("arms_out")
  else

  end
  sol.audio.play_sound("boss_charge")
  timers[#timers + 1] = sol.timer.start(self, 1500, function() self:fire_step_3() end)
end

function enemy:fire_step_3()
  local sprite = self:get_sprite()
  local sound, breed
  if sprite:get_animation() == "arms_out" then
    sound = "boss_fireball"
    breed = "fireball_triple"
  end
  sprite:set_animation("stopped")
  if sound ~= nil then sol.audio.play_sound(sound) end

  vulnerable = true
  timers[#timers + 1] = sol.timer.start(self, 700, function() self:restart() end)

  function throw_fire()
    nb_sons_created = nb_sons_created + 1
    self:create_enemy({x = 0, y = 21, breed = "fireball_triple", name = "carock_fireball_" .. nb_sons_created})
  end

  throw_fire()
  if self:get_life() <= initial_life / 2 then
    timers[#timers + 1] = sol.timer.start(self, 200, function()
      if self:throw_fire() ~= nil then self:throw_fire() end
    end)
    timers[#timers + 1] = sol.timer.start(self, 400, function()
      if self:throw_fire() ~= nil then self:throw_fire() end
    end)
  end
end

function enemy:receive_bounced_fireball(fireball)
  if fireball:get_name():find("^carock_fireball")
      and vulnerable then
    -- Receive a fireball shot back by the hero: get hurt.
    for _, t in ipairs(timers) do t:stop() end
    fireball:remove()
    self:hurt(1)
  end
end

function enemy:on_hurt(attack)
  local life = self:get_life()
  if life <= 0 then
    self:get_map():remove_entities("carock_fireball")
    self:set_life(1)
    finished = true
  elseif life <= initial_life / 3 then
    fireball_proba = 50
  end
end