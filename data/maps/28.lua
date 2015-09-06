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

for enemy in map:get_entities("chuchu") do
  enemy.on_dead = function()
    if not map:has_entities("chuchu") and game:get_value("i1027") <= 4 then
      game:start_dialog("crista.1.woods_chuchu_after", game:get_player_name(), function()
        game:set_value("i1027", 5)
        local m = sol.movement.create("target")
	m:set_ignore_obstacles(true)
        m:set_target(768, 1120)
        m:set_speed(32)
        npc_crista:get_sprite():set_animation("walking")
        m:start(npc_crista, function()
	  npc_crista:remove()
        end)
      end)
    end
  end
end

function sign_directions_1:on_interaction()
  if game:has_item("sword") then
    game:set_dialog_style("wood")
    game:start_dialog("sign.G12_directions_1")
  else
    game:set_dialog_style("wood")
    game:start_dialog("sign.G12_danger")
  end
end
function sign_directions_2:on_interaction()
  if game:has_item("sword") then
    game:set_dialog_style("wood")
    game:start_dialog("sign.G12_directions_2")
  else
    game:set_dialog_style("wood")
    game:start_dialog("sign.G12_danger")
  end
end