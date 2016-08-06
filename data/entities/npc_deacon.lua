local entity = ...
local game = entity:get_game()
local map = entity:get_game():get_map()
local hero = entity:get_game():get_hero()

if game:get_value("i1602")==nil then game:set_value("i1602", 0) end
if game:get_value("i1913")==nil then game:set_value("i1913", 0) end

-- Deacon is a minor NPC who lives outside of Ordon.
-- He is a lumberjack who helps direct our hero through the woods.
-- There is a small "match maker" sidequest between Deacon and Gaira.

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
end

function entity:on_interaction()
  -- First, make the NPC face the hero when interacting
  self:get_sprite():set_direction(self:get_direction4_to(game:get_hero()))

  if game:get_value("b1117") and not game:get_value("b1134") then
    -- Finished Mausoleum but not Lakebed, so direct to Lake Hylia.
    game:start_dialog("deacon.6.house")

  elseif game:get_value("i1602") == 6 then
    game:start_dialog("deacon.5.faron", game:get_player_name())
  elseif game:get_value("i1602") == 3 then
    game:start_dialog("deacon.3.house", function() game:set_value("i1602", 4) end)
  elseif game:get_value("i1602") == 1 then
    game:start_dialog("deacon.2.faron", function() game:set_value("i1602", 2) end)
  else
    if game:get_value("i1913") >= 3 and not game:get_value("b1134") then
      game:start_dialog("deacon.6.house", function() game:set_value("i1030", 1) end)
    elseif game:get_value("i1913") == 1 then
      game:start_dialog("deacon.1.faron")
      game:set_value("i1913", game:get_value("i1913")+1)
    else
      game:start_dialog("deacon.0.faron")
      game:set_value("i1913", game:get_value("i1913")+1)
    end
  end
end

function entity:on_movement_changed(movement)
  local direction = movement:get_direction4()
  entity:get_sprite():set_direction(direction)
end

-- Change HUD action to "Speak" when facing the NPC.
entity:add_collision_test("facing", function(entity, other)
  if other:get_type() == "hero" then 
    hero_facing = true
    if hero_facing then
      game:set_custom_command_effect("action", "speak")
      action_command = true
    else
      game:set_custom_command_effect("action", nil)
    end
  end
end)

function entity:on_update()
  if action_command and not hero_facing then
    game:set_custom_command_effect("action", nil)
    action_command = false
  end
  hero_facing = false
end