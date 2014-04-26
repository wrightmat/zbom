local map = ...
local game = map:get_game()

-------------------------------------------------------------
-- Outside World F13 (Faron Woods) - Deacon the Lumberjack --
-------------------------------------------------------------

if game:get_value("i1913")==nil then game:set_value("i1913", 0) end

local function follow_hero(npc)
  local hero_x, hero_y, hero_layer = hero:get_position()
  local npc_x, npc_y, npc_layer = npc:get_position()
  local distance_hero = math.abs((hero_x+hero_y)-(npc_x+npc_y))
  local m = sol.movement.create("target")
  if distance_hero > 1000 then
    m:set_speed(64)
  elseif distance_hero < 20 then
    m:set_speed(32)
  else
    m:set_speed(48)
  end
  m:start(npc)
  npc:get_sprite():set_animation("walking")
end

local function random_walk(npc)
  local m = sol.movement.create("random_path")
  m:set_speed(32)
  m:start(npc)
  npc:get_sprite():set_animation("walking")
end

function map:on_started(destination)
  if game:get_value("i1602") <= 2 then
    npc_gaira:remove()
  elseif game:get_value("i1602") == 3 then
    npc_deacon:remove()
    follow_hero(npc_gaira)
    sol.timer.start(2000, function()
      game:start_dialog("gaira.4.faron")
    end)
  elseif game:get_value("i1602") == 4 then
    npc_deacon:set_position(128, 712)
    sol.timer.start(1000, function()
      game:set_value("i1602", 5)
      game:start_dialog("gaira.4.faron_deacon1", function()
	game:start_dialog("deacon.4.faron", function()
	  game:start_dialog("gaira.4.faron_deacon2", function()
	    game:start_dialog("deacon.4.faron_gaira3", function()
	      game:start_dialog("gaira.4.faron_deacon4", function()
		game:start_dialog("deacon.4.faron_gaira5", function()
		  game:set_value("i1602", 6)
		end)
	      end)
	    end)
          end)
        end)
      end)
    end)
  elseif game:get_value("i1602") == 6 then
    npc_deacon:remove()
    npc_gaira:remove()
  end
end

function npc_deacon:on_interaction()
  if game:get_value("i1602") == 1 then
    game:start_dialog("deacon.2.faron", function()
      game:set_value("i1602", 2)
    end)
  end
  if game:get_value("i1913") == 1 then
    game:start_dialog("deacon.1.faron")
    game:set_value("i1913", game:get_value("i1913")+1)
  else
    game:start_dialog("deacon.0.faron")
    game:set_value("i1913", game:get_value("i1913")+1)
  end
end
