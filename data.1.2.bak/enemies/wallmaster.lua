local enemy = ...
local map = enemy:get_map()
local hero = map:get_hero()

-- Wallmaster

function enemy:on_created()
  self:set_visible(false)
  self:set_can_attack(false)
  self:set_life(3)
  self:set_damage(2)
  self:create_sprite("enemies/wallmaster")
  self:set_size(32, 32)
  self:set_origin(16, 13)
  self:set_pushed_back_when_hurt(false)
  sol.timer.start(enemy, math.random(10)*500, function()
    self:appear()
  end)
end

function enemy:retreat()
  shadow = nil
  local ex, ey, el = self:get_position()
  local sprite = self:get_sprite()
  sprite:set_animation("shaking")

  local m = sol.movement.create("target")
  m:set_speed(80)
  m:set_target(ex, 0)
  m:set_smooth(false)
  m:set_ignore_obstacles(true)
  m:start(self)

  function m:on_finished()
    enemy:set_visible(false)
  end
  sol.timer.start(map, math.random(10)*5000, function()
    shadow = nil
    enemy:restart()
  end)
end

function enemy:grab()
  shadow:remove()
  local sprite = self:get_sprite()
  sprite:set_animation("immobilized")
  if self:overlaps(hero) then
    hero:freeze()
  end

  sol.timer.start(enemy, 500, function()
    if self:overlaps(hero) then
      hero:set_visible(false)
      hero:teleport(map:get_id())
      hero:set_visible(true)
      hero:unfreeze()
    end
    self:retreat()
  end)
end

function enemy:drop()
  local sprite = self:get_sprite()
  sprite:set_animation("hurt")
  local ex, ey, el = self:get_position()

  local m = sol.movement.create("target")
  m:set_speed(128)
  m:set_target(ex, ey+100)
  m:set_smooth(false)
  m:set_ignore_obstacles(true)
  m:start(self)

  function m:on_finished()
    enemy:grab()
  end
end

function enemy:appear()
  if enemy:is_in_same_region(hero) then
    -- shadow appears first
    local hx, hy, hl = hero:get_position()
    if not shadow then  -- don't create more than one shadow
      shadow = enemy:create_enemy({ name = "shadow", x = hx, y = hy, layer = 1, breed = "wallmaster_shadow" })
    end

    sol.timer.start(enemy, 2000, function()
      shadow:stop_movement()
      local sx, sy, sl = shadow:get_position()
      -- hand appears next
      self:set_position(sx, sy-100, 2)
      self:set_visible(true)
      local sprite = self:get_sprite()
      sprite:set_animation("walking")
      sol.timer.start(enemy, 500, function() self:drop() end)
    end)
  end
end

function enemy:on_restarted()
  self:appear()
end
function enemy:on_hurt()
  self:retreat()
end
