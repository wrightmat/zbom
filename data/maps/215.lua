local map = ...
local game = map:get_game()

---------------------------------------------
-- Dungeon 7: Tower of the Winds (Floor 6) --
---------------------------------------------

function map:on_started(destination)
  if not game:get_value("b1166") then miniboss_grim_creeper:set_enabled(false) end
  block_1:set_enabled(false)
  block_2:set_enabled(false)
  switch_2:set_enabled(false) -- re-enabled after Grim Creeper defeat
  if not game:get_value("b1161") then chest_map:set_enabled(false) end
end

function switch_1:on_activated()
  block_1:set_enabled(true)
end

function switch_2:on_actived()
  block_2:set_enabled(true)
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
    sol.timer.start(1000, function()
      sol.audio.play_music("temple_wind")
    end)
  end
end