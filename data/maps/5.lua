local map = ...
local game = map:get_game()

------------------------
-- Goron City houses  --
------------------------

if game:get_value("i1914") == nil then game:set_value("i1914", 0) end --Dargor rep
if game:get_value("i1916") == nil then game:set_value("i1916", 0) end --Galen rep
if game:get_value("i1029") == nil then game:set_value("i1029", 0) end --quest variable

function map:on_started(destination)
  --npc_galen_2:get_sprite():set_direction(2)--up
  if game:get_value("i1029") < 2 or game:get_value("i1029") > 3 then
    npc_galen_2:remove()
  elseif game:get_value("i1029") >= 4 then
    npc_osgor:remove()
  end

  if destination == from_outside_house_sick then
    sol.timer.start(1000, function()
      hero:freeze()
      game:start_dialog("dargor.3.house", function()
        npc_galen_2:get_sprite():set_animation("walking")
	local m = sol.movement.create("target")
        m:set_target(112, 384)
	m:set_speed(16)
	m:start(npc_galen_2, function()
	  npc_galen_2:get_sprite():set_animation("stopped")
	  game:start_dialog("galen.2.house", function()
	    npc_galen_2:get_sprite():set_animation("walking")
	    local m2 = sol.movement.create("target")
            m2:set_target(168, 512)
            m2:start(npc_galen_2, function()
	      npc_galen_2:remove()
	      hero:unfreeze()
	      game:set_value("i1029", 3)
	    end)
          end)
        end)
      end)
    end)
  end
end

function npc_dargor:on_interaction()
  if game:get_value("i1914") == 1 then
    game:start_dialog("dargor.1.house", function()
      game:set_value("i1914", game:get_value("i1914")+1)
    end)
  elseif game:get_value("i1914") == 2 then
    game:start_dialog("dargor.2.house", function
      game:set_value("i1914", game:get_value("i1914")+1)
      game:set_value("i1029", 1)
    end)
  else
    game:start_dialog("dargor.0.house", function()
      game:set_value("i1914", game:get_value("i1914")+1)
    end)
  end
end

function npc_osgor:on_interaction()
  game:start_dialog("osgor.0.house")
end

function npc_galen:on_interaction()
  if game:get_value("i1916") == 1 then
    game:start_dialog("galen.1.house", function()
      game:set_value("i1916", game:get_value("i1916")+1)
      game:set_Value("i1029", 2)
    end)
  else
    game:start_dialog("galen.0.house", function()
      game:set_value("i1916", game:get_value("i1916")+1)
    end)
  end
end

function npc_goron_smith:on_interaction()

end

function npc_goron_shopkeep:on_interaction()

end

function npc_gor_lorin:on_interaction()

end
