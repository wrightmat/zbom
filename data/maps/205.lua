local map ...
local game = map:get_game()

--------------------------------------
-- Dungeon 4: Mountaintop Mausoleum --
--------------------------------------

if game:has_item("lamp") then
  lantern_overlay = sol.surface.create("entities/dark.png")
else
  game:start_dialog("_cannot_see_need_lamp")
  lantern_overlay = sol.surface.create(640,480)
  lantern_overlay:set_opacity(0.96 * 255)
  lantern_overlay:fill_color{0, 0, 0}
end

function map:on_started(destination)
  miniboss_arrghus:set_enabled(false)
  map:set_doors_open("door_miniboss")
  chest_big_key:set_enabled(false)
  chest_book:set_enabled(false)
end

function npc_dampeh:on_interaction()
  game:start_dialog("dampeh.0.mausoleum")
end

function sensor_miniboss:on_activated()
  map:close_doors("door_miniboss")
  miniboss_arrghus:set_enabled(true)
end

function miniboss_arrghus:on_dead()
  map:open_doors("door_miniboss")
  chest_big_key:set_enabled(true)
end

function door_key2_1:on_opened()
  -- If the key 2 door is opened before the key 1 door, open
  -- the shutter to the other key so the player's not trapped!
  map:set_doors_open("door_shutter_key2")
end

function game:on_map_changed(map)
  function map:on_draw(dst_surface)
    -- Draw the lights eminating from the statues first
    local light_overlay = sol.surface.create("entities/dark.png")
    local s1x, s1y, s1l = statue_1:get_position()
    light_overlay:draw(dst_surface, s1x, s1y)
    -- Then draw the lantern light that follows the hero
    if lantern_overlay then
      local screen_width, screen_height = dst_surface:get_size()
      local hero = map:get_entity("hero")
      local hero_x, hero_y = hero:get_center_position()
      local camera_x, camera_y = map:get_camera_position()
      local x = 320 - hero_x + camera_x
      local y = 240 - hero_y + camera_y
      lantern_overlay:draw_region(x, y, screen_width, screen_height, dst_surface)
      -- Lantern slowly drains magic here so you're forced to find ways to refill magic
      game:remove_magic(1)
    end
  end
end
