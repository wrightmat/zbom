local behavior = {}

-- Behavior of an enemy that wanders and shoots rocks.

function behavior:create(enemy, properties)
  local going_hero = false
  local can_shoot = false
  local main_sprite = nil
  
  -- Set default values.
  if properties.life == nil then
    properties.life = 2
  end
  if properties.damage == nil then
    properties.damage = 3
  end
  if properties.normal_speed == nil then
    properties.normal_speed = 32
  end
  if properties.faster_speed == nil then
    properties.faster_speed = 64
  end
  if properties.hurt_style == nil then
    properties.hurt_style = "normal"
  end
  if properties.projectile == nil then
    properties.projectile = "projectiles/rock_small"
  end
  
  function enemy:on_created()
    enemy:set_life(properties.life)
    enemy:set_damage(properties.damage)
    enemy:set_hurt_style(properties.hurt_style)
    main_sprite = enemy:create_sprite(properties.main_sprite)
    enemy:set_pushed_back_when_hurt(true)
    enemy:set_push_hero_on_sword(false)
    enemy:set_size(16, 16)
    enemy:set_origin(8, 13)
  end
  
  function enemy:go_hero()
    enemy:get_sprite():set_animation("walking")
    local movement = sol.movement.create("target")
    movement:set_speed(properties.normal_speed)
    movement:start(enemy)
  end
  
  function enemy:shoot()
    local hero = enemy:get_map():get_hero()
    if not enemy:is_in_same_region(hero) then
      return true  -- Repeat the timer.
    end
    local x, y, layer = enemy:get_position()
    local direction = enemy:get_sprite():get_direction()
    -- Where to create the projectile.
    local dxy = {
      {  8,  -4 },
      {  0, -13 },
      { -8,  -4 },
      {  0,   0 },
    }
    enemy:get_sprite():set_animation("shooting")
    enemy:stop_movement()
    sol.timer.start(enemy, 300, function()
      sol.audio.play_sound("stone")
      local stone = enemy:create_enemy({
        breed = properties.projectile,
        x = dxy[direction + 1][1],
        y = dxy[direction + 1][2],
      })
      stone:go(direction)
      sol.timer.start(enemy, 50 * math.random(20), function() enemy:go_hero() end)
    end)
  end
  
  function enemy:on_restarted()
    self:go_hero(); can_shoot = true
    sol.timer.start(enemy, 100, function()
      local hero = enemy:get_map():get_hero()
      local hero_x, hero_y = hero:get_position()
      local x, y = enemy:get_center_position()
      if can_shoot then
        local aligned = (math.abs(hero_x - x) < 16 or math.abs(hero_y - y) < 16) 
        if aligned and enemy:get_distance(hero) < 200 then
          self:shoot(); can_shoot = false
          sol.timer.start(enemy, 150 * math.random(20), function() can_shoot = true end)
       end
      end
      return true  -- Repeat the timer.
    end)
  end
  
  function enemy:on_movement_changed(movement)
    local direction4 = movement:get_direction4()
    self:get_sprite():set_direction(direction4)
  end
end

return behavior