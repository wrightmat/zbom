local map = ...
local game = map:get_game()

---------------------------------
-- Outside D3 - Midoro Palace  --
---------------------------------

function npc_bagu:on_interaction()
  -- Must have Golden Bracelet before Bagu will let you into Saria
  if not game:get_value("b1611") then
    if game:get_value("i1817") > 1 then
      game:start_dialog("bagu.1.bridge", function()
	game:set_value("b1611", true)
      end)
    else
      game:start_dialog("bagu.0.bridge")
    end
  else
    game:start_dialog("bagu.2.bridge")
  end
end
