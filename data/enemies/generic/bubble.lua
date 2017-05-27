local behavior = {}

-- Behavior of an an invincible enemy that moves 
-- in diagonal directions and bounces against walls.

function behavior:create(enemy, properties)
  local last_direction8 = 0
  
  -- Set default properties.
  if properties.life == nil then
    properties.life = 1
  end
  if properties.damage == nil then
    properties.damage = 2
  end
  if properties.normal_speed == nil then
    properties.normal_speed = 32
  end
  if properties.faster_speed == nil then
    properties.faster_speed = 48
  end
  if properties.hurt_style == nil then
    properties.hurt_style = "normal"
  end
  if properties.pushed_when_hurt == nil then
    properties.pushed_when_hurt = true
  end
  if properties.push_hero_on_sword == nil then
    properties.push_hero_on_sword = false
  end
  if properties.ignore_obstacles == nil then
    properties.ignore_obstacles = false
  end
  if properties.detection_distance == nil then
    properties.detection_distance = 160
  end
  if properties.obstacle_behavior == nil then
    properties.obstacle_behavior = "normal"
  end
  if properties.movement_create == nil then
    properties.movement_create = function()
      local m = sol.movement.create("random_path")
      return m
    end
  end
  
  function enemy:on_created()
    self:set_life(properties.life)
    self:set_damage(properties.damage)
    self:create_sprite(properties.sprite)
    self:set_hurt_style(properties.hurt_style)
    self:set_pushed_back_when_hurt(properties.pushed_when_hurt)
    self:set_push_hero_on_sword(properties.push_hero_on_sword)
    self:set_obstacle_behavior(properties.obstacle_behavior)
    self:set_can_hurt_hero_running(true)
    self:set_invincible()
    self:set_size(8, 8)
    self:set_origin(4, 6)
  end

  function enemy:on_restarted()
    local direction8 = math.random(4) * 2 - 1
    self:go(direction8)
  end

  function enemy:on_obstacle_reached()
    local dxy = {
      { x =  1, y =  0},
      { x =  1, y = -1},
      { x =  0, y = -1},
      { x = -1, y = -1},
      { x = -1, y =  0},
      { x = -1, y =  1},
      { x =  0, y =  1},
      { x =  1, y =  1}
    }

    -- The current direction is last_direction8:
    -- try the three other diagonal directions.
    local try1 = (last_direction8 + 2) % 8
    local try2 = (last_direction8 + 6) % 8
    local try3 = (last_direction8 + 4) % 8

    if not self:test_obstacles(dxy[try1 + 1].x, dxy[try1 + 1].y) then
      self:go(try1)
    elseif not self:test_obstacles(dxy[try2 + 1].x, dxy[try2 + 1].y) then
      self:go(try2)
    else
      self:go(try3)
    end
  end

  function enemy:go(direction8)
    local m = sol.movement.create("straight")
    m:set_speed(80)
    m:set_smooth(false)
    m:set_angle(direction8 * math.pi / 4)
    m:start(self)
    last_direction8 = direction8
  end
  
  function enemy:on_movement_changed(movement)
    local direction4 = movement:get_direction4()
    local sprite = self:get_sprite()
    sprite:set_direction(direction4)
  end
end

return behavior