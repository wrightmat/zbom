local enemy = ...
local phase = 0
local breed = ""
local son_breed = "keese"
local nb_sons_created = 0
local nb_sons_to_create = 0

-- Grim Creeper: Miniboss who controls flocks of Keese.

function enemy:on_created()
  self:set_life(6); self:set_damage(3)
  self:create_sprite("enemies/grim_creeper")
  self:set_size(16, 24); self:set_origin(8, 17)
  self:set_invincible(true)
  self:set_attack_consequence("explosion", 1)
  self:set_pushed_back_when_hurt(false)
  self:release_wave()
end

function enemy:change_phase()
  if phase < 4 then
    phase = phase + 1
  else
    phase = 0
  end
  self:release_wave()
end

function enemy:throw_keese(breed)
  -- Create the sons.
  nb_sons_created = nb_sons_created + 1
  local son_name = self:get_name() .. "_keese_" .. nb_sons_created
  if breed == "regular" or breed == nil then
    son_breed = "keese"
  else
    son_breed = "keese_" .. breed
  end
  self:create_enemy{
    name = son_name,
    breed = son_breed,
    x = 0,
    y = -40,
  }
  if breed == "fire" then sol.audio.play_sound("lamp") end
  if breed == "ice" then sol.audio.play_sound("ice_shatter") end
  if breed == "elec" then sol.audio.play_sound("spark") end
  if breed == "dark" then sol.audio.play_sound("poe_soul") end

  -- See what to do next.
  nb_sons_to_create = nb_sons_to_create - 1
  if nb_sons_to_create > 0 then
    -- Throw another son in 0.5 seconds.
    sol.timer.start(self, 500, function() self:throw_keese(breed) end)
  else
    -- Finish the son phase.
    local sprite = self:get_sprite()
    sprite:set_animation("walking")
    local delay = 3500 + (math.random(3) * 1000)
    sol.timer.start(self, delay, function() self:change_phase() end)
  end
end

function enemy:release_wave()
  if self:get_sprite() == "enemies/grim_creeper" then self:get_sprite():set_animation("shaking") end
  -- Throw more keese as life is taken away.
  if phase == 0 then
    nb_sons_to_create = 7 + (8-self:get_life())
    breed = "regular"
  elseif phase == 1 then
    nb_sons_to_create = 7 + (8-self:get_life())
    breed = "fire"
  elseif phase == 2 then
    nb_sons_to_create = 6 + (8-self:get_life())
    breed = "ice"
  elseif phase == 3 then
    nb_sons_to_create = 5 + (8-self:get_life())
    breed = "elec"
  elseif phase == 4 then
    nb_sons_to_create = 4 + (8-self:get_life())
    breed = "dark"
  end
  sol.timer.start(self, 1500, function() self:throw_keese(breed) end)
end

function enemy:on_enabled()
  self:release_wave()
end

function enemy:on_hurt()
  -- Wait one second to change phase so hurt animation isn't changed right away.
  sol.timer.start(self:get_map(), 1000, function() self:change_phase() end)
end

function enemy:on_restarted()
  self:throw_keese(breed)
end