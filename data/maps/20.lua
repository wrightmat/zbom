local map = ...
local game = map:get_game()

------------------------------------------------------------------------------
-- Outside World D15 (Sacred Grove) - Deku/Tokay conflict, Monkey mini-game --
------------------------------------------------------------------------------

local positions = {
  {x = 216, y = 824},
  {x = 296, y = 704},
  {x = 520, y = 792},
  {x = 328, y = 576},
  {x = 656, y = 584},
  {x = 736, y = 872},
  {x = 888, y = 768},
  {x = 880, y = 488},
}

if game:get_value("i1068")==nil then game:set_value("i1068", 0) end --Tokay/Deku conflict

function map:on_started(destination)
  if game:get_value("i1068") > 6 then
    npc_tokay_1:remove()
    npc_tokay_2:remove()
    npc_tokay_3:remove()
    npc_deku_warning:remove()
    local position1 = (positions[math.random(#positions)])
    npc_deku_1:set_position(position1.x, position1.y)
    local position2 = (positions[math.random(#positions)])
    if position2 == position1 then position2 = (positions[math.random(#positions)]) end
    npc_deku_2:set_position(position2.x, position2.y)
    local position3 = (positions[math.random(#positions)])
    if position3 == position1 or position3 == position2 then position3 = (positions[math.random(#positions)]) end
    npc_deku_3:set_position(position3.x, position3.y)
  end
  if game:get_value("i1068") == 9 then
    npc_monkey_1:remove()
    npc_monkey_2:remove()
  end
end

function sensor_deku_tokay:on_activated()
  if game:get_value("i1068") < 1 and hero:get_direction() == 2 then --only walking left
    game:set_value("i1068", 1)
    sol.audio.play_sound("tokay")
    game:start_dialog("tokay.0.faron", function()
      sol.audio.play_sound("deku")
      game:start_dialog("deku.0.faron")
    end)
  elseif game:get_value("i1068") >= 2 and game:get_value("i1068") <= 4 and hero:get_direction() == 0 then --only walking right
    game:start_dialog("tokay.0.desert")
  elseif game:get_value("i1068") == 7 then
    -- In the future there may be a mini-game to retrieve book piece, but for now just give it back
    game:set_value("i1068", 9)
    sol.audio.play_sound("monkey")
    game:start_dialog("monkey.2.faron", function()
      game:get_item("book_mudora"):set_variant(2) --give back book piece
      game:set_value("b1061", true)
    end)
  end
end

function npc_monkey_1:on_interaction()
  if game:get_value("i1068") == 7 then
    game:set_value("i1068", 9)
    sol.audio.play_sound("monkey")
    game:start_dialog("monkey.2.faron", function()
      game:get_item("book_mudora"):set_variant(2) --give back book piece
    end)
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
    game:start_dialog("monkey.2.faron", function()
      game:get_item("book_mudora"):set_variant(2) --give back book piece
    end)
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
    if game:get_value("i1032") > 2 then
      repeat -- make sure the same quote is not picked again
        index = math.random(5)
      until index ~= last_message
      game:start_dialog("deku.4.faron."..index)
      last_message = index
    else
      sol.audio.play_sound("deku")
      game:start_dialog("deku1.1.faron")
    end
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
    if game:get_value("i1032") > 2 then
      repeat -- make sure the same quote is not picked again
        index = math.random(5)
      until index ~= last_message
      game:start_dialog("deku.4.faron."..index)
      last_message = index
    else
      sol.audio.play_sound("deku")
      game:start_dialog("deku2.1.faron")
    end
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
    if game:get_value("i1032") > 2 then
      repeat -- make sure the same quote is not picked again
        index = math.random(5)
      until index ~= last_message
      game:start_dialog("deku.4.faron."..index)
      last_message = index
    else
      sol.audio.play_sound("deku")
      game:start_dialog("deku3.1.faron")
    end
  end
end

function npc_deku_warning:on_interaction()
  if not game:has_item("bow") then
    sol.audio.play_sound("deku")
    game:start_dialog("deku.0.warning")
  else
    sol.audio.play_sound("deku")
    game:start_dialog("deku.4.faron.2")
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
