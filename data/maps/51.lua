local map = ...
local game = map:get_game()

------------------------------------------------------------------------
-- Outside World D7 (Kakariko City) - Houses, Ampitheater, Fireworks! --
------------------------------------------------------------------------

if game:get_value("i1920")==nil then game:set_value("i1920", 0) end

local function random_walk(npc)
  local m = sol.movement.create("random_path")
  m:set_speed(32)
  m:start(npc)
  npc:get_sprite():set_animation("walking")
end

local function fireworks_shower_start()
  fireworks_shower:get_sprite():set_animation("ground")
  sol.timer.start(4000, function()
    fireworks_shower:get_sprite():set_animation("stopped")
    sol.timer.start(math.random(10)*1000, fireworks_shower_start)
  end)
end

function map:on_started(destination)
  fireworks_shower:get_sprite():set_animation("stopped")
  local fire_show = math.random(10)*500
  sol.timer.start(fire_show, fireworks_shower_start)
  if game:get_time_of_day() == "day" then
    npc_rowin:remove()
    npc_moriss:remove()
    npc_etnaya:remove()
  end

  -- Opening doors
  local entrance_names = { "house_5", "house_7", "house_8", "house_9", "house_10" }
  for _, entrance_name in ipairs(entrance_names) do
    local sensor = map:get_entity(entrance_name .. "_door_sensor")
    local tile = map:get_entity(entrance_name .. "_door")
    sensor.on_activated_repeat = function()
      if hero:get_direction() == 1 and tile:is_enabled() and game:get_time_of_day() == "day" then
	tile:set_enabled(false)
	sol.audio.play_sound("door_open")
      end
    end
  end
end

function npc_warun:on_interaction()
  game:set_dialog_style("default")
  game:start_dialog("warun.0")
end

function npc_moriss:on_interaction()
  game:set_dialog_style("default")
  game:start_dialog("moriss.0.show")
end

function npc_rowin:on_interaction()
  game:set_dialog_style("default")
  if game:get_value("i1920") == 1 then
    game:start_dialog("rowin.1.show", function()
      game:set_value("i1920", game:get_value("i1920")+1)
    end)
  elseif game:get_value("i1920") == 2 then
    game:start_dialog("rowin.2.show")
  else
    game:start_dialog("rowin.0.show")
  end
end

function sensor_show:on_activated()
  if game:get_time_of_day() == "night" and game:get_value("i1920") < 3 then
    game:start_dialog("etnaya.1.show", function()
      sensor_show:set_enabled(false)
    end)
  end
end

function sign_ampitheater:on_interaction()
  if game:get_time_of_day() == "night" then
    game:set_dialog_style("wood")
    game:start_dialog("sign.ampitheater.2")
  else
    game:set_dialog_style("wood")
    game:start_dialog("sign.ampitheater")
  end
end