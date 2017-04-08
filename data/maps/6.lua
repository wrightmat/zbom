local map = ...
local game = map:get_game()

----------------------------------------------------------------------
-- Beach/Desert houses (Tokay settlement, Astronomer, Gerudo, etc.) --
----------------------------------------------------------------------

function map:on_started(destination)
  if game:get_time_of_day() == "day" then
    npc_hesla:remove()
    npc_araeki:remove()
    npc_ibari:remove()
    npc_tokay_chef:remove()
    npc_tokay_alchemy:remove()
    alchemy_stone:remove()
    npc_tokay_crystal:remove()
    magic_crystal:remove()
    npc_tokay_plume:remove()
    goddess_plume:remove()
    npc_tokay_amber:remove()
    goron_amber:remove()
  end
  if not game:get_value("b2023") then quest_trading_tear:remove() end
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
  -- Remove Gerudo from houses if they aren't back to the desert yet.
  if game:get_value("i1068") <= 6 then
    npc_helsa:remove()
    npc_araeki:remove()
    npc_ibari:remove()
  end
end

npc_mosq:register_event("on_interaction", function()
  game:set_value("astronomer_spoken", true)
  if game:get_value("b2023") then
   game:start_dialog("astronomer.0.trading", function(answer)
    if answer == 1 then
      -- Give him the Deku Mask, get the Moon Tear.
      game:start_dialog("astronomer.0.trading_yes", function()
        hero:start_treasure("trading", 4)
        game:set_value("b2024", true)
        game:set_value("b2023", false)
        quest_trading_tear:remove()
      end)
    else
      -- Don't give him the Mask.
      game:start_dialog("astronomer.0.trading_no")
    end
   end)
  else
   game:start_dialog("astronomer.0.house")
  end
end)

npc_araeki:register_event("on_interaction", function()
  game:start_dialog("gerudo.3.desert")
end)

npc_ibari:register_event("on_interaction", function()
  game:start_dialog("gerudo.3.desert")
end)

npc_hesla:register_event("on_interaction", function()
  game:start_dialog("hesla.6.desert")
end)

function npc_tokay_chef:on_interaction()
  game:start_dialog("chef.0.house")
end

function npc_tokay_jade:on_interaction()
  game:start_dialog("tokay.mystic_jade", function(answer)
    if answer == 1 and game:get_money() >= 175 then
      game:remove_money(175)
      hero:start_treasure("jade")
    end
  end)
end

function npc_tokay_amber:on_interaction()
  game:start_dialog("tokay.goron_amber", function(answer)
    if answer == 1 and game:get_money() >= 180 then
      game:remove_money(180)
      hero:start_treasure("amber")
    end
  end)
end

function npc_tokay_alchemy:on_interaction()
  game:start_dialog("tokay.alchemy_stone", function(answer)
    if answer == 1 and game:get_money() >= 185 then
      game:remove_money(185)
      hero:start_treasure("alchemy")
    end
  end)
end

function npc_tokay_crystal:on_interaction()
  game:start_dialog("tokay.magic_crystal", function(answer)
    if answer == 1 and game:get_money() >= 190 then
      game:remove_money(190)
      hero:start_treasure("crystal")
    end
  end)
end

function npc_tokay_plume:on_interaction()
  game:start_dialog("tokay.goddess_plume", function(answer)
    if answer == 1 and game:get_money() >= 195 then
      game:remove_money(195)
      hero:start_treasure("plume")
    end
  end)
end