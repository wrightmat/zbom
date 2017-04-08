local map = ...
local game = map:get_game()

---------------------------------------
-- Outside World F5 (Septen Heights) --
---------------------------------------

if game:get_value("i1926")==nil then game:set_value("i1926", 0) end
if game:get_value("i1927")==nil then game:set_value("i1927", 0) end
if game:get_value("i1928")==nil then game:set_value("i1928", 0) end

local function random_walk(npc)
  local m = sol.movement.create("random_path")
  m:set_speed(32)
  m:start(npc)
  npc:get_sprite():set_animation("walking")
end

function map:on_started(destination)
  if game:get_time_of_day() == "night" then
    npc_quinn:remove()
  else
    random_walk(npc_rhett)
    random_walk(npc_quinn)
  end
  if game:is_dungeon_finished(7) then
    bridge_1:set_enabled(true)
    bridge_2:set_enabled(true)
    bridge_3:set_enabled(true)
    bridge_4:set_enabled(true)
  elseif game:get_value("i1926") >= 2 and game:get_value("i1927") >= 2 then
    npc_horwin:remove()
  end

  -- Activate any night-specific dynamic tiles.
  if game:get_time_of_day() == "night" then
    for entity in game:get_map():get_entities("night_") do
      entity:set_enabled(true)
    end
  end
end

npc_rhett:register_event("on_interaction", function()
  if math.random(2) == 1 then
    game:start_dialog("rito_1.0.septen")
  else
    game:start_dialog("rito_1.1.zora")
  end
end)

npc_zomali:register_event("on_interaction", function()
  if game:get_value("i1928") >= 1 then
    if game:get_value("i1840") < 5 then
      game:start_dialog("rito_2.1.septen")
    else
      game:start_dialog("rito_2.0.septen")
    end
  else
    game:start_dialog("rito_2.0.septen", function()
      game:set_value("i1928", 1)
    end)
  end
end)

npc_quinn:register_event("on_interaction", function()
  if game:get_value("b1150") then
    game:start_dialog("rito_3.1.septen")
  else
    game:start_dialog("rito_3.0.septen")
  end
end)

npc_horwin:register_event("on_interaction", function()
  if game:is_dungeon_finished(7) and game:get_value("i1926") >= 3 then
    game:start_dialog("rito_carpenter.2.septen")
    sol.timer.start(game, 360000, function()
      -- After a real-time hour, the carpenter will return to the bridge
      -- (or speaking to the architect again with force it).
      game:set_value("i1926", 3)
    end)
  elseif game:get_value("i1926") >= 1 then
    game:start_dialog("rito_carpenter.1.septen")
    game:set_value("i1927", 2)
  else
    game:start_dialog("rito_carpenter.0.septen")
    game:set_value("i1927", 1)
  end
end)

function sign_tower:on_interaction()
  if game:get_value("b1150") then -- Tower under construction until after Snowpeak
    game:set_dialog_style("wood")
    game:start_dialog("sign.tower")
  else
    game:set_dialog_style("wood")
    game:start_dialog("sign.tower_construction")
  end
end