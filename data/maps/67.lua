local map = ...
local game = map:get_game()

-----------------------------------
-- Outside World H7 (Goron City) --
-----------------------------------

local function random_walk(npc)
  local m = sol.movement.create("random_path")
  m:set_speed(32)
  m:start(npc)
  npc:get_sprite():set_animation("walking")
end

function map:on_started(destination)
  if game:get_time_of_day() == "day" then
    random_walk(npc_dagrazo)
    random_walk(npc_rokdo)
    random_walk(npc_dudoggo)
  else
    npc_dagrazo:remove()
    npc_rokdo:remove()
    npc_dudoggo:remove()
  end

  -- Opening doors
  local entrance_names = { "house_3", "house_4", "house_leader" }
  for _, entrance_name in ipairs(entrance_names) do
    local sensor = map:get_entity(entrance_name .. "_door_sensor")
    local tile = map:get_entity(entrance_name .. "_door")
    sensor.on_activated_repeat = function()
      if hero:get_direction() == 1 and tile:is_enabled() and game:get_time_of_day() == "day" then
        tile:set_enabled(false)
        sol.audio.play_sound("door_open")
      end
    end
  end

  if game:get_value("i1029") ~= 3 then
    npc_galen:remove()
  end
  if game:get_value("i1029") == 3 then
    -- Wait until Link gets outside to declare the child dead.
    -- that way when he goes back in the child will be gone from
    -- the bed and when he goes outside again the ghost will be there.
    npc_goron_ghost:remove()
    game:set_value("i1029", 4)
  elseif game:get_value("i1029") == 4 then
    sol.audio.play_sound("ghost")
    game:start_dialog("osgor.0.ghost", game:get_player_name(), function()
      game:set_value("i1029", 5)
      -- start following hero
      sol.audio.play_sound("ghost")
      local m = sol.movement.create("target")
      m:set_speed(32)
      m:start(npc_goron_ghost)
      -- After a while, suggest the hero visit the mausoleum
      -- (this timer should persist and trigger as long as the
      -- hero's on a map that has the ghost present).
      dialog_timer = sol.timer.start(game, 60000, function()
        if npc_goron_ghost ~= nil then
          sol.audio.play_sound("ghost")
          game:start_dialog("osgor.1.ghost", game:get_player_name())
          return true
        end
      end)
    end)
  elseif game:get_value("i1029") == 5 then
    -- Set position to hero and then follow
    -- (on intermediate layer so he doesn't collide).
    hx, hy, hl = map:get_entity("hero"):get_position()
    if map:get_entity("hero"):get_direction() == 0 or map:get_entity("hero"):get_direction() == 3 then
      npc_goron_ghost:set_position(hx+16, hy+16, 1)
    elseif map:get_entity("hero"):get_direction() == 1 or map:get_entity("hero"):get_direction() == 2 then
      npc_goron_ghost:set_position(hx-16, hy-16, 1)
    end
    sol.audio.play_sound("ghost")
    local m = sol.movement.create("target")
    m:set_speed(32)
    m:start(npc_goron_ghost)
  else
    npc_goron_ghost:remove()
  end
end

function npc_dagrazo:on_interaction()
  if game:get_value("b1699") then
    game:start_dialog("goron5.0.goron_city_mine")
  else
    game:start_dialog("goron5.0.goron_city")
  end
end

function npc_rokdo:on_interaction()
  if game:get_value("b1699") then
    game:start_dialog("goron6.0.goron_city_mine")
  else
    game:start_dialog("goron6.0.goron_city")
  end
end

function npc_dudoggo:on_interaction()
  if game:get_value("b1699") then
    game:start_dialog("goron7.0.goron_city_mine")
  else
    game:start_dialog("goron7.0.goron_city")
  end
end

function npc_galen:on_interaction()
  game:start_dialog("galen.2.outside")
end