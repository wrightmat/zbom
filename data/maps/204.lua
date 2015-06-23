local map = ...
local game = map:get_game()

----------------------------------
-- Dungeon 3: Abandoned Pyramid --
----------------------------------

function map:on_started(destination)
  if not game:get_value("b1078") then
    miniboss_lanmola:set_enabled(false)
  else
    map:set_doors_open("door_miniboss_exit")
  end
  if game:get_value("b1090") then map:set_doors_open("door_shortcut") end
  if not game:get_value("b1079") then boss_manhandla:set_enabled(false) end
  if not game:get_value("b1087") then chest_room7_part:set_enabled(false) end
  if not game:get_value("b1070") then chest_room8_key:set_enabled(false) end
  if not game:get_value("b1071") then chest_room9_key:set_enabled(false) end
  if not game:get_value("b1073") then chest_room11_big:set_enabled(false) end
  if not game:get_value("b1077") then chest_room12_item:set_enabled(false) end
  if not game:get_value("b1076") then chest_room14_compass:set_enabled(false) end
  if not game:get_value("b1088") then chest_room16_part:set_enabled(false) end
  if not game:get_value("b1072") then chest_room17_key:set_enabled(false) end
  if not game:get_value("b1089") then chest_room18_part:set_enabled(false) end
  if not game:get_value("b1074") then boss_heart:set_enabled(false) end
  map:set_doors_open("door_miniboss_enter")
end

function sensor_pyramid_enter:on_activated()
  if not game:get_value("b1069") then
    game:start_dialog("pyramid_enter", function()
      game:set_value("b1069", 1)
    end)
  end
end

function sensor_save_ground:on_activated()
  hero:save_solid_ground()
end
function sensor_reset_ground:on_activated()
  hero:reset_solid_ground()
end
function sensor_save_ground_2:on_activated()
  hero:save_solid_ground()
end
function sensor_reset_ground_2:on_activated()
  hero:reset_solid_ground()
end
function sensor_save_ground_3:on_activated()
  hero:reset_solid_ground()
  hero:save_solid_ground()
end
function sensor_reset_ground_3:on_activated()
  hero:reset_solid_ground()
  hero:save_solid_ground()
end

function sensor_miniboss:on_activated()
  if not game:get_value("b1078") then
    map:close_doors("door_miniboss_enter")
    map:close_doors("door_miniboss_exit")
    miniboss_lanmola:set_enabled(true)
    sol.audio.play_music("miniboss")
  end
end

function sensor_boss:on_activated()
  if not game:get_value("b1079") then
    map:close_doors("door_boss")
    map:close_doors("door_boss_shutter")
    boss_manhandla:set_enabled(true)
    sol.audio.play_music("boss")
  end
end

function switch_room4:on_activated()
  map:move_camera(1816, 912, 250, function()
    map:open_doors("door_shutter_room4")
    sol.audio.play_sound("door_open")
  end, 500, 500)
end

function switch_room7_3:on_activated()
  if switch_room7_1:is_activated() and switch_room7_2:is_activated() then
    chest_room7_part:set_enabled(true)
    sol.audio.play_sound("chest_appears")
  end
end

function switch_shortcut:on_activated()
  game:set_value("b1090", true)
  map:open_doors("door_shortcut")
end

if miniboss_lanmola ~= nil then
 function miniboss_lanmola:on_dead()
  map:open_doors("door_miniboss_exit")
  map:open_doors("door_miniboss_enter")
  sol.audio.play_sound("boss_killed")
  sol.timer.start(2000, function()
    chest_room12_item:set_enabled(true)
    sol.audio.play_sound("chest_appears")
  end)
  sol.audio.play_music("temple_pyramid")
 end
end

if boss_manhandla ~= nil then
 function boss_manhandla:on_dead()
  map:open_doors("door_boss")
  map:open_doors("door_boss_shutter")
  sol.audio.play_sound("boss_killed")
  boss_heart:set_enabled(true)
  sol.audio.play_music("temple_pyramid")
 end
end

function switch_room9_arrow_1:on_activated()
  room9_pit:set_enabled(false)
  sol.audio.play_sound("secret")
end

function switch_room9_arrow_2:on_activated()
  map:open_doors("door_shutter_room9")
  sol.audio.play_sound("door_open")
end

function switch_room11_arrow_1:on_activated()
  switch_room11_arrow_1:set_locked(true)
  if switch_room11_arrow_2:is_activated() then
    room11_bridge:set_enabled(true)
    sol.audio.play_sound("secret")
  end
end
function switch_room11_arrow_2:on_activated()
  switch_room11_arrow_2:set_locked(true)
  if switch_room11_arrow_1:is_activated() then
    room11_bridge:set_enabled(true)
    sol.audio.play_sound("secret")
  end
end

function switch_room11_arrow_3:on_activated()
  switch_room11_arrow_3:set_locked(true)
  if switch_room11_arrow_4:is_activated() then
    chest_room11_big:set_enabled(true)
    sol.audio.play_sound("chest_appears")
  end
end
function switch_room11_arrow_4:on_activated()
  switch_room11_arrow_4:set_locked(true)
  if switch_room11_arrow_3:is_activated() then
    chest_room11_big:set_enabled(true)
    sol.audio.play_sound("chest_appears")
  end
end

function switch_room18_1:on_activated()
  if switch_room18_2:is_activated() and switch_room18_3:is_activated() and switch_room18_4:is_activated() and switch_room18_5:is_activated() then
    chest_room18_part:set_enabled(true)
    sol.audio.play_sound("chest_appears")
  end
end
function switch_room18_2:on_activated()
  if switch_room18_1:is_activated() and switch_room18_3:is_activated() and switch_room18_4:is_activated() and switch_room18_5:is_activated() then
    chest_room18_part:set_enabled(true)
    sol.audio.play_sound("chest_appears")
  end
end
function switch_room18_3:on_activated()
  if switch_room18_1:is_activated() and switch_room18_2:is_activated() and switch_room18_4:is_activated() and switch_room18_5:is_activated() then
    chest_room18_part:set_enabled(true)
    sol.audio.play_sound("chest_appears")
  end
end
function switch_room18_4:on_activated()
  if switch_room18_1:is_activated() and switch_room18_2:is_activated() and switch_room18_3:is_activated() and switch_room18_5:is_activated() then
    chest_room18_part:set_enabled(true)
    sol.audio.play_sound("chest_appears")
  end
end
function switch_room18_5:on_activated()
  if switch_room18_1:is_activated() and switch_room18_2:is_activated() and switch_room18_3:is_activated() and switch_room18_4:is_activated() then
    chest_room18_part:set_enabled(true)
    sol.audio.play_sound("chest_appears")
  end
end

for enemy in map:get_entities("gibdos") do
  enemy.on_dead = function()
    if not map:has_entities("gibdos_room8") and not game:get_value("b1070") then
      chest_room8_key:set_enabled(true)
      sol.audio.play_sound("chest_appears")
    end

    if not map:has_entities("gibdos_room9") and not map:has_entities("keese_room9") and not game:get_value("b1071") then
      chest_room9_key:set_enabled(true)
      sol.audio.play_sound("chest_appears")
    end

    if not map:has_entities("gibdos_room14") and not game:get_value("b1076") then
      chest_room14_compass:set_enabled(true)
      sol.audio.play_sound("chest_appears")
    end

    if not map:has_entities("gibdos_room16") and not game:get_value("b1088") then
      chest_room16_part:set_enabled(true)
      sol.audio.play_sound("chest_appears")
    end
  end
end

for enemy in map:get_entities("keese") do
  enemy.on_dead = function()
    if not map:has_entities("gibdos_room9") and not map:has_entities("keese_room9") and not game:get_value("b1071") then
      chest_room9_key:set_enabled(true)
      sol.audio.play_sound("chest_appears")
    end

    if not map:has_entities("keese_room17") and not game:get_value("b1072") then
      chest_room17_key:set_enabled(true)
      sol.audio.play_sound("chest_appears")
    end
  end
end

function map:on_obtained_treasure(item, variant, savegame_variable)
  if item:get_name() == "book_mudora" then
    game:set_dungeon_finished(3)
  end
end