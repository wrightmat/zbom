local map = ...
local game = map:get_game()
local woods_overlay = nil

--------------------------------------------------------------
-- Outside World (Lost Woods - Interloper Sanctum Entrance) --
--------------------------------------------------------------

woods_overlay = sol.surface.create("effects/woods.png")
woods_overlay:set_opacity(255)

local function send_hero(from_sensor, to_sensor)
  local hero_x, hero_y = hero:get_position()
  local from_sensor_x, from_sensor_y = from_sensor:get_position()
  local to_sensor_x, to_sensor_y = to_sensor:get_position()

  hero_x = hero_x + to_sensor_x - from_sensor_x
  hero_y = hero_y + to_sensor_y - from_sensor_y
  hero:set_position(hero_x, hero_y)
end

function sensor_a1:on_activated()
  send_hero(sensor_a1, sensor_a2)
end

function sensor_b1:on_activated()
  send_hero(sensor_b1, sensor_b2)
end

function sensor_c1:on_activated()
  send_hero(sensor_c1, sensor_c2)
end

function map:on_started()
  if game:get_value("i1807") == 7 then
    sensor_a1:set_enabled(false)
    sensor_b1:set_enabled(false)
    sensor_c1:set_enabled(false)
    tree_temple:set_enabled(false)
    obstacle_temple:set_enabled(false)
    
    if not game:get_value("b1179") then
      game:start_dialog("deku.2.lost_woods_first", function() game:set_value("b1179", true) end)
    end
  end
  if game:get_value("b1191") then
    signpost_credits:set_enabled(true)
  else
    signpost_credits:set_enabled(false)
  end
end

function npc_deku_1:on_interaction()
  if game:get_value("i1807") == 7 then
    if math.random(4) == 1 then
      game:start_dialog("deku.2.lost_woods")
    else
      game:start_dialog("deku.3.lost_woods")
    end
  else
    game:start_dialog("deku.1.lost_woods")
  end
end

function map:on_draw(dst_surface)
  if woods_overlay ~= nil then
    woods_overlay:draw(dst_surface)
  end
end

function map:on_finished()
  if woods_overlay then woods_overlay = nil end
end

function signpost_credits:on_interaction()
  game:start_dialog("sign.credits", function(answer)
    if answer == 1 then game:on_credits_started() end
  end)
end