local map = ...
local game = map:get_game()

------------------------
-- Goron City houses  --
------------------------

if game:get_value("i1914") == nil then game:set_value("i1914", 0) end --Dargor rep
if game:get_value("i1916") == nil then game:set_value("i1916", 0) end --Galen rep
if game:get_value("i1029") == nil then game:set_value("i1029", 0) end --quest variable

function map:on_started(destination)
  npc_galen_2:get_sprite():set_direction(1)--up
  if game:get_value("i1029") < 2 then
    npc_galen_2:remove()
  elseif game:get_value("i1029") == 2 then
    npc_galen:remove()
  elseif game:get_value("i1029") >= 3 then
    npc_osgor:remove()
    npc_galen_2:remove()
    if game:get_value("i1029") == 3 then npc_galen:remove() end
  end

  if game:get_value("i1029") == 2 and destination == from_outside_house_sick then
    sol.timer.start(1000, function()
      hero:freeze()
      game:start_dialog("dargor.3.house", game:get_player_name(), function()
        npc_galen_2:get_sprite():set_animation("walking")
	local m = sol.movement.create("target")
        m:set_target(112, 384)
	m:set_speed(32)
	m:start(npc_galen_2, function()
	  npc_galen_2:get_sprite():set_animation("stopped")
	  npc_galen_2:get_sprite():set_direction(2)--left/west
          sol.timer.start(2000, function()
	    npc_galen_2:get_sprite():set_direction(0)--right/east
	    game:start_dialog("galen.2.house", game:get_player_name(), function()
	      npc_galen_2:get_sprite():set_animation("walking")
	      local m2 = sol.movement.create("target")
              m2:set_target(160, 488)
	      m:set_speed(16)
              m2:start(npc_galen_2, function()
	        npc_galen_2:remove()
	        hero:unfreeze()
	        game:set_value("i1029", 3)
	      end)
            end)
	  end)
        end)
      end)
    end)
  end
end

function npc_dargor:on_interaction()
  if game:get_value("i1914") == 1 then
    game:start_dialog("dargor.1.house", function()
      game:set_value("i1914", game:get_value("i1914")+1)
    end)
  elseif game:get_value("i1914") == 2 then
    game:start_dialog("dargor.2.house", function()
      game:set_value("i1914", game:get_value("i1914")+1)
      game:set_value("i1029", 1)
    end)
  elseif game:get_value("i1029") >= 3 then
    game:start_dialog("dargor.4.house", game:get_player_name())
  else
    game:start_dialog("dargor.0.house", function()
      game:set_value("i1914", game:get_value("i1914")+1)
    end)
  end
end

function npc_galen:on_interaction()
  if game:get_value("i1029") == 1 then
    game:start_dialog("galen.1.house", function()
      game:set_value("i1916", game:get_value("i1916")+1)
      game:set_value("i1029", 2)
    end)
  else
    game:start_dialog("galen.0.house", function()
      game:set_value("i1916", game:get_value("i1916")+1)
    end)
  end
end

function npc_osgor:on_interaction()
  game:start_dialog("osgor.0.house")
end

function npc_gor_larin:on_interaction()
  game:start_dialog("larin.1.house")
end

function npc_goron_smith:on_interaction()

end

function npc_goron_shopkeep:on_interaction()

end

function npc_goron_innkeep:on_interaction()

end

function inn_bed:on_activated()
  snores:set_enabled(true)
  bed:set_enabled(true)
  bed:get_sprite():set_animation("hero_sleeping")
  hero:freeze()
  hero:set_visible(false)
  sol.timer.start(1000, function()
    snores:remove()
    bed:get_sprite():set_animation("hero_waking")
    sleep_timer = sol.timer.start(1000, function()
      sensor_sleep:set_enabled(false)
      hero:set_visible(true)
      hero:start_jumping(4, 24, true)
      bed:get_sprite():set_animation("empty_open")
      sol.audio.play_sound("hero_lands")
    end)
    sleep_timer:set_with_sound(false)
  end)
end

function innkeeper_sensor:on_interaction()
  game:start_dialog("turt.0.inn", function(answer)
    if answer == 1 then
      game:remove_money(20)
      hero:teleport("5", "inn_bed", "fade")
      game:set_life(game:get_max_life())
      if game:get_value("i1026") < 2 then game:set_max_stamina(game:get_max_stamina()-20) end
      if game:get_value("i1026") > 5 then game:set_max_stamina(game:get_max_stamina()+20) end
      game:set_stamina(game:get_max_stamina())
      game:set_value("i1026", 0)
      game:switch_time_of_day()
      if game:get_time_of_day() == "day" then
        for entity in map:get_entities("night_") do
          entity:set_enabled(false)
        end
        night_overlay = nil
      else
        for entity in map:get_entities("night_") do
          entity:set_enabled(true)
        end
      end
    end
  end)
end
