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

function map:on_started(destination)

end

function subrosian_shaman:on_interaction()
  -- Gives Master Ore after 50 Subrosian Ore obtained
  if game:get_value("i1922") == 0 then
    game:start_dialog("subrosian_shaman.0.subrosia")
    game:set_value("i1922", 1)
  elseif game:get_value("i1922") > 0 and game:get_value("i1836") >= 50 then
    game:start_dialog("subrosian_shaman.3.subrosia", function()
      hero:start_treasure("master_ore", 0, "b1851", function()
        game:start_dialog("subrosian_shaman.4.subrosia")
        game:set_value("i1922", 4)
      end)
    end)
  elseif game:get_value("i1922") == 3 then
    game:start_dialog("subrosian_shaman.2.subrosia")
  elseif game:get_value("i1922") >= 4 then
    game:start_dialog("subrosian_shaman.1.subrosia")
  elseif game:get_value("i1922") < 3 then
    game:start_dialog("subrosian_shaman."..game:get_value("i1922")..".subrosia")
    game:set_value("i1922", game:get_value("i1922")+1)
  end
end
