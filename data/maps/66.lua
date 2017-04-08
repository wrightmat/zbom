local map = ...
local game = map:get_game()

-----------------------------------
-- Outside World H6 (Goron City) --
-----------------------------------

local function random_walk(npc)
  local m = sol.movement.create("random_path")
  m:set_speed(32)
  m:start(npc)
  npc:get_sprite():set_animation("walking")
end

function map:on_started(destination)
  random_walk(npc_botoglo)
  random_walk(npc_golo)
  random_walk(npc_rogulo)
  random_walk(npc_dotombo)
  
  if game:get_value("i1029") == 5 then
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

  -- Activate any night-specific dynamic tiles.
  if game:get_time_of_day() == "night" then
    for entity in game:get_map():get_entities("night_") do
      entity:set_enabled(true)
    end
  end
end

npc_botoglo:register_event("on_interaction", function()
  if game:get_value("b1699") then
    game:start_dialog("goron1.0.goron_city_mine")
  else
    game:start_dialog("goron1.0.goron_city")
  end
end)

npc_golo:register_event("on_interaction", function()
  if game:get_value("b1699") then
    game:start_dialog("goron2.0.goron_city_mine")
  else
    game:start_dialog("goron2.0.goron_city")
  end
end)

npc_rogulo:register_event("on_interaction", function()
  game:start_dialog("goron3.0.goron_city")
end)

npc_dotombo:register_event("on_interaction", function()
  game:start_dialog("goron4.0.goron_city")
end)