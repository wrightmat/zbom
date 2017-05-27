local behavior = {}

-- Behavior of an enemy that shoots magical beams at the hero.

function behavior:create(enemy, properties)
  local vulnerable = false
  local timers = {}
  local ex, ey, el
  local main_sprite = nil
  
  -- Set default values.
  if properties.life == nil then
    properties.life = 4
  end
  if properties.damage == nil then
    properties.damage = 4
  end
  if properties.play_hero_seen_sound == nil then
    properties.play_hero_seen_sound = false
  end
  if properties.normal_speed == nil then
    properties.normal_speed = 48
  end
  if properties.faster_speed == nil then
    properties.faster_speed = 64
  end
  if properties.hurt_style == nil then
    properties.hurt_style = "normal"
  end
  if properties.type == nil then
    properties.type = "magic"
  end
  
  function enemy:on_created()
    enemy:set_life(properties.life)
    enemy:set_damage(properties.damage)
    enemy:set_hurt_style(properties.hurt_style)
    main_sprite = enemy:create_sprite(properties.main_sprite)
    enemy:set_size(16, 24)
    enemy:set_origin(8, 17)
  end

  function enemy:on_restarted()
    vulnerable = false
    for _, t in ipairs(timers) do t:stop() end
    self:get_sprite():fade_out()
    timers[#timers + 1] = sol.timer.start(self, 700, function() self:hide() end)
  end

  function enemy:on_movement_changed(movement)
    local direction4 = movement:get_direction4()
    self:get_sprite():set_direction(direction4)
  end

  function enemy:hide()
    vulnerable = false
    self:get_sprite():set_animation("immobilized")
    ex, ey, el = self:get_position()
    self:set_position(-100, -100)
    sol.timer.start(self:get_map(), math.random(10)*100, function() self:unhide() end)
  end

  function enemy:unhide()
    vulnerable = true
    self:set_position(ex, ey)
    self:get_sprite():fade_in()
    self:get_sprite():set_animation("walking")
    local m = sol.movement.create("path_finding")
    m:set_speed(properties.normal_speed)
    m:start(self)
    timers[#timers + 1] = sol.timer.start(self, 1000, function() self:fire() end)
  end

  function enemy:fire()
    vulnerable = true
    self:get_sprite():set_animation("shaking")
    local beam = self:create_enemy({ breed = "projectiles/wizzrobe_beam", direction = self:get_sprite():get_direction(), name = properties.type })
    self:restart()
  end
end

return behavior