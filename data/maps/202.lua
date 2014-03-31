local map = ...
local game = map:get_game()

--------------------------------
-- Dungeon 1: Hyrulean Sewers --
--------------------------------

if game:has_item("lamp") then
  lantern_overlay = sol.surface.create("entities/dark.png")
else
  game:start_dialog("_cannot_see_need_lamp")
  lantern_overlay = sol.surface.create(640,480)
  lantern_overlay:set_opacity(0.98 * 255)
  lantern_overlay:fill_color{0, 0, 0}
end

function map:on_started(destination)
  if game:get_value("i1027") <= 4 then
    tentacle_sword_1:set_enabled(false)
    tentacle_sword_2:set_enabled(false)
    tentacle_sword_3:set_enabled(false)
  end
  if not game:get_value("b2000") then
    chest_sword:set_enabled(false)
  end
  if not game:get_value("b1040") then
    chest_key_1:set_enabled(false)
  end
  if not game:get_value("b1041") then
    chest_key_2:set_enabled(false)
  end
end

function switch_sword:on_activated()
  chest_sword:set_enabled(true)
  sol.audio.play_sound("chest_appears")
end

function switch_arrow_key_1:on_activated()
  chest_key_1:set_enabled(true)
  sol.audio.play_sound("chest_appears")
end

function switch_key_2_1:on_activated()
  if switch_key_2_2:is_activated(true) then
    chest_key_2:set_enabled(true)
    sol.audio.play_sound("chest_appears")
  end
end

function switch_key_2_2:on_activated()
  if switch_key_2_1:is_activated(true) then
    chest_key_2:set_enabled(true)
    sol.audio.play_sound("secret")
  end
end

--function sensor_open_door_1:on_activated()
--  door_1:set_open(true)
--  sol.audio.play_sound("door_open")
--end

--function sensor_close_door_1:on_activated()
--  door_1:set_open(false)
--  sol.audio.play_sound("door_closed")
--end

for enemy in map:get_entities("tentacle_orig") do
  enemy.on_dead = function()
    map:open_doors("door_2")
    map:open_doors("door_3")
  end
end

for enemy in map:get_entities("enemy_chuchu") do
  enemy.on_dead = function()
    map:open_doors("door_9")
  end
end

function map:on_obtained_treasure(treasure_item, treasure_variant, treasure_savegame_variable)
  if tentacle_sword_1 ~= nil then tentacle_sword_1:set_enabled(true) end
  if tentacle_sword_2 ~= nil then tentacle_sword_2:set_enabled(true) end
  if tentacle_sword_3 ~= nil then tentacle_sword_3:set_enabled(true) end
end

function game:on_map_changed(map)
  function map:on_draw(dst_surface)
    if lantern_overlay then
      local screen_width, screen_height = dst_surface:get_size()
      local hero = map:get_entity("hero")
      local hero_x, hero_y = hero:get_center_position()
      local camera_x, camera_y = map:get_camera_position()
      local x = 320 - hero_x + camera_x
      local y = 240 - hero_y + camera_y
      lantern_overlay:draw_region(x, y, screen_width, screen_height, dst_surface)
    end
  end
end
