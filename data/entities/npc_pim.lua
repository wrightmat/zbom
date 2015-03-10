local entity = ...
local game = entity:get_game()

-- Pim is an NPC which appears on several maps and will sell
-- our hero a pumpkin if he doesn't have one already.

function entity:on_created()
  self:set_drawn_in_y_order(true)
  self:set_traversable_by("hero", false)
  if game:get_map():get_id() ~= "1" then
    if game:get_value("i1845") > 1 then
      self:remove() -- He leaves if you have a pumpkin
    else
      random_walk() -- Otherwise he wanders around
    end
  end
end

function entity:on_interaction()
  if game:get_value("i1024") <= 80 then
    game:start_dialog("pim.0.stamina")
  else
    if game:get_value("i1925") <= 2 then
      game:start_dialog("pim."..game:get_value("i1925")..".house")
      game:set_value("i1925", game:get_value("i1925")+1)
    elseif game:get_value("i1925") >=4 then
      if game:get_map():get_id() == "1" then
	-- In his house, don't sell pumpkins
        game:start_dialog("pim.2.house")
      else
	game:start_dialog("pim.2.pumpkin", function(answer)
	  if answer == 1 and game:get_money() >= 100 then
	    game:remove_money(100)
	    hero:start_treasure("pumpkin")
	  else
	    game:start_dialog("pim.2.no_pumpkin", function()
	      if answer = 1 then
		-- Provide directions depending on current map
		if game:get_map():get_id() == "23" then game:start_dialog("pim.directions.23") end
		if game:get_map():get_id() == "26" then game:start_dialog("pim.directions.26") end
	      else
		game:start_dialog("pim.2.no_directions")
	      end
	    end)
	  end
	end)
    else
      game:start_dialog("pim.3.house", function()
	game:set_value("i1925", 4)
	hero:start_treasure("apple")
      end)
    end
  end
end

local function random_walk()
  local m = sol.movement.create("random_path")
  m:set_speed(32)
  m:start(self)
  self:get_sprite():set_animation("walking")
end

local function follow_hero()
 sol.timer.start(self, 500, function()
  local hero_x, hero_y, hero_layer = hero:get_position()
  local npc_x, npc_y, npc_layer = self:get_position()
  local distance_hero = math.abs((hero_x+hero_y)-(npc_x+npc_y))
  local m = sol.movement.create("target")
  m:set_ignore_obstacles(false)
  m:set_speed(40)
  m:start(self)
  self:get_sprite():set_animation("walking")
 end)
end
