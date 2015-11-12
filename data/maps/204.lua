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
  if not game:get_value("b1070") then chest_room10_key:set_enabled(false) end
  if not game:get_value("b1071") then chest_room11_key:set_enabled(false) end
  if not game:get_value("b1072") then chest_room20_key:set_enabled(false) end
  if not game:get_value("b1073") then chest_room13_big:set_enabled(false) end
  if not game:get_value("b1074") then boss_heart:set_enabled(false) end
  if not game:get_value("b1075") then chest_room17_map:set_enabled(false) end
  if not game:get_value("b1076") then chest_room7_compass:set_enabled(false) end
  if not game:get_value("b1077") and not game:get_value("b1078") then chest_room15_item:set_enabled(false) end
  if not game:get_value("b1079") then boss_manhandla:set_enabled(false) end
  if not game:get_value("b1087") then chest_room9_part:set_enabled(false) end
  if not game:get_value("b1088") then chest_room19_part:set_enabled(false) end
  if not game:get_value("b1089") then chest_room22_part:set_enabled(false) end
  if game:get_value("b1090") then map:set_doors_open("door_shortcut") end
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

function switch_room7:on_activated()
  chest_room7_compass:set_enabled(true)
  sol.audio.play_sound("chest_appears")
end

function switch_room9_3:on_activated()
  if switch_room9_1:is_activated() and switch_room9_2:is_activated() then
    chest_room9_part:set_enabled(true)
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
    chest_room15_item:set_enabled(true)
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

function switch_room11_arrow_1:on_activated()
  room11_pit:set_enabled(false)
  sol.audio.play_sound("secret")
end
function switch_room11_arrow_2:on_activated()
  map:open_doors("door_shutter_room11")
  sol.audio.play_sound("door_open")
end

function switch_room13_arrow_1:on_activated()
  switch_room13_arrow_1:set_locked(true)
  if switch_room13_arrow_2:is_activated() then
    room13_bridge:set_enabled(true)
    sol.audio.play_sound("secret")
  end
end
function switch_room13_arrow_2:on_activated()
  switch_room13_arrow_2:set_locked(true)
  if switch_room13_arrow_1:is_activated() then
    room13_bridge:set_enabled(true)
    sol.audio.play_sound("secret")
  end
end
function switch_room13_arrow_3:on_activated()
  switch_room13_arrow_3:set_locked(true)
  if switch_room13_arrow_4:is_activated() then
    chest_room13_big:set_enabled(true)
    sol.audio.play_sound("chest_appears")
  end
end
function switch_room13_arrow_4:on_activated()
  switch_room13_arrow_4:set_locked(true)
  if switch_room13_arrow_3:is_activated() then
    chest_room13_big:set_enabled(true)
    sol.audio.play_sound("chest_appears")
  end
end

function switch_room22_1:on_activated()
  if switch_room22_2:is_activated() and switch_room22_3:is_activated() and switch_room22_4:is_activated() and switch_room22_5:is_activated() then
    chest_room22_part:set_enabled(true)
    sol.audio.play_sound("chest_appears")
  end
end
function switch_room22_2:on_activated()
  if switch_room22_1:is_activated() and switch_room22_3:is_activated() and switch_room22_4:is_activated() and switch_room22_5:is_activated() then
    chest_room22_part:set_enabled(true)
    sol.audio.play_sound("chest_appears")
  end
end
function switch_room22_3:on_activated()
  if switch_room22_1:is_activated() and switch_room22_2:is_activated() and switch_room22_4:is_activated() and switch_room22_5:is_activated() then
    chest_room22_part:set_enabled(true)
    sol.audio.play_sound("chest_appears")
  end
end
function switch_room22_4:on_activated()
  if switch_room22_1:is_activated() and switch_room22_2:is_activated() and switch_room22_3:is_activated() and switch_room22_5:is_activated() then
    chest_room22_part:set_enabled(true)
    sol.audio.play_sound("chest_appears")
  end
end
function switch_room22_5:on_activated()
  if switch_room22_1:is_activated() and switch_room22_2:is_activated() and switch_room22_3:is_activated() and switch_room22_4:is_activated() then
    chest_room22_part:set_enabled(true)
    sol.audio.play_sound("chest_appears")
  end
end

for enemy in map:get_entities("gibdos") do
  enemy.on_dead = function()
    if not map:has_entities("gibdos_room10") and not game:get_value("b1070") then
      chest_room10_key:set_enabled(true)
      sol.audio.play_sound("chest_appears")
    end

    if not map:has_entities("gibdos_room11") and not map:has_entities("keese_room11") and not game:get_value("b1071") then
      chest_room11_key:set_enabled(true)
      sol.audio.play_sound("chest_appears")
    end

    if not map:has_entities("gibdos_room17") and not game:get_value("b1075") then
      chest_room17_map:set_enabled(true)
      sol.audio.play_sound("chest_appears")
    end

    if not map:has_entities("gibdos_room19") and not game:get_value("b1088") then
      chest_room19_part:set_enabled(true)
      sol.audio.play_sound("chest_appears")
    end
  end
end

for enemy in map:get_entities("keese") do
  enemy.on_dead = function()
    if not map:has_entities("gibdos_room11") and not map:has_entities("keese_room11") and not game:get_value("b1071") then
      chest_room11_key:set_enabled(true)
      sol.audio.play_sound("chest_appears")
    end

    if not map:has_entities("keese_room20") and not game:get_value("b1072") then
      chest_room20_key:set_enabled(true)
      sol.audio.play_sound("chest_appears")
    end
  end
end

function map:on_obtained_treasure(item, variant, savegame_variable)
  if item:get_name() == "book_mudora" then
    game:set_dungeon_finished(3)
  end
end

function chest_book:on_empty()
  --dynamically determine book variant to give, since dungeons can be done in any order
  local book_variant = game:get_item("book_mudora"):get_variant() + 1
  map:get_hero():start_treasure("book_mudora", book_variant)
end