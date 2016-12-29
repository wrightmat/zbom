local map = ...
local game = map:get_game()

------------------------------------------------------------------------------
-- Outside World D15 (Sacred Grove) - Deku/Tokay conflict, Monkey mini-game --
------------------------------------------------------------------------------

local positions = {
  {x = 216, y = 824},
  {x = 296, y = 720},
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
    if game:get_value("i1032") == 4 then
      npc_deku_1:remove()
      npc_deku_2:remove()
      npc_deku_3:remove()
    else
      local position1 = (positions[math.random(#positions)])
      npc_deku_1:set_position(position1.x, position1.y)
      local position2 = (positions[math.random(#positions)])
      if position2 == position1 then position2 = (positions[math.random(#positions)]) end
      npc_deku_2:set_position(position2.x, position2.y)
      local position3 = (positions[math.random(#positions)])
      if position3 == position1 or position3 == position2 then position3 = (positions[math.random(#positions)]) end
      npc_deku_3:set_position(position3.x, position3.y)
    end
  end
  if game:get_value("i1068") == 9 then
    npc_monkey_1:remove()
    npc_monkey_2:remove()
  end

  sol.timer.start(map, 1000, function()
    if game:get_value("i1068") < 6 then
      -- If the dekus/tokay are fighting then keep them staring each other down!
      npc_deku_1:get_sprite():set_direction(2)
      npc_deku_2:get_sprite():set_direction(2)
      npc_deku_3:get_sprite():set_direction(2)
      npc_tokay_1:get_sprite():set_direction(0)
      npc_tokay_2:get_sprite():set_direction(0)
      npc_tokay_3:get_sprite():set_direction(0)
      return true
    end
  end)
end

function sensor_deku_tokay:on_activated()
  if game:get_value("i1068") < 1 and hero:get_direction() == 2 then -- Only walking left.
    game:set_value("i1068", 1)
    sol.audio.play_sound("tokay")
    game:set_dialog_position("top")
    game:start_dialog("tokay.0.faron", function()
      sol.audio.play_sound("deku")
      game:set_dialog_position("bottom")
      game:start_dialog("deku.0.faron")
    end)
  elseif game:get_value("i1068") >= 1 and game:get_value("i1068") < 3 and game:get_value("b1061") then
    game:set_dialog_position("top")
    game:start_dialog("tokay.0.desert")
  elseif game:get_value("i1068") >= 3 and game:get_value("i1068") <= 4 and hero:get_direction() == 0 then -- Only walking right.
    game:set_dialog_position("top")
    game:start_dialog("tokay.1.desert")
  elseif game:get_value("i1068") == 7 or game:get_value("i1068") == 8 then
    -- Mini-game to retrieve book piece.
    sol.audio.play_sound("monkey")
    game:start_dialog("monkey.1.faron", function(answer)
      if answer == 1 then
        game:set_value("i1068", 8)
        game:get_hero():teleport("171")
      else
        game:start_dialog("monkey.1.faron_no")
      end
    end)
  end
end

function npc_monkey_1:on_interaction()
  if game:get_value("i1068") == 7 or game:get_value("i1068") == 8 then
    -- Mini-game to retrieve book piece.
    sol.audio.play_sound("monkey")
    game:start_dialog("monkey.1.faron", function(answer)
      if answer == 1 then
        game:set_value("i1068", 8)
        game:get_hero():teleport("171")
      else
        game:start_dialog("monkey.1.faron_no")
      end
    end)
  elseif game:get_value("i1068") == 9 then
    sol.audio.play_sound("monkey")
    game:start_dialog("monkey.3.faron")
  else
    sol.audio.play_sound("monkey")
    game:start_dialog("monkey1.0.faron")
  end
end

function npc_monkey_2:on_interaction()
  if game:get_value("i1068") == 7 or game:get_value("i1068") == 8 then
    -- Mini-game to retrieve book piece.
    sol.audio.play_sound("monkey")
    game:start_dialog("monkey.1.faron", function(answer)
      if answer == 1 then
        game:set_value("i1068", 8)
        game:get_hero():teleport("171")
      else
        game:start_dialog("monkey.1.faron_no")
      end
    end)
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
      repeat -- Make sure the same quote is not picked again.
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
      repeat -- Make sure the same quote is not picked again.
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
      repeat -- Make sure the same quote is not picked again.
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