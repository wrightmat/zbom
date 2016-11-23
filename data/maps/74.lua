local map = ...
local game = map:get_game()

------------------------------------------------------------------
-- Outside World B9 (Gerudo Airship Port) - Gerudo Airship Port --
------------------------------------------------------------------

function map:on_started(destination)
  if game:get_time_of_day() == "night" then
    npc_gerudo_leader:remove()
    npc_gerudo_pirate_1:remove()
    npc_gerudo_pirate_2:remove()
  end
  if game:get_value("i1068") <= 6 then
    gerudo_ship:remove()
    map:set_entities_enabled("block", false)
    npc_gerudo_leader:remove()
    npc_gerudo_pirate_1:remove()
    npc_gerudo_pirate_2:remove()
  elseif game:get_value("i1068") > 6 then
    gerudo_ship:get_sprite():set_animation("airship")
    map:set_entities_enabled("block", true)
  end

  -- Activate any night-specific dynamic tiles.
  if game:get_time_of_day() == "night" then
    for entity in game:get_map():get_entities("night_") do
      entity:set_enabled(true)
    end
    for entity in game:get_map():get_entities("torch_") do
      entity:get_sprite():set_animation("lit")
    end
  end
end

function npc_gerudo_pirate_1:on_interaction()
  game:set_dialog_style("default")
  game:start_dialog("gerudo.3.desert")
end

function npc_gerudo_pirate_2:on_interaction()
  game:set_dialog_style("default")
  game:start_dialog("gerudo.3.desert")
end

function npc_gerudo_leader:on_interaction()
  game:set_dialog_style("default")
  game:start_dialog("hesla.6.desert")
end