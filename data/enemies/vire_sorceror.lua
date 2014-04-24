local enemy = ...

-- Vire Sorceror (Boss of Mausoleum): creates Vires and Fire Keese

-- Possible positions where he appears.
local positions = {
  {x = 1576, y = 128, direction4 = 3},
  {x = 1448, y = 224, direction4 = 3},
  {x = 1352, y = 160, direction4 = 1}
}

local vulnerable = false
local timers = {}

function enemy:on_created()
  self:set_life(8)
  self:set_damage(2)
  self:create_sprite("enemies/vire_sorceror")
  self:set_optimization_distance(0)
  self:set_size(32, 32)
  self:set_origin(16, 19)
  self:set_attack_consequence("arrow", "protected")
  self:set_attack_consequence("hookshot", "protected")
  self:set_attack_consequence("boomerang", "protected")
  self:set_pushed_back_when_hurt(true)
  self:set_push_hero_on_sword(false)

  local sprite = self:get_sprite()
  sprite:set_animation("stopped")
end

function enemy:on_restarted()
  vulnerable = false
  for _, t in ipairs(timers) do t:stop() end
  local sprite = self:get_sprite()

  if not finished then
    sprite:fade_out()
    timers[#timers + 1] = sol.timer.start(self, 700, function() self:hide() end)
  end
end

function enemy:hide()
  vulnerable = false
  self:set_position(-100, -100)
  -- Always keep at lease one Vire alive
  if not map:get_entities_count("vire") then
    self:create_enemy({ breed = "vire", treasure_name = "amber" })
  end
  timers[#timers + 1] = sol.timer.start(self, 500, function() self:unhide() end)
end

function enemy:create_keese()
  self:create_enemy({ breed = "keese_fire", treasure_name = "heart" })
  -- Always keep at lease one Vire alive
  if not map:get_entities_count("vire") then
    self:create_enemy({ breed = "vire", treasure_name = "amber" })
  end
end

function enemy:unhide()
  local position = (positions[math.random(#positions)])
  self:set_position(position.x, position.y)
  local sprite = self:get_sprite()
  sprite:set_direction(position.direction4)
  sprite:fade_in()
  timers[#timers + 1] = sol.timer.start(self, 1000, function() self:create_keese() end)
end
