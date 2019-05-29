local map = ...
local game = map:get_game()

-----------------------------------------------
-- Inside various caves - Blacksmith, etc.   --
-----------------------------------------------

if game:get_value("i1601")==nil then game:set_value("i1601", 0) end
if game:get_value("i1840")==nil then game:set_value("i1840", 0) end
if game:get_value("i1902")==nil then game:set_value("i1902", 0) end

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
    if blocker ~= nil then blocker:set_enabled(false) end
    if npc_moblin ~= nil then npc_moblin:remove() end
  end
  if game:get_value("i1822") > 1 then
    map:create_chest({ x = 1480, y = 1741, layer = 0, treasure_name = "rupee", treasure_variant = 5, sprite = "entities/chest" })
  else
    map:create_chest({ x = 1480, y = 1741, layer = 0, treasure_name = "tunic", treasure_variant = 2, sprite = "entities/chest" })
  end

  -- Activate any night-specific dynamic tiles.
  if game:get_time_of_day() == "night" then
    for entity in game:get_map():get_entities("night_") do
      entity:set_enabled(true)
    end
  end
end

npc_rudy:register_event("on_interaction", function()
  if game:get_value("i1902") == 0 then   -- General dialogs for low Rep.
    game:start_dialog("rudy.0", rudy_reputation)
  elseif game:get_value("i1841") == 4 then
    if game:get_value("i1902") >= 5 then
      game:start_dialog("rudy.5.sword_working")
      npc_rudy:get_sprite():set_direction(3)
    else
      -- Has Master Ore - offer to upgrade sword
      game:start_dialog("rudy.5.sword", function(answer)
        if answer == 1 then
          game:start_dialog("rudy.5.sword_1", function()
            game:set_value("i1902", 5)
            game:set_ability("sword", 0)
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
            if game:has_item("bottle_2") or game:has_item("bottle_3") or game:has_item("bottle_4") then
              game:start_dialog("rudy.2.cave_bottle_2", function() hero:start_treasure("bottle_1") end)
            else
              game:start_dialog("rudy.2.cave_bottle", function() hero:start_treasure("bottle_1") end)
            end
          end
        end)
      end
    elseif game:get_value("i1601") == 2 then
      -- Quest complete.
      game:start_dialog("rudy.4.cave", function(answer)
        if answer == 1 then -- Work.
          if game:get_value("i1841") == 3 then
            game:start_dialog("rudy.4.cave_work_3")
          elseif game:get_value("i1841") == 2 then
            game:start_dialog("rudy.4.cave_work_2")
          else game:start_dialog("rudy.4.cave_work") end
        else -- Chat.
          local rand = math.random(3)
          if rand == last_rand then rand = math.random(3) end
          game:start_dialog("rudy.4.cave_chat_"..rand)
          local last_rand = rand
          game:set_value("i1652", 1) -- Start the Master Ore quest in the tracker.
        end
      end)
    elseif game:get_value("i1902") >= 6 then
      game:start_dialog("rudy.6.cave")
    else
      game:start_dialog("rudy.1.cave", rudy_reputation)
      game:set_value("i1601", 1)
    end
  end
end)

function sensor_leaving:on_activated()
  if game:get_ability("sword") == 0 then
    game:start_dialog("rudy.5.sword_leaving", function()
      -- Upgrade the sword by one step.
      -- To get the light sword we need the blacksmith's quest
      -- and the fairy's quest but the order is not important.
      hero:start_treasure("sword", game:get_value("i1821") == 1 and 2 or 3)
      game:set_value("i1841", 5) -- Remove Master Ore.
      game:set_value("i1902", 6)
      game:set_value("i1652", 5)
    end)
  elseif not game:has_item("bottle_1") and game:get_value("i1902") >= 1 and game:get_hero():get_direction() == 3 then
    game:start_dialog("rudy.2.cave_bottle", function()
      hero:start_treasure("bottle_1")
    end)
  end
end