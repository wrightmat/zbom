local map = ...
local game = map:get_game()
local warned = false

--------------------------------------
-- Dungeon 4: Mountaintop Mausoleum --
--------------------------------------

if game:get_value("i1029") == nil then game:set_value("i1029", 0) end
local dark_overlay = nil
local lantern_overlay = nil

if game:has_item("lamp") then
  if lantern_overlay == nil and game:get_magic() > 0 then
    lantern_overlay = sol.surface.create("entities/dark.png")
  else
    dark_overlay = sol.surface.create(640,480)
    dark_overlay:set_opacity(0.9 * 255)
    dark_overlay:fill_color{0, 0, 0}
  end
else
  game:start_dialog("_cannot_see_need_lamp")
  dark_overlay = sol.surface.create(640,480)
  dark_overlay:set_opacity(0.9 * 255)
  dark_overlay:fill_color{0, 0, 0}
end
if game:get_value("b1117") then
  if lantern_overlay then lantern_overlay:clear() end
  if dark_overlay then dark_overlay:clear() end
end

function map:on_started(destination)
  if game:get_value("i1029") <= 4 then
    npc_goron_ghost:remove()
  elseif game:get_value("i1029") == 5 then
    sol.audio.play_sound("ghost")
    local m = sol.movement.create("target")
    m:set_speed(32)
    m:start(npc_goron_ghost)
  elseif game:get_value("i1029") >= 6 then
    dampeh_1:remove()
    dampeh_2:remove()
    npc_goron_ghost:remove()
    if npc_dampeh ~= nil then npc_dampeh:remove() end
  end

  map:set_doors_open("door_miniboss")
  if not game:get_value("b1102") then chest_key_3:set_enabled(false) end
  if not game:get_value("b1103") then chest_key_4:set_enabled(false) end
  if not game:get_value("b1105") then chest_compass:set_enabled(false) end
  if not game:get_value("b1106") then chest_map:set_enabled(false) end
  if not game:get_value("b1107") then miniboss_arrghus:set_enabled(false) end
  if not game:get_value("b1108") then chest_big_key:set_enabled(false) end
  if not game:get_value("b1110") then
    vire:set_enabled(false)
    boss_vire_sorceror:set_enabled(false)
    -- Dodongos appear after the boss is defeated.
    map:set_entities_enabled("dodongo", false)
  else
    if npc_dampeh ~= nil then npc_dampeh:remove() end
  end
  if not game:get_value("b1111") then chest_alchemy:set_enabled(false) end
  if game:get_value("b1113") or game:get_value("b1114") then map:set_doors_open("door_shutter_key2") end
  if not game:get_value("b1117") then chest_book:set_enabled(false) end
  if not game:get_value("b1118") then boss_heart:set_enabled(false) end
  if not game:get_value("b1119") then chest_rupees:set_enabled(false) end

  -- Lantern slowly drains magic here so you're forced to find ways to refill magic.
  magic_deplete = sol.timer.start(map, 5000, function()
    if not game:get_value("b1117") then
      game:remove_magic(1)
      return true
    end
  end)
end

function npc_dampeh:on_interaction()
  if game:get_value("i1029") == 5 then
    game:start_dialog("dampeh.1.mausoleum", function()
      game:set_value("i1029", 6)
      npc_dampeh:get_sprite():set_animation("walking")
      local m = sol.movement.create("target")
      m:set_target(232, 1712)
      m:set_speed(24)
      m:start(npc_dampeh, function()
        npc_dampeh:remove()
        dampeh_1:remove()
        dampeh_2:remove()
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
  if boss_vire_sorceror ~= nil then
    map:close_doors("door_boss")
    vire:set_enabled(true)
    boss_vire_sorceror:set_enabled(true)
    sol.audio.play_music("boss")
  end
end

if boss_vire_sorceror ~= nil then
 function boss_vire_sorceror:on_dead()
  map:open_doors("door_boss")
  sol.audio.play_sound("boss_killed")
  boss_heart:set_enabled(true)
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
  if game:get_magic() <= 0 and not game:get_value("b1117") then
    if lantern_overlay then
      lantern_overlay:clear()
      lantern_overlay = nil
      if dark_overlay == nil then
        dark_overlay = sol.surface.create(640,480)
        dark_overlay:set_opacity(0.9 * 255)
        dark_overlay:fill_color{0, 0, 0}
      end
    elseif not warned then
      game:start_dialog("_cannot_see_need_magic")
      warned = true
    end
  else
    if game:has_item("lamp") and lantern_overlay == nil then lantern_overlay = sol.surface.create("entities/dark.png") end
  end
end

for enemy in map:get_entities("tektite_key3") do
  enemy.on_dead = function()
    if not map:has_entities("tektite_key3") and not game:get_value("b1102") then
      chest_key_3:set_enabled(true)
      sol.audio.play_sound("chest_appears")
    end
  end
end
for enemy in map:get_entities("tektite_key4") do
  enemy.on_dead = function()
    if not map:has_entities("tektite_key4") and not game:get_value("b1103") then
      chest_key_4:set_enabled(true)
      sol.audio.play_sound("chest_appears")
    end
  end
end
for enemy in map:get_entities("tektite_map") do
  enemy.on_dead = function()
    if not map:has_entities("tektite_map") and not game:get_value("b1106") then
      map:move_camera(1304, 861, 250, function()
        chest_map:set_enabled(true)
        sol.audio.play_sound("chest_appears")
      end, 250, 250)
    end
  end
end
for enemy in map:get_entities("tektite_compass") do
  enemy.on_dead = function()
    if not map:has_entities("tektite_compass") and not game:get_value("b1105") then
      map:move_camera(1304, 1149, 250, function()
        chest_compass:set_enabled(true)
        sol.audio.play_sound("chest_appears")
      end, 250, 250)
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
    if not map:has_entities("dodongo_alchemy") and not game:get_value("b1111") then
      chest_alchemy:set_enabled(true)
      sol.audio.play_sound("chest_appears")
    end
  end
end

function map:on_draw(dst_surface)
  local screen_width, screen_height = dst_surface:get_size()
  local camera_x, camera_y = map:get_camera():get_position()

  -- Draw the lantern light that follows the hero.
  if lantern_overlay then
    local hero = map:get_entity("hero")
    local hero_x, hero_y = hero:get_center_position()
    local x = 320 - hero_x + camera_x
    local y = 240 - hero_y + camera_y
    lantern_overlay:draw_region(x, y, screen_width, screen_height, dst_surface)
  elseif dark_overlay then
    dark_overlay:draw(dst_surface, x, y)
  end
end

function map:on_finished()
  if lantern_overlay then
    lantern_overlay:fade_out()
    lantern_overlay = nil
  end
  if dark_overlay then
    dark_overlay:fade_out()
    dark_overlay = nil
  end
end

function chest_book:on_opened(item, variant, savegame_variable)
  -- Dynamically determine book variant to give, since dungeons can be done in any order.
  local book_variant = game:get_item("book_mudora"):get_variant() + 1
  map:get_hero():start_treasure("book_mudora", book_variant)
  game:set_dungeon_finished(4)
  game:set_value("i1029", 6)
  game:set_value("b1117", true) -- This value varies depending on the dungeon (chest save value)
end