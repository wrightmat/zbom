local map = ...
local game = map:get_game()

-----------------------------------
-- Outside World H7 (Goron City) --
-----------------------------------

function map:on_started(destination)

  -- Opening doors
  local entrance_names = {
    "house_3", "house_4", "house_leader"
  }
  for _, entrance_name in ipairs(entrance_names) do
    local sensor = map:get_entity(entrance_name .. "_door_sensor")
    local tile = map:get_entity(entrance_name .. "_door")
    sensor.on_activated_repeat = function()
      if hero:get_direction() == 1
	  and tile:is_enabled() then
	tile:set_enabled(false)
	sol.audio.play_sound("door_open")
      end
    end
  end

  if game:get_value("i1029") == 3 then
    -- wait until Link gets outside to declare the child dead.
    -- that way when he goes back in the child will be gone from
    -- the bed and when he goes outside again the ghost will be there.
    npc_goron_ghost:remove()
    game:set_value("i1029", 4)
  elseif game:get_value("i1029") == 4 or game:get_value("i1029") == 5 then
    sol.audio.play_sound("ghost")
    game:start_dialog("osgor.0.ghost", function()
      game:set_value("i1029", 5)
      -- start following hero
      sol.audio.play_sound("ghost")
      local m = sol.movement.create("target")
      m:set_speed(16)
      m:start(npc_goron_ghost)
      -- after a while, suggest the hero visit the mausoleum
      -- (this timer should persist and trigger as long as the
      -- hero's on a map that has the ghost present)
      dialog_timer = sol.timer.start(game, 10000, function()
        if npc_goron_ghost ~= nil then game:start_dialog("osgor.1.ghost") end
      end)
    end)
  else
    npc_goron_ghost:remove()
  end

end
