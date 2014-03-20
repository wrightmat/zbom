local enemy = ...

-- Manhandla: boss with multiple heads to attack - this file defines the body segment
--            directly then creates the heads (green, red, blue, purple) dynamically.

local heads_present = 0

-- Makes the boss go toward a diagonal direction (1, 3, 5 or 7).
function enemy:go(direction8)
  local m = sol.movement.create("straight")
  m:set_speed(80)

  m:set_smooth(false)
  m:set_angle(direction8 * math.pi / 4)
  m:start(self)
  last_direction8 = direction8
end

-- Four heads are created right after the body - these are attacked first.
function enemy:create_head(color)
  if color == "blue" then
    -- blue on right
    head = self:create_enemy({name="manhandla_head_blue", breed="manhandla_head", x=12, y=6})
    head.color = "blue"
    head:add_life(2)
    head:get_sprite():set_direction(0)
  elseif color == "purple" then
    -- purple on top
    head = self:create_enemy({name="manhandla_head_purple", breed="manhandla_head", x=6, y=-12})
    head.color = "purple"
    head:add_life(3)
    head:get_sprite():set_direction(1)
  elseif color == "green" then
    -- green goes on left
    head = self:create_enemy({name="manhandla_head_green", breed="manhandla_head", x=-12, y=6})
    head.color = "green"
    head:get_sprite():set_direction(2)
  elseif color == "red" then
    -- red on bottom
    head = self:create_enemy({name="manhandla_head_red", breed="manhandla_head", x=6, y=12})
    head.color = "red"
    head:add_life(1)
    head:get_sprite():set_direction(3)
  end
  head.body = self
  heads_present = heads_present + 1
end

function enemy:on_created()
  self:set_life(3)
  self:set_damage(2)
  self:create_sprite("enemies/manhandla")
  self:set_size(24, 24)
  self:set_origin(12, 12)
  self:set_hurt_style("boss")
end

function enemy:on_enabled()
  -- create one of the heads every second in order from easiest to hardest
  sol.timer.start(self, 1000, function()
    self:create_head("green")
    sol.timer.start(self, 1000, function()
      self:create_head("red")
      sol.timer.start(self, 1000, function()
        self:create_head("blue")
        sol.timer.start(self, 1000, function()
          self:create_head("purple")
        end)
      end)
    end)
  end)
end

function enemy:on_restarted()
  local direction8 = math.random(4) * 2 - 1
  self:go(direction8)
end

function enemy:on_update()
  heads_present = self:get_map():get_entities_count("manhandla_head")
  if heads_present > 0 then
    -- if there are heads (and how many)
    self:set_attack_consequence("sword", "protected")
  else
    -- if only the body is left (only three more hits then dead!)
    self:set_attack_consequence("sword", 1)
  end
end

-- An obstacle is reached: make the boss bounce.
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
