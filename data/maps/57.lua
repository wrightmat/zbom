local map = ...
local game = map:get_game()

--------------------------------------
-- Outside World G5 (Zora's Domain) --
--------------------------------------

function map:on_started(destination)

end

function npc_zora_1:on_interaction()
  game:start_dialog("zora.0.domain")
end

function npc_zora_2:on_interaction()
  game:start_dialog("zora.0.domain")
end

function npc_zora_3:on_interaction()
  game:start_dialog("zora.0.domain")
end

function npc_zora_trading:on_interaction()
  if game:get_value("b2029") then
    game:start_dialog("zora.0.trading", function(answer)
      if answer == 1 then
        -- give him the vase, get the zora scale
        game:start_dialog("zora.0.trading_yes", function()
          hero:start_treasure("trading", 10)
          game:set_value("b2030", true)
          game:set_value("b2029", false)
        end)
      else
        -- don't give him the vase
        game:start_dialog("zora.0.trading_no")
      end
    end)
  else
    game:start_dialog("zora.0.domain")
  end
end