local map = ...
local game = map:get_game()

---------------------------------------------
-- Dungeon 7: Tower of the Winds (Floor 6) --
---------------------------------------------

function map:on_started(destination)
  if not game:get_value("b1166") then
    miniboss_grim_creeper:set_enabled(false)
    miniboss_warp:set_enabled(false)
    map:open_doors("door_key2_2")
    switch_2:set_enabled(false)
  else
    map:set_entities_enabled("stairs", true)
  end
  if not game:get_value("b1178") then
    block_1:set_enabled(false)
    block_2:set_enabled(false)
    hook_1:set_enabled(false)
    hook_2:set_enabled(false)
  else
    switch_1:set_activated(true)
    switch_2:set_activated(true)
  end
  if not game:get_value("b1161") then chest_map:set_enabled(false) end
end

function switch_1:on_activated()
  map:move_camera(448, 325, 250, function()
    block_1:set_enabled(true)
    hook_1:set_enabled(true)
  end, 500, 500)
  if switch_2:is_activated() then game:set_value("b1178", true) end
end

function switch_2:on_activated()
  map:move_camera(464, 229, 250, function()
    block_2:set_enabled(true)
    hook_2:set_enabled(true)
  end, 500, 500)
  if switch_1:is_activated() then game:set_value("b1178", true) end
end

function sensor_miniboss:on_activated()
  if miniboss_grim_creeper ~= nil then
    map:close_doors("door_key2_2")
    miniboss_grim_creeper:set_enabled(true)
    sol.audio.play_music("miniboss")
  end
end

if miniboss_grim_creeper ~= nil then
  function miniboss_grim_creeper:on_dead()
    map:open_doors("door_key2")
    sol.audio.play_sound("boss_killed")
    switch_2:set_enabled(true)
    chest_map:set_enabled(true)
    miniboss_warp:set_enabled(true)
    map:set_entities_enabled("stairs", true)
    sol.timer.start(1000, function()
      sol.audio.play_music("temple_wind")
    end)
  end
end