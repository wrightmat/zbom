local enemy = ...

-- Bubble: an invincible enemy that moves in diagonal directions
-- and bounces against walls - this one is made of water.

local last_direction8 = 0

function enemy:on_created()
  self:set_life(1)
  self:create_sprite("enemies/bubble_white")
  self:set_size(8, 8)
  self:set_origin(4, 4)
  self:set_can_hurt_hero_running(true)
  self:set_invincible()
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

-- Bubbles have a specific attack which drains magic (and freezes hero).
function enemy:on_attacking_hero(hero)
  local game = enemy:get_game()

  -- Hero is frozen.
  hero:start_frozen(4000)
  hero:set_invincible()

  -- If hero has magic, it is drained.
  if game:get_magic() > 0 then
    game:remove_magic(4)
    sol.audio.play_sound("magic_bar")
  end
end
