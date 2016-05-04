local map = ...
local game = map:get_game()
local creating_fire = false

----------------------------------------------------
-- Great Fairy Palace - Fountain of Understanding --
----------------------------------------------------

if game:get_value("i1608")==nil then game:set_value("i1608", 0) end
if game:get_value("i1834")==nil then game:set_value("i1834", 0) end

function map:on_started(destination)
  if game:get_value("i1608") >= 1 and game:get_value("i1608") < 5 then  -- force the initial dialog to be heard
    if game:get_value("i1834") >= 10 then game:set_value("i1608", 2) end
    if game:get_value("i1834") >= 20 then game:set_value("i1608", 3) end
    if game:get_value("i1834") >= 35 then game:set_value("i1608", 4) end
    if game:get_value("i1834") >= 50 then game:set_value("i1608", 5) end
  end
  if game:get_value("b1200") then map:set_doors_open("door_fairy") end
  custom_sensor_bubble:add_collision_test("overlapping", function(sensor, other)
    if (other:get_type() == "enemy" and other:get_breed() == "bubble_red") or other:get_type() == "hero" then
      -- Activate the alter.
      if other:get_distance(map:get_hero()) < 200 and not creating_fire then
        creating_fire = true
        map:create_enemy({ breed = "flame_red", x = "1120", y = "69", layer = 1, direction = 0 })
        sol.timer.start(map, 5000, function() creating_fire = false end)
      end
    end
  end)
end

function sensor_fairy_speak:on_activated()
  game:set_dialog_style("default")
  if game:get_value("i1608") == 1 then
    game:start_dialog("great_fairy.1")
  elseif game:get_value("i1608") == 2 then
    game:start_dialog("great_fairy.2")
  elseif game:get_value("i1608") == 3 then
    game:start_dialog("great_fairy.3")
  elseif game:get_value("i1608") == 4 then
    game:start_dialog("great_fairy.4")
  elseif game:get_value("i1608") == 5 then
    game:start_dialog("great_fairy.5.north", function()
      game:set_value("i1608", 6)
      hero:start_treasure("sword", 3)
    end)
  elseif game:get_value("i1608") == 6 then
    game:start_dialog("great_fairy.6")
  else
    game:start_dialog("great_fairy.0.north", function()
      game:set_value("i1608", 1)
    end)
  end
  sensor_fairy_speak:set_enabled(false)
end

function sensor_fairy_room:on_activated()
  map:open_doors("door_fairy")
  game:set_value("b1200", true)
end

function switch_rust_1:on_activated()
  skull_1:set_enabled(false)
end

function switch_rust_2:on_activated()
  skull_2:set_enabled(false)
end

function switch_rust_2:on_inactivated()
  skull_2:set_enabled(true)
end