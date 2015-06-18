local map = ...
local game = map:get_game()

-----------------------------------------------
-- Inside various caves - Blacksmith, etc.   --
-----------------------------------------------

if game:get_value("i1902")==nil then game:set_value("i1902", 0) end
if game:get_value("i1601")==nil then game:set_value("i1601", 0) end

function rudy_reputation()
  game:set_value("i1902", game:get_value("i1902")+1)
end

function map:on_started(destination)
  if game:get_value("i1902") < 2 or game:get_value("i1601") >= 1 then
    quest_rudy:remove() -- remove quest bubble if rep is too low or quest is already complete
  end
  if game:get_value("i1601") >= 2 then
    blacksmith_water:set_enabled(true)
  end
  if game:get_value("i1840") >= 7 then
    blocker:set_enabled(false)
    npc_moblin:remove()
  end
end

function npc_rudy:on_interaction()
  if game:get_value("i1902") == 0 then   -- General dialogs for low Rep
    game:start_dialog("rudy.0", rudy_reputation)
  elseif game:get_value("b1851") then
    if game:get_value("i1902") >= 5 then
      game:start_dialog("rudy.5.sword_working")
    else
      -- Has Master Ore - offer to upgrade sword
      game:start_dialog("rudy.5.sword", function(answer)
        if answer == 1 then
          game:start_dialog("rudy.5.sword_1", function()
	    game:set_ability("sword", 0)
	    game:set_value("i1902", 5)
            local m = sol.movement.create("target")
            m:set_target(232, 168)
            m:set_speed(32)
	    m:start(npc_rudy, function()
              local m = sol.movement.create("target")
              m:set_target(232, 168)
              m:set_speed(32)
              m:set_target(136, 120)
	      m:start(npc_rudy, function()
		m:stop()
	        npc_rudy:get_sprite():set_direction(3)
	        npc_rudy:get_sprite():set_animation("stopped")
	      end)
            end)
          end)
        else
          game:start_dialog("rudy.5.sword_2")
        end
      end)
    end
  elseif game:get_value("i1902") >= 1 then
    -- Cave-specific dialogs for water bottle side quest
    if game:get_value("i1601") == 1 then
      if game:get_item("bottle_1"):get_variant() == 2 then --bottle has water
        game:start_dialog("rudy.3.cave", function()
          game:get_item("bottle_1"):set_variant(1)
          game:set_value("i1601", 2)
        end)
      elseif game:get_item("bottle_2"):get_variant() == 2 then --bottle has water
        game:start_dialog("rudy.3.cave", function()
          game:get_item("bottle_2"):set_variant(1)
          game:set_value("i1601", 2)
        end)
      elseif game:get_item("bottle_3"):get_variant() == 2 then --bottle has water
        game:start_dialog("rudy.3.cave", function()
          game:get_item("bottle_3"):set_variant(1)
          game:set_value("i1601", 2)
        end)
      elseif game:get_item("bottle_4"):get_variant() == 2 then --bottle has water
        game:start_dialog("rudy.3.cave", function()
          game:get_item("bottle_4"):set_variant(1)
          game:set_value("i1601", 2)
        end)
      else
        game:start_dialog("rudy.2.cave", function()
          if not game:has_item("bottle_1") then
            game:start_dialog("rudy.2.cave_bottle", function()
              hero:start_treasure("bottle_1")
            end)
          end
        end)
      end
    elseif game:get_value("i1601") == 2 then
      -- quest complete
      game:start_dialog("rudy.4.cave", function(answer)
        if answer == 1 then --work
          game:start_dialog("rudy.4.cave_work")
        else --chat
          game:start_dialog("rudy.4.cave_chat")
        end
      end)
    elseif game:get_value("i1902") >= 6 then
      game:start_dialog("rudy.6.cave")
    else
      game:start_dialog("rudy.1.cave", rudy_reputation)
      game:set_value("i1601", 1)
    end
  end
end

function npc_moblin:on_interaction()
  if game:get_value("b2026") then
    game:start_dialog("moblin.0.trading", function(answer)
      if answer == 1 then
        -- give it the meat, get the dog food
        game:start_dialog("moblin.0.trading_yes", function()
          hero:start_treasure("trading", 7)
          game:set_value("b2027", true)
          game:set_value("b2026", false)
	  blocker:set_enabled(false)
        end)
      else
        -- don't give it the meat
        game:start_dialog("moblin.0.trading_no")
      end
    end)
  else
    game:start_dialog("moblin.0.cave_ordeals")
  end
end

function sensor_leaving:on_activated()
  if game:get_value("b1851") and game:get_ability("sword") == 0 then
    game:start_dialog("rudy.5.sword_leaving", function()
      hero:start_treasure("sword", 2)
      game:set_value("b1851", false)
      game:set_value("i1902", 6)
    end)
  end
end
