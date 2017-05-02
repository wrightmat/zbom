local map = ...
local game = map:get_game()

-------------------------------------------
-- Subrosia B1 (Underground J4) - Shaman --
-------------------------------------------

if game:get_value("i1922")==nil then game:set_value("i1922", 0) end

local function random_walk(npc)
  local m = sol.movement.create("random_path")
  m:set_speed(32)
  m:start(npc)
  npc:get_sprite():set_animation("walking")
end

npc_shaman:register_event("on_interaction", function()
  -- Gives Master Ore after 50 Subrosian Ore obtained.
  if game:get_value("i1652") > 2 and game:get_value("i1836") >= 50 and game:get_value("i1841") < 4 then
    game:start_dialog("subrosian_shaman.3.subrosia", function()
      -- Master ore is a special variant of "airship part" so it can go in that place in the inventory menu.
      hero:start_treasure("airship_part", 4, "i1841", function()
        game:start_dialog("subrosian_shaman.4.subrosia")
        game:set_value("i1836", game:get_value("i1836")-50)
        game:set_value("i1652", 4)
      end)
    end)
  else
    game:start_dialog("subrosian_shaman."..game:get_value("i1652")..".subrosia")
    game:set_value("i1652", game:get_value("i1652")+1)
  end
end)