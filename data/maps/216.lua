local map = ...
local game = map:get_game()
local door_timer = nil

---------------------------------------------
-- Dungeon 7: Tower of the Winds (Floor 7) --
---------------------------------------------

function map:on_started(destination)
  map:set_doors_open("door_statues")
end

function switch_door:on_activated()
  map:move_camera(232, 368, 250, function()
    map:open_doors("door_shutter")
  end, 500, 500)
end

function sensor_door_close:on_activated()
  if map:get_entity("door_statues"):is_open() then
    eye_statue_1:set_enabled(false)
    eye_statue_2:set_enabled(true)
    map:close_doors("door_statues")
  end
end

function sensor_door_open:on_activated()
  if not map:get_entity("door_statues"):is_open() then
    eye_statue_2:set_enabled(false)
    eye_statue_1:set_enabled(true)
    map:open_doors("door_statues")
  end
end