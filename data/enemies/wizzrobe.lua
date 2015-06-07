local enemy = ...

-- Wizzrobe

local vulnerable = false
local timers = {}
local ex, ey, el

function enemy:on_created()
  self:set_life(3)
  self:set_damage(2)
  self:create_sprite("enemies/wizzrobe")
  self:set_optimization_distance(0)
  self:set_size(16, 24)
  self:set_origin(8, 17)

  local sprite = self:get_sprite()
  sprite:set_animation("immobilized")
end

function enemy:on_restarted()
print('restarted')
  vulnerable = false
  for _, t in ipairs(timers) do t:stop() end
  local sprite = self:get_sprite()

  sprite:fade_out()
  timers[#timers + 1] = sol.timer.start(self, 700, function() self:hide() end)
end

function enemy:hide()
print('hiding')
  vulnerable = false
  ex, ey, el = self:get_position()
  self:set_position(-100, -100)
  timers[#timers + 1] = sol.timer.start(self, 500, function() self:unhide() end)
end

function enemy:unhide()
print('unhiding')
  vulnerable = true
  self:set_position(ex, ey)
  local sprite = self:get_sprite()
  sprite:fade_in()
  timers[#timers + 1] = sol.timer.start(self, 1000, function() self:fire() end)
end

function enemy:fire()
print('firing')
  vulnerable = true
  beam = self:create_enemy({
    breed = "wizzrobe_beam",
    direction = self:get_sprite():get_direction()
  })
  self:restart()
end