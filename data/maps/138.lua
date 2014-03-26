local map = ...
local game = map:get_game()

-----------------------------------------------------------------
-- Outside World M5 (Ancient Library) - Library, Ordona Speaks --
-----------------------------------------------------------------

function map:on_started(destination)
  if game:get_value("i1032") == 1 then
    torch_ordona:get_sprite():set_animation("lit")
    sol.timer.start(4000, function()
      hero:freeze()
      torch_overlay = sol.surface.create("entities/dark.png")
      game:start_dialog("ordona.2.library", game:get_player_name(), function()
        torch_overlay:fade_out(50)
        hero:unfreeze()
        game:set_value("i1032", 2)
      end)
    end)
  end
end
