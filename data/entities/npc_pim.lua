local entity = ...
local game = entity:get_game()
local hero = game:get_map():get_entity("hero")
local warned = false

-- Pim is an NPC which appears on several maps and will sell
-- our hero a pumpkin if he doesn't have one already.

if game:get_value("i1845")==nil then game:set_value("i1845", 0) end
if game:get_value("i1925")==nil then game:set_value("i1925", 0) end

local function random_walk()
  local m = sol.movement.create("random_path")
  m:set_speed(24)
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
  if game:get_map():get_id() ~= "1" then
    random_walk()
  end
end

function entity:on_interaction()
  game:set_dialog_style("default")
  if game:get_value("i1024") <= 80 and not warned then
    game:start_dialog("pim.0.stamina")
    warned = true
  else
    if game:get_value("i1925") <= 2 then
      game:start_dialog("pim."..game:get_value("i1925")..".house")
      game:set_value("i1925", game:get_value("i1925")+1)
    elseif game:get_value("i1925") >=4 then
      if game:get_map():get_id() == "1" or game:get_value("i1845") > 1 then
	-- In his house, don't sell pumpkins
        game:start_dialog("pim.2.house")
      else
	game:start_dialog("pim.2.pumpkin", function(answer)
	  if answer == 1 and game:get_money() >= 100 then
	    game:remove_money(100)
	    hero:start_treasure("pumpkin")
	  else
	    game:start_dialog("pim.2.no_pumpkin", function(answer)
	      if answer == 1 then
		-- Provide directions depending on current map
		if game:get_map():get_id() == "23" then game:start_dialog("pim.directions.23") end
		if game:get_map():get_id() == "26" then game:start_dialog("pim.directions.26") end
		if game:get_map():get_id() == "40" then game:start_dialog("pim.directions.40") end
		if game:get_map():get_id() == "80" then game:start_dialog("pim.directions.80") end
	      else
		game:start_dialog("pim.2.no_directions")
	      end
	    end)
	  end
	end)
      end
    else
      game:start_dialog("pim.3.house", function()
	game:set_value("i1925", 4)
	hero:start_treasure("apple")
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