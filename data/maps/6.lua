local map = ...
local game = map:get_game()

----------------------------------------------------------------------
-- Beach/Desert houses (Tokay settlement, Astronomer, Gerudo, etc.) --
----------------------------------------------------------------------

function map:on_started(destination)
  if destination == enter_astronomer then
    sol.audio.play_music("house_zuna")
  end
  if game:get_value("i1068") < 7 then
    npc_tokay_alchemy:remove()
    npc_tokay_crystal:remove()
    npc_tokay_plume:remove()
    npc_tokay_jade:remove()
    npc_tokay_amber:remove()
    alchemy_stone:remove()
    magic_crystal:remove()
    goddess_plume:remove()
    mystic_jade:remove()
    goron_amber:remove()
  end
end

function npc_astronomer:on_interaction()
  if game:get_value("b2023") then
   game:start_dialog("astronomer.0.trading", function(answer)
    if answer == 1 then
      -- give him the potion, get the deku mask
      game:start_dialog("astronomer.0.trading_yes", function()
        hero:start_treasure("trading", 4)
        game:set_value("b2024", true)
        game:set_value("b2023", false)
      end)
    else
      -- don't give him the potion
      game:start_dialog("astronomer.0.trading_no")
    end
   end)
  else
   game:start_dialog("astronomer.0.house")
  end
end

function npc_tokay_jade:on_interaction()
  game:start_dialog("tokay.mystic_jade", function(answer)
    if answer == 1 then
      hero:start_treasure("jade")
      game:remove_money(200)
    end
  end)
end

function npc_tokay_alchemy:on_interaction()
  game:start_dialog("tokay.alchemy_stone", function(answer)
    if answer == 1 then
      hero:start_treasure("alchemy")
      game:remove_money(200)
    end
  end)
end

function npc_tokay_crystal:on_interaction()
  game:start_dialog("tokay.magic_crystal", function(answer)
    if answer == 1 then
      hero:start_treasure("crystal")
      game:remove_money(200)
    end
  end)
end

function npc_tokay_plume:on_interaction()
  game:start_dialog("tokay.goddess_plume", function(answer)
    if answer == 1 then
      hero:start_treasure("plume")
      game:remove_money(200)
    end
  end)
end

function npc_tokay_amber:on_interaction()
  game:start_dialog("tokay.goron_amber", function(answer)
    if answer == 1 then
      hero:start_treasure("amber")
      game:remove_money(200)
    end
  end)
end
