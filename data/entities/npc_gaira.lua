local entity = ...
local game = entity:get_game()
local map = entity:get_game():get_map()
local hero = entity:get_game():get_hero()

if game:get_value("i1602")==nil then game:set_value("i1602", 0) end
if game:get_value("i1911")==nil then game:set_value("i1911", 0) end

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
  m:set_speed(48)
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

  if map:get_id() == "17" then
    -- Outside of Deacon's house.
    if game:get_value("i1602") == 3 then
      game:start_dialog("gaira.4.faron")
    end
  elseif map:get_id() == "16" then
    if game:get_value("i1602") >= 2 then
      game:start_dialog("gaira.3.faron", function() game:set_value("i1602", 3) end)
      follow_hero(npc_gaira)
    else
      game:start_dialog("gaira.2.faron")
    end
  elseif map:get_id() == "1" then
    if not game:get_value("b1722") then
      game:start_dialog("gaira.5.faron", game:get_player_name(), function()
        hero:start_treasure("heart_piece", 1, "b1722")
      end)
    elseif game:get_value("i1030") < 2 then
      game:start_dialog("gaira.6.house")
    else
      game:start_dialog("gaira.5.forest")
    end
  else
    if game:get_value("i1911") == 1 then
      game:start_dialog("gaira.1.ordon", function()
        game:set_value("i1911", game:get_value("i1911")+1)
      end)
    elseif game:get_value("i1911") == 2 then
      game:start_dialog("gaira.2.ordon", function()
        game:set_value("i1911", game:get_value("i1911")+1)
        game:set_value("i1602", 1)
      end)
    else
      game:start_dialog("gaira.0.ordon", function()
        game:set_value("i1911", game:get_value("i1911")+1)
      end)
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