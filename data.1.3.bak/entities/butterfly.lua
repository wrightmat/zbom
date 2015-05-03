local entity = ...
local game = entity:get_game()
local hero = game:get_map():get_entity("hero")

-- A butterly is an entity which follows our hero sometimes,
-- flies randomly sometimes, and lands on things sometimes.

local function random_walk()
  local m = sol.movement.create("random_path")
  m:set_speed(32)
  m:start(entity)
  entity:get_sprite():set_animation("walking")
end

local function follow_hero()
 sol.timer.start(entity, 500, function()
  local hero_x, hero_y, hero_layer = hero:get_position()
  local npc_x, npc_y, npc_layer = entity:get_position()
  local distance_hero = math.abs((hero_x+hero_y)-(npc_x+npc_y))
  local m = sol.movement.create("target")
  m:set_ignore_obstacles(true)
  m:set_speed(40)
  m:start(entity)
  entity:get_sprite():set_animation("walking")
 end)
end

function entity:on_created()
  self:set_drawn_in_y_order(true)
  self:set_can_traverse("hero", true)
  self:set_traversable_by("hero", true)

  if math.random(10) < 5 then
    random_walk()
  else
    follow_hero()
  end
end

function entity:on_movement_changed(movement)
  local direction = movement:get_direction4()
  entity:get_sprite():set_direction(direction)
end
