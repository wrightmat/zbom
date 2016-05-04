local enemy = ...
local can_shoot = true
local map = enemy:get_map()
local hero = map:get_hero()

-- Swamp Flower, Big: a swamp flower that can shoot fire.

function enemy:on_created()
  self:set_life(1); self:set_damage(8)
  self:create_sprite("enemies/swamp_flower_big")
  self:set_size(32, 32); self:set_origin(16, 27)
  self:set_pushed_back_when_hurt(false)
  self:set_invincible(true)
  self:set_obstacle_behavior("swimming")
end

local function shoot()
  if not enemy:is_in_same_region(hero) then
    return true  -- Repeat the timer.
  end

  local sprite = enemy:get_sprite()
  local x, y, layer = enemy:get_position()
  local direction = sprite:get_direction()

  sprite:set_animation("shooting")
  sol.timer.start(enemy, 500, function()
    sol.audio.play_sound("lamp")
    local flame = enemy:create_enemy({ breed = "fireball_small", x, y, layer = 1, direction = 0 })
    sol.timer.start(enemy, 2000, function() enemy:restart() end)
  end)
end

function enemy:on_restarted()
  can_shoot = true
  local sprite = enemy:get_sprite()
  sprite:set_animation("stopped")

  sol.timer.start(enemy, 5000, function()
    local hero_x, hero_y = hero:get_position()
    local x, y = enemy:get_center_position()

    if can_shoot then
      local aligned = (math.abs(hero_x - x) < 16 or math.abs(hero_y - y) < 16) 
      if aligned and enemy:get_distance(hero) < 200 then
        shoot()
        can_shoot = false
        sol.timer.start(enemy, 5000, function() can_shoot = true end)
      end
    end
    return true  -- Repeat the timer.
  end)
end