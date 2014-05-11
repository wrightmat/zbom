local map = ...
local game = map:get_game()

----------------------------------------------------------------------------
-- Outside World G12 (Faron Woods, Sewer Access) - Sewer with Ordon Sword --
----------------------------------------------------------------------------

if game:get_value("i1901") == nil then game:set_value("i1901", 0) end

local function random_walk(npc)
  local m = sol.movement.create("random_path")
  m:set_speed(32)
  m:start(npc)
  npc:get_sprite():set_animation("walking")
end

function map:on_started(destination)
  if game:get_value("i1027") <= 4 then
    if game:has_item("sword") then
      game:start_dialog("crista.1.woods_chuchu", game:get_player_name())
    else
      for enemy in map:get_entities("chuchu") do
        enemy:remove()
      end
      random_walk(npc_crista)
    end
  else
    npc_crista:remove()
  end
end

function npc_crista:on_interaction()
  if game:get_value("i1901") >= 1 then
    if not map:has_entities("chuchu") and game:get_value("i1027") <= 4 then 
      game:start_dialog("crista.1.woods")
    elseif map:has_entities("chuchu") and game:get_value("i1027") <= 4 then
      game:start_dialog("crista.1.woods_chuchu", game:get_player_name())
    else
      game:start_dialog("crista.1.woods_close")
    end
  else
    if map:has_entities("chuchu") then
      game:start_dialog("crista.1.woods_chuchu", game:get_player_name())
    else
      game:start_dialog("crista.0.woods", game:get_player_name(), function(answer)
        if answer == 1 then
          game:set_value("i1901", game:get_value("i1901")+1)
          game:start_dialog("crista.0.woods_agree")
        else
          game:set_value("i1901", game:get_value("i1901")-1)
          game:start_dialog("crista.0.woods_disagree")
        end
      end)
    end
  end
end

for enemy in map:get_entities("chuchu") do
  enemy.on_dead = function()
    if not map:has_entities("chuchu") and game:get_value("i1027") <= 4 then
      game:start_dialog("crista.1.woods_chuchu_after", game:get_player_name(), function()
        game:set_value("i1027", 5)
        local m = sol.movement.create("target")
        m:set_target(776, 1120)
        m:set_speed(32)
        m:start(npc_crista, function()
	  npc_crista:remove()
        end)
      end)
    end
  end
end

function game:on_map_changed(map)
  function map:on_draw(dst_surface)
    if map:get_id() == "28" and lantern_overlay then lantern_overlay:fade_out() end
  end
end
