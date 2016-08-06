local map = ...
local game = map:get_game()

-------------------------------------------------------------
-- Outside World F13 (Faron Woods) - Deacon the Lumberjack --
-------------------------------------------------------------

local function follow_hero(npc)
  local hero_x, hero_y, hero_layer = hero:get_position()
  local npc_x, npc_y, npc_layer = npc:get_position()
  local distance_hero = math.abs((hero_x+hero_y)-(npc_x+npc_y))
  local m = sol.movement.create("target")
  m:set_speed(40)
  m:start(npc)
  npc:get_sprite():set_animation("walking")
  sol.timer.start(3000, function() m:stop(npc) end)
end

local function random_walk(npc)
  local m = sol.movement.create("random_path")
  m:set_speed(32)
  m:start(npc)
  npc:get_sprite():set_animation("walking")
end

function map:on_started(destination)
  game:set_dialog_style("default")
  if game:get_value("i1602") <= 2 or game:get_value("i1602") > 4 then
    npc_gaira:remove()
  end
  if game:get_value("i1602") == 3 then
    npc_deacon:remove()
    follow_hero(npc_gaira)
    sol.timer.start(2000, function()
      game:start_dialog("gaira.4.faron")
    end)
  elseif game:get_value("i1602") == 4 then
    npc_gaira:set_position(88, 728)
    npc_deacon:set_position(128, 712)
    sol.timer.start(1000, function()
      game:set_value("i1602", 5)
      game:start_dialog("gaira.4.faron_deacon1", function()
        game:set_dialog_position("top")
        game:start_dialog("deacon.4.faron", game:get_player_name(), function()
          game:set_dialog_position("bottom")
          game:start_dialog("gaira.4.faron_deacon2", game:get_player_name(), function()
            game:set_dialog_position("top")
            game:start_dialog("deacon.4.faron_gaira3", function()
              game:set_dialog_position("bottom")
              game:start_dialog("gaira.4.faron_deacon4", function()
                game:set_dialog_position("top")
                game:start_dialog("deacon.4.faron_gaira5", function()
                  game:set_value("i1602", 6)
                end)
              end)
            end)
          end)
        end)
      end)
    end)
  elseif game:get_value("i1602") == 6 or game:get_time_of_day() == "night" then
    npc_deacon:remove()
  end

  -- Activate any night-specific dynamic tiles.
  if game:get_time_of_day() == "night" then
    for entity in game:get_map():get_entities("night_") do
      entity:set_enabled(true)
    end
  end
end

function sensor_music:on_activated()
  if game:get_hero():get_direction() == 3 then sol.audio.play_music("town_ordon") end
end