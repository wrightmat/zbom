local enemy = ...
local visible = false
local timers = {}
local ex, ey, el
local body_sprite = nil

-- Pit Pincer: Emerges from its pit when the hero nears.

function enemy:on_created()
  self:set_life(5); self:set_damage(4)
  self:create_sprite("enemies/pincer")
  self:set_size(16, 16); self:set_origin(8, 13)
  self:get_sprite():set_animation("shaking")
  self:set_obstacle_behavior("flying") -- allows to traverse holes

  body_sprite = sol.sprite.create("enemies/pincer")
  body_sprite:set_animation("body")
end

function enemy:on_hurt()
  self:hide(false)
end

function enemy:on_movement_changed(movement)
  local direction8 = self:get_direction8_to(self:get_map():get_hero())
  self:get_sprite():set_direction(direction8)
end

function enemy:on_restarted()
  for _, t in ipairs(timers) do t:stop() end
  self:get_sprite():fade_out()
  if ex == nil or ey == nil then ex, ey, el = self:get_position() end
  timers[#timers + 1] = sol.timer.start(self, 700, function() self:go_back(ex, ey) end)
end

function enemy:hide(update_position)
  visible = false
  self:get_sprite():set_animation("shaking")
  if update_position then ex, ey, el = self:get_position() end
  timers[#timers + 1] = sol.timer.start(self, 500, function() self:get_sprite():set_animation("hiding") end)
end

function enemy:unhide()
  visible = true
  self:set_position(ex, ey)
  self:get_sprite():fade_in(10)
  self:get_sprite():set_animation("shaking")
  timers[#timers + 1] = sol.timer.start(self, 2000, function() self:go_toward() end)
end

function enemy:go_toward()
  visible = true
  ex, ey, el = self:get_position()
  self:get_sprite():set_animation("walking")
  local m = sol.movement.create("straight")
  m:set_speed(80)
  m:set_angle(self:get_angle(self:get_map():get_hero()))
  m:start(self)
  timers[#timers + 1] = sol.timer.start(self, 800, function() self:go_back(ex, ey) end)
end

function enemy:go_back(x, y)
  visible = true
  local m = sol.movement.create("target")
  m:set_speed(48)
  m:set_target(x, y)
  m:start(self, function() self:hide(true) end)
end

function enemy:on_pre_draw()
  if visible then
    local ex2, ey2, el2 = self:get_position()
    local nb_body = 5
    for i = 1, nb_body do
      local x = ex + (ex2 - ex) * i / nb_body
      local y = ey + (ey2 - ey) * i / nb_body
      self:get_map():draw_sprite(body_sprite, x, y)
    end
  end
end

function enemy:on_update()
  if self:get_distance(self:get_map():get_hero()) < 60 and not visible then
    self:unhide()
  end

  if not visible then
    self:set_invincible(true)
  else
    self:set_attack_arrow(1)
    self:set_attack_hookshot("immobilized")
    self:set_attack_consequence("sword", 1)
    self:set_attack_consequence("explosion", 1)
    self:set_attack_consequence("boomerang", "immobilized")
  end
end