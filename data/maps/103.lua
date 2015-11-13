local map = ...
local game = map:get_game()

---------------------------------------------
-- Outside E4 - Midoro Swamp / Saria Town  --
---------------------------------------------

function map:on_started(destination)
  -- Able to get on bridge to get Crystal Ball or after Bagu gives permission
  if game:get_value("b2024") or game:get_value("b1611") then
    npc_river_man:set_position(880,749)
  else
  -- Otherwise River Man blocks it!
    npc_river_man:set_position(864,773)
  end
end

function npc_river_man:on_interaction()
  if game:get_value("b2024") then
    game:start_dialog("river_man.0.crystal_ball")
  elseif game:get_value("b2025") and map:get_hero():get_direction() == "0" then
    -- If coming from Saria after the Crystal Ball, move River Man out of the way
    game:start_dialog("river_man.0.bridge", function()
      npc_river_man:set_position(872,757)
    end)
  elseif game:get_value("b1611") then
    game:start_dialog("river_man.1.bridge")
  else
    game:start_dialog("river_man.0.bridge_out")
  end
end
