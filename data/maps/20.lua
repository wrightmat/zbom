local map = ...
local game = map:get_game()

------------------------------------------------------------------------------
-- Outside World D15 (Sacred Grove) - Deku/Tokay conflict, Monkey mini-game --
------------------------------------------------------------------------------

if game:get_value("i1068")==nil then game:set_value("i1068", 0) end --Tokay/Deku conflict

function map:on_started(destination)
  if game:get_value("i1068") > 6 then
    npc_tokay_1:remove()
    npc_tokay_2:remove()
    npc_tokay_3:remove()
  end
  if game:get_value("i1068") == 9 then
    npc_monkey_1:remove()
    npc_monkey_2:remove()
  end
end

function sensor_deku_tokay:on_activated()
  if game:get_value("i1068") == 0 then
    game:set_value("i1068", 1)
    game:start_dialog("tokay.0.faron")
  elseif game:get_value("i1068") == 7 then
    -- In the future there may be a mini-game to retrieve book piece, but for now just give it back
    game:set_value("i1068", 9)
    sol.audio.play_sound("monkey")
    game:start_dialog("monkey.2.faron", function()
      game:get_item("book_mudora"):set_variant(2) --give back book piece
    end)
  end
end

function npc_monkey_1:on_interaction()
  if game:get_value("i1068") == 7 then
    game:set_value("i1068", 9)
    sol.audio.play_sound("monkey")
    game:start_dialog("monkey.2.faron")
  elseif game:get_value("i1068") == 8 then
    -- may be a mini game later
  elseif game:get_value("i1068") == 9 then
    sol.audio.play_sound("monkey")
    game:start_dialog("monkey.3.faron")
  else
    sol.audio.play_sound("monkey")
    game:start_dialog("monkey1.0.faron")
  end
end

function npc_monkey_2:on_interaction()
  if game:get_value("i1068") == 7 then
    game:set_value("i1068", 9)
    sol.audio.play_sound("monkey")
    game:start_dialog("monkey.2.faron")
  elseif game:get_value("i1068") == 8 then
    -- may be a mini game later
  elseif game:get_value("i1068") == 9 then
    sol.audio.play_sound("monkey")
    game:start_dialog("monkey.3.faron")
  else
    sol.audio.play_sound("monkey")
    game:start_dialog("monkey2.0.faron")
  end
end

function npc_deku_1:on_interaction()
  if game:get_value("i1068") > 6 and game:get_value("i1068") < 9 then
    sol.audio.play_sound("deku")
    game:start_dialog("deku.2.faron")
  elseif game:get_value("i1068") == 9 then
    sol.audio.play_sound("deku")
    game:start_dialog("deku.3.faron")
  else
    sol.audio.play_sound("deku")
    game:start_dialog("deku1.1.faron")
  end
end

function npc_deku_2:on_interaction()
  if game:get_value("i1068") > 6 and game:get_value("i1068") < 9 then
    sol.audio.play_sound("deku")
    game:start_dialog("deku.2.faron")
  elseif game:get_value("i1068") == 9 then
    sol.audio.play_sound("deku")
    game:start_dialog("deku.3.faron")
  else
    sol.audio.play_sound("deku")
    game:start_dialog("deku2.1.faron")
  end
end

function npc_deku_3:on_interaction()
  if game:get_value("i1068") > 6 and game:get_value("i1068") < 9 then
    sol.audio.play_sound("deku")
    game:start_dialog("deku.2.faron")
  elseif game:get_value("i1068") == 9 then
    sol.audio.play_sound("deku")
    game:start_dialog("deku.3.faron")
  else
    sol.audio.play_sound("deku")
    game:start_dialog("deku3.1.faron")
  end
end

function npc_tokay_1:on_interaction()
  sol.audio.play_sound("tokay")
  game:start_dialog("tokay1.1.faron")
end

function npc_tokay_2:on_interaction()
  sol.audio.play_sound("tokay")
  game:start_dialog("tokay2.1.faron")
end

function npc_tokay_3:on_interaction()
  sol.audio.play_sound("tokay")
  game:start_dialog("tokay3.1.faron")
end

function map:on_update()
  if game:get_value("i1068") < 6 then
    -- if the dekus/tokay are fighting then keep them staring each other down!
    npc_deku_1:get_sprite():set_direction(2)
    npc_deku_2:get_sprite():set_direction(2)
    npc_deku_3:get_sprite():set_direction(2)
    npc_tokay_1:get_sprite():set_direction(0)
    npc_tokay_2:get_sprite():set_direction(0)
    npc_tokay_3:get_sprite():set_direction(0)
  end
end
