local enemy = ...
local map = enemy:get_map()
local vulnerable = false
local position_last = {}
local enemies_region = 0
local timers = {}
-- Possible positions where he appears.
local positions = {
  {x = 1576, y = 128, direction4 = 3},
  {x = 1448, y = 224, direction4 = 3},
  {x = 1352, y = 160, direction4 = 3},
  {x = 1608, y = 208, direction4 = 3},
  {x = 1584, y = 64, direction4 = 3}
}
if map:get_id() == "170" then
  -- Positions are different if this is the boss run.
  local positions = {
    {x = 440, y = 148, direction4 = 3},
    {x = 321, y = 244, direction4 = 3},
    {x = 216, y = 180, direction4 = 3},
    {x = 472, y = 228, direction4 = 3},
    {x = 448, y = 84, direction4 = 3}
  }
end

-- Vire Sorceror (Boss of Mausoleum): creates Vires and Fire Keese.

function enemy:on_created()
  self:set_life(12); self:set_damage(4)
  local sprite = self:create_sprite("enemies/vire_sorceror")
  self:set_size(32, 32); self:set_origin(16, 19)
  self:set_hurt_style("boss")
  self:set_attack_arrow("protected")
  self:set_attack_hookshot("protected")
  self:set_attack_consequence("boomerang", "protected")
  self:set_pushed_back_when_hurt(true)
  self:set_push_hero_on_sword(false)
  sprite:set_animation("immobilized")
end

function enemy:on_restarted()
  vulnerable = false
  for _, t in ipairs(timers) do t:stop() end
  local sprite = self:get_sprite()

  if math.random(4) == 1 then
    sprite:fade_out()
    timers[#timers + 1] = sol.timer.start(self:get_map(), 700, function() self:hide() end)
  end
  ex, ey, el = self:get_position()
  if ex == -100 and ey == -100 then
    self:unhide()
  end
  timers[#timers + 1] = sol.timer.start(self:get_map(), 1000, function()
    for entity in map:get_entities_in_rectangle(1272, 16, 408, 288) do
      if entity:get_type() == "enemy" then enemies_region = enemies_region + 1 end
    end
    if enemies_region < 2 then
      sol.timer.start(map, 5000, function()
        self:create_enemy({ x = ex + 20, y = ey + 20, name = "vire", breed = "vire", treasure_name = "amber" })
      end)
    end
  end)
end

function enemy:hide()
  position_last = self:get_position()
  vulnerable = false
  self:set_position(-100, -100)
  sol.timer.start(self:get_map(), math.random(5)*500, function() self:unhide() end)
end

function enemy:unhide()
  local position = (positions[math.random(#positions)])
  if position == position_last then  -- Reselect position if it's the same as last time.
    local position = (positions[math.random(#positions)])
  end
  self:set_position(position.x, position.y)
  local sprite = self:get_sprite()
  sprite:set_direction(position.direction4)
  sprite:fade_in()
  vulnerable = true
end

function enemy:on_hurt()
  sol.timer.start(map, 400, function() self:hide() end)
end