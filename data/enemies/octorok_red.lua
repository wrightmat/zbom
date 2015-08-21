local enemy = ...
local can_shoot = true
local map = enemy:get_map()
local hero = map:get_hero()

-- Octorok: Simple enemy who wanders and shoots rocks.

function enemy:on_created()
  self:set_life(2); self:set_damage(3)
  self:create_sprite("enemies/octorok_red")
  self:set_size(16, 16); self:set_origin(8, 13)
  self:set_hurt_style("monster")
  self:set_pushed_back_when_hurt(true)
  self:set_push_hero_on_sword(false)
end

local function go_hero()
  local sprite = enemy:get_sprite()
  sprite:set_animation("walking")
  local movement = sol.movement.create("target")
  movement:set_speed(48)
  movement:start(enemy)
end

local function shoot()
  if not enemy:is_in_same_region(hero) then
    return true  -- Repeat the timer.
  end

  local sprite = enemy:get_sprite()
  local x, y, layer = enemy:get_position()
  local direction = sprite:get_direction()

  -- Where to create the projectile.
  local dxy = {
    {  8,  -4 },
    {  0, -13 },
    { -8,  -4 },
    {  0,   0 },
  }

  sprite:set_animation("shooting")
  enemy:stop_movement()
  sol.timer.start(enemy, 300, function()
    sol.audio.play_sound("stone")
    local stone = enemy:create_enemy({
      breed = "projectiles/rock_small",
      x = dxy[direction + 1][1],
      y = dxy[direction + 1][2],
    })

    stone:go(direction)
    sol.timer.start(enemy, 500, go_hero)
  end)
end

function enemy:on_restarted()
  go_hero()
  can_shoot = true

  sol.timer.start(enemy, 100, function()
    local hero_x, hero_y = hero:get_position()
    local x, y = enemy:get_center_position()

    if can_shoot then
      local aligned = (math.abs(hero_x - x) < 16 or math.abs(hero_y - y) < 16) 
      if aligned and enemy:get_distance(hero) < 200 then
        shoot()
        can_shoot = false
        sol.timer.start(enemy, 1500, function()
          can_shoot = true
        end)
      end
    end
    return true  -- Repeat the timer.
  end)
end

function enemy:on_movement_changed(movement)
  local direction4 = movement:get_direction4()
  local sprite = self:get_sprite()
  sprite:set_direction(direction4)
end