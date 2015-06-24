local map = ...
local game = map:get_game()

---------------------------------------
-- Outside World F5 (Septen Heights) --
---------------------------------------

if game:get_value("i1926")==nil then game:set_value("i1926", 0) end
if game:get_value("i1927")==nil then game:set_value("i1927", 0) end

local function random_walk(npc)
  local m = sol.movement.create("random_path")
  m:set_speed(32)
  m:start(npc)
  npc:get_sprite():set_animation("walking")
end

function map:on_started(destination)
  npc_rito_1:random_walk()
  npc_rito_3:random_walk()
  if game:get_value("i1926") >= 2 and game:get_value("i1927") >= 2 then
    npc_rito_carpenter:remove()
  end
end

function npc_rito_1:on_interaction()
  game:start_dialog("rito_1.0.septen")
end

function npc_rito_2:on_interaction()
  game:start_dialog("rito_2.0.septen")
end

function npc_rito_3:on_interaction()
  if game:get_value("b1150") then
    game:start_dialog("rito_3.1.septen")
  else
    game:start_dialog("rito_3.0.septen")
  end
end

function npc_rito_carpenter:on_interaction()
  if game:get_value("i1926") >= 1 then
    game:start_dialog("rito_carpenter.1.septen")
    game:set_value("i1927", 2)
  else
    game:start_dialog("rito_carpenter.0.septen")
    game:set_value("i1927", 1)
  end
end

function sign_tower:on_interaction()
  if game:get_value("b1150") then -- Tower under construction until after Snowpeak
    game:start_dialog("sign.tower")
  else
    game:start_dialog("sign.tower_construction")
  end
end

function ocarina_wind_to_M6:on_interaction()
  -- if this point not previously discovered
  -- then add it, otherwise do nothing
  if not game:get_value("b1510") then
    game:start_dialog("warp.new_point", function()
      game:set_value("b1510", true)
    end)
  else
    -- if other paired point is discovered (and they have the Ocarina),
    -- then ask the player if they want to warp there!
   if game:has_item("ocarina") then
    if game:get_value("b1511") then
      game:start_dialog("warp.to_M6", function(answer)
        if answer == 1 then
          sol.audio.play_sound("ocarina_wind")
          map:get_entity("hero"):teleport(139, "ocarina_warp", "fade")
        end
      end)
    else
      game:start_dialog("warp.interaction")
    end
   end
  end
end