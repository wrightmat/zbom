local map = ...
local game = map:get_game()

--------------------------------------
-- Dungeon 4: Mountaintop Mausoleum --
--------------------------------------

if game:get_value("i1029") == nil then game:set_value("i1029", 0) end

if game:has_item("lamp") then
 lantern_overlay = sol.surface.create("entities/dark.png")
else
  game:start_dialog("_cannot_see_need_lamp")
  lantern_overlay = sol.surface.create(640,480)
  lantern_overlay:set_opacity(0.96 * 255)
  lantern_overlay:fill_color{0, 0, 0}
end
if game:get_value("b1117") and lantern_overlay then
  lantern_overlay:clear()
end

function map:on_started(destination)
  if game:get_value("i1029") <= 4 then
    npc_goron_ghost:remove()
  elseif game:get_value("i1029") == 5 then
    sol.audio.play_sound("ghost")
    local m = sol.movement.create("target")
    m:set_speed(24)
    m:start(npc_goron_ghost)
  elseif game:get_value("i1029") >= 6 then
    dampeh_1:remove()
    dampeh_2:remove()
    npc_goron_ghost:remove()
    npc_dampeh:remove()
  end
  map:set_doors_open("door_miniboss")
  chest_alchemy:set_enabled(false)
  if not game:get_value("b1108") then chest_big_key:set_enabled(false) end
  if not game:get_value("b1102") then chest_key_3:set_enabled(false) end
  if not game:get_value("b1103") then chest_key_4:set_enabled(false) end
  if not game:get_value("b1119") then chest_rupees:set_enabled(false) end
  if not game:get_value("b1118") then boss_heart:set_enabled(false) end
  if not game:get_value("b1117") then chest_book:set_enabled(false) end
  if not game:get_value("b1105") then chest_compass:set_enabled(false) end
  if not game:get_value("b1106") then chest_map:set_enabled(false) end
  if not game:get_value("b1107") then miniboss_arrghus:set_enabled(false) end
  -- Dodongos appear after the boss is defeated
  if not game:get_value("b1110") then
    boss_vire:set_enabled(false)
    map:set_entities_enabled("dodongo", false)
  else
    if npc_dampeh ~= nil then npc_dampeh:remove() end
  end
  -- Lantern slowly drains magic here so you're forced to find ways to refill magic
  magic_deplete = sol.timer.start(map, 5000, function()
    if game:get_magic() > 1 then game:remove_magic(1) end
    return true
  end)
end

function map:on_obtained_treasure(treasure_item, treasure_variant, treasure_savegame_variable)
  if treasure_name == book_mudora and treasure_variant == 3 then
    game:set_dungeon_finished(4)
    game:set_value("i1029", 6)
  end
end

function npc_dampeh:on_interaction()
  if game:get_value("i1029") == 5 then
    game:start_dialog("dampeh.1.mausoleum", function()
      npc_dampeh:get_sprite():set_animation("walking")
      local m = sol.movement.create("target")
      m:set_target(232, 1712)
      m:set_speed(16)
      m:start(npc_dampeh, function()
	npc_dampeh:remove()
	dampeh_1:remove()
	dampeh_2:remove()
        game:set_value("i1029", 6)
        game:start_dialog("osgor.2.mausoleum")
      end)
    end)
  else
    game:start_dialog("dampeh.0.mausoleum")
  end
end

function sensor_miniboss:on_activated()
  if miniboss_arrghus ~= nil then
    map:close_doors("door_miniboss")
    miniboss_arrghus:set_enabled(true)
    sol.audio.play_music("boss")
  end
end

if miniboss_arrghus ~= nil then
 function miniboss_arrghus:on_dead()
  map:open_doors("door_miniboss")
  sol.audio.play_sound("boss_killed")
  sol.timer.start(2000, function()
    chest_big_key:set_enabled(true)
    sol.audio.play_sound("chest_appears")
  end)
  sol.audio.play_music("temple_mausoleum")
 end
end

function sensor_boss:on_activated()
  if boss_vire ~= nil then
    map:close_doors("door_boss")
    boss_vire:set_enabled(true)
    sol.audio.play_music("boss")
  end
end

if boss_vire ~= nil then
 function boss_vire:on_dead()
  map:open_doors("door_boss")
  sol.audio.play_sound("boss_killed")
  if boss_heart ~= nil then
    boss_heart:get_sprite():fade_in(30, function()
      boss_heart:set_enabled(true)
    end)
  end
  chest_book:set_enabled(true)
  sol.audio.play_sound("chest_appears")
  sol.audio.play_music("temple_mausoleum")
  sol.timer.start(2000, function()
    game:start_dialog("_mausoleum_outro", function()
      lantern_overlay:fade_out(50)
      lantern_overlay:clear()
      map:set_entities_enabled("dodongo", true)
    end)
  end)
 end
end

function door_key2_1:on_opened()
  map:set_doors_open("door_shutter_key2")
end
function door_key1_1:on_opened()
  map:set_doors_open("door_shutter_key2")
end

function map:on_update()
  if lantern_overlay and game:get_magic() <= 0 then
    lantern_overlay = nil
  end
end

for enemy in map:get_entities("tektite") do
  enemy.on_dead = function()
    if not map:has_entities("tektite_key3") and not game:get_value("b1102") then
      chest_key_3:set_enabled(true)
      sol.audio.play_sound("chest_appears")
    end
    if not map:has_entities("tektite_key4") and not game:get_value("b1103") then
      chest_key_4:set_enabled(true)
      sol.audio.play_sound("chest_appears")
    end
    if not map:has_entities("tektite_map") and not game:get_value("b1106") then
      chest_map:set_enabled(true)
      sol.audio.play_sound("chest_appears")
    end
    if not map:has_entities("tektite_alchemy") then
      chest_alchemy:set_enabled(true)
      sol.audio.play_sound("chest_appears")
    end
  end
end

for enemy in map:get_entities("keese") do
  enemy.on_dead = function()
    if not map:has_entities("keese_rupees") and not game:get_value("b1119") then
      chest_rupees:set_enabled(true)
      bridge_rupees:set_enabled(true)
      sol.audio.play_sound("chest_appears")
    end
  end
end

for enemy in map:get_entities("dodongo") do
  enemy.on_dead = function()
    if not map:has_entities("dodongo_compass") and not game:get_value("b1105") then
      chest_compass:set_enabled(true)
      sol.audio.play_sound("chest_appears")
    end
  end
end

function game:on_map_changed(map)
  function map:on_draw(dst_surface)
    local screen_width, screen_height = dst_surface:get_size()
    local camera_x, camera_y = map:get_camera_position()

    -- Draw the lights eminating from the statues
    --local s1x, s1y, s1l = statue_1:get_position()
    --light_overlay = sol.surface.create("entities/light.png")
    --local x = 320 - s1x + camera_x
    --local y = 240 - s1y + camera_y
    --light_overlay:draw_region(x, y, screen_width, screen_height, dst_surface)

    -- Draw the lantern light that follows the hero
    if lantern_overlay then
      local hero = map:get_entity("hero")
      local hero_x, hero_y = hero:get_center_position()
      local x = 320 - hero_x + camera_x
      local y = 240 - hero_y + camera_y
      lantern_overlay:draw_region(x, y, screen_width, screen_height, dst_surface)
    else
      lantern_overlay = sol.surface.create(640,480)
      lantern_overlay:set_opacity(0.9 * 255)
      lantern_overlay:fill_color{0, 0, 0}
      local hero = map:get_entity("hero")
      local hero_x, hero_y = hero:get_center_position()
      local camera_x, camera_y = map:get_camera_position()
      local x = 320 - hero_x + camera_x
      local y = 240 - hero_y + camera_y
      lantern_overlay:draw_region(x, y, screen_width, screen_height, dst_surface)
    end
  end
end
