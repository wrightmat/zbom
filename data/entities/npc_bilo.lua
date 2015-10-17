local entity = ...
local game = entity:get_game()
local map = entity:get_game():get_map()

if game:get_value("i1027")==nil then game:set_value("i1027", 0) end
if game:get_value("i1032")==nil then game:set_value("i1032", 0) end
if game:get_value("i1905")==nil then game:set_value("i1905", 0) end
if game:get_value("i3005")==nil then game:set_value("i3005", 0) end

-- Bilo is a minor NPC who lives in Ordon.
-- He can be found traveling around, looking for a more permanent home.

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
  m:set_ignore_obstacles(false)
  m:set_speed(40)
  m:start(entity)
  entity:get_sprite():set_animation("walking")
 end)
end

function entity:on_created()
  self:set_drawn_in_y_order(true)
  self:set_can_traverse("hero", false)
  self:set_traversable_by("hero", false)
  if map:get_id() == "32" then random_walk() end
end

function entity:on_interaction()
  game:set_dialog_style("default")
  if map:get_id() == "32" then
    game:start_dialog("bilo.0.field")
  else
    if map:get_game():get_value("i3005") == 0 then
      game:start_dialog("bilo.0")
    elseif game:get_value("i1032") >= 3 then
      game:start_dialog("bilo.2")
    elseif game:get_value("i1905") >= 1 and game:get_value("i1027") >= 4 then
      game:start_dialog("bilo.1")
    else
      game:start_dialog("bilo.0")
    end
  end
end

function entity:on_movement_changed(movement)
  local direction = movement:get_direction4()
  entity:get_sprite():set_direction(direction)
end