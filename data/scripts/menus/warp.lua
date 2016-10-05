local game = ...
local warp_menu = {}  -- The warp menu.
local initial_point
local initial_y = 10
local initial_volume 
local index
local hero_x, hero_y
local matched = {}

-- Warp point name, Companion point, Warp to map, Coordinate x on minimap, Coordinate y on minimap, Name of warp.
warp_points = {         -- Intentionally Global!
  b1500 = { "b1501", "133", 166, 102, "Old Kasuto" },     -- Patch at Hidden Village (G8)
  b1501 = { "b1500", "46", 178, 220, "Hidden Village" },  -- Patch at Old Kasuto (L5)
  b1502 = { "b1503", "51", 90, 194, "Kakariko City" },
  b1503 = { "b1502", "11", 162, 372, "Ordon Village" },
  b1504 = { "b1505", "72", 2, 228, "Gerudo Camp" },
  b1505 = { "b1504", "66", 208, 178, "Goron City" },
  b1506 = { "b1507", "82", 50, 346, "Beach" },
  b1507 = { "b1506", "37", 218, 266, "Lost Woods" },
  b1508 = { "b1509", "60", 4, 180, "Snowpeak" },
  b1509 = { "b1508", "88", 15, 25, "Calatia Peaks" }, 
  b1510 = { "b1511", "56", 160, 150, "Septen Heights" },
  b1511 = { "b1510", "139", 178, 126, "Three Eye Rock" },
  b1512 = { "b1513", "57", 184, 150, "Zora's Domain" },
  b1513 = { "b1512", "93", 34, 40, "Ruto Town" },
  b1514 = { "b1515", "34", 120, 258, "Lake Hylia" },
  b1515 = { "b1514", "13", 210, 365, "Floria Peninsula" }
}

function game:on_warp_started(point)
  initial_point = point
  if not sol.menu.is_started(warp_menu) then sol.menu.start(game, warp_menu) end
end

function warp_menu:on_started()
  game.hud:set_enabled(false)
  game.hud:set_enabled(true)  -- Refresh the HUD so it stays on top of the menu.
  self.hero_head_sprite = sol.sprite.create("menus/hero_head")
  self.hero_head_sprite:set_animation("tunic" .. game:get_item("tunic"):get_variant())
  self.background_surfaces = sol.surface.create("pause_submenus.png", true)
  self.background_surfaces:set_opacity(192)
  self.cursor_sprite = sol.sprite.create("menus/pause_cursor")
  local menu_font, menu_font_size = sol.language.get_menu_font()
  self.caption_text_1 = sol.text_surface.create{
    horizontal_alignment = "center",
    vertical_alignment = "middle",
    font = menu_font,
    font_size = menu_font_size,
  }
  self.caption_text_2 = sol.text_surface.create{
    horizontal_alignment = "center",
    vertical_alignment = "middle",
    font = menu_font,
    font_size = menu_font_size,
  }

  -- Show a world map.
  self.caption_text_1:set_text(sol.language.get_string("map.caption.warp"))
  self.outside_world_minimap_size = { width = 225, height = 399 }
  self.world_minimap_img = sol.surface.create("menus/warp_map.png")
  self.world_minimap_movement = nil
  self.world_minimap_visible_xy = {x = 0, y = 0 }

  -- Initialize the cursor and scroll map to initial point.
  for k, v in pairs(warp_points) do
    if k == initial_point then
      index = v[1]
      self:set_cursor_position(v[3], v[4])
      if v[4] >= 133 then initial_y = v[4] - 133 + 10 end
      self.world_minimap_visible_xy = {x = 0, y = initial_y }
    end
  end

  -- Build new table just for matched points.
  for k, v in pairs(warp_points) do
    if game:get_value(v[1]) then table.insert(matched, v[1]) end
  end

  -- Ensure the hero can't move and the HUD is correct.
  game:get_map():get_hero():freeze()
  game.hud.elements[10].surface:set_opacity(128) --item_icon_1
  game.hud.elements[11].surface:set_opacity(128) --item_icon_2
  game.hud.elements[12].surface:set_opacity(128) --attack_icon
  game.hud.elements[9]:on_menu_opened() -- pause_icon

  -- Lower the volume (so ocarina sound can be heard when point selected).
  initial_volume = sol.audio.get_music_volume()
  sol.audio.set_music_volume(initial_volume/3)
end

function warp_menu:on_command_pressed(command)
  if command == "left" or command == "up" or command == "right" or command == "down" then
    self:next_warp_point()
    handled = true
  elseif command == "action" then
    for k, v in pairs(warp_points) do
      if v[1] == index and game:get_value(v[1]) then
        game:start_dialog("warp.to_"..v[2], function(answer)
          if answer == 1 then
            sol.menu.stop(warp_menu)
            game:get_map():get_hero():set_animation("ocarina")
            sol.audio.play_sound("ocarina_wind")
            game:get_map():get_entity("hero"):teleport(v[2], "ocarina_warp", "fade")
          end
        end)
      end
    end
  elseif command == "pause" then
    sol.menu.stop(warp_menu)
  end

  return true
end

function warp_menu:next_warp_point()
  local matched_index = 1

  -- Move cursor and scroll map to new warp point.
  for k, v in ipairs(matched) do
    if k == matched_index then
      index = v
      for k, v in pairs(warp_points) do
        if v[1] == index then
          self:set_cursor_position(v[3], v[4])
          if v[4] >= 133 then initial_y = v[4] - 133 + 10 else initial_y = 0 end
          self.world_minimap_visible_xy = {x = 0, y = initial_y }
        end
      end
      table.remove(matched, matched_index)
    end
  end

  if table.getn(matched) == 0 then
    -- Re-build table for matched points when it's been looped through.
    for k, v in pairs(warp_points) do
      if game:get_value(v[1]) then table.insert(matched, v[1]) end
    end
  end
end

function warp_menu:set_cursor_position(x, y)
  self.cursor_x = x
  self.cursor_y = y
  if y > 133 then
    if y < 399 then self.world_minimap_visible_xy.y = y - 51 else self.world_minimap_visible_xy.y = 399 end
  end

  -- Update the caption text. Only show it if that point has been discovered.
  for k, v in pairs(warp_points) do
    if v[3] == self.cursor_x and v[4] == self.cursor_y and game:get_value(v[1]) then
      self.caption_text_2:set_text(v[5])
      game:set_custom_command_effect("action", "validate")
    end
  end
end

function warp_menu:on_draw(dst_surface)
  -- Draw background.
  local width, height = dst_surface:get_size()
  self.background_surfaces:draw_region(320, 0, 320, 240, dst_surface, (width - 320) / 2, (height - 240) / 2)

  -- Draw caption.
  local width, height = dst_surface:get_size()
  self.caption_text_1:draw(dst_surface, width / 2, height / 2 + 83)
  self.caption_text_2:draw(dst_surface, width / 2, height / 2 + 95)

  -- Draw the minimap.
  self.world_minimap_img:draw_region(self.world_minimap_visible_xy.x, self.world_minimap_visible_xy.y, 255, 133, dst_surface, 48, 59)

  -- Draw the warp points.
  for k, v in pairs(warp_points) do
    if game:get_value(v[1]) then -- Only those that have been discovered are shown.
      local point_visible_y = v[4] - self.world_minimap_visible_xy.y
      if point_visible_y >= 10 and point_visible_y <= 133 then self.hero_head_sprite:draw(dst_surface, v[3] + 40, point_visible_y + 51) end
    end
  end

  -- Draw the cursor.
  if self.cursor_y >= (10 + self.world_minimap_visible_xy.y) and self.cursor_y <= (133 + self.world_minimap_visible_xy.y) then
    self.cursor_sprite:draw(dst_surface, self.cursor_x + 48, self.cursor_y + 55 - self.world_minimap_visible_xy.y)
  end
end

function warp_menu:on_finished()
  sol.timer.start(game, 1500, function() sol.audio.set_music_volume(initial_volume) end)
  game:get_map():get_hero():unfreeze()
  game:set_custom_command_effect("pause", nil)
  game:set_custom_command_effect("action", nil)
  game.hud.elements[10].surface:set_opacity(255) --item_icon_1
  game.hud.elements[11].surface:set_opacity(255) --item_icon_2
  game.hud.elements[12].surface:set_opacity(255) --attack_icon
  game.hud.elements[9]:on_menu_closed() -- pause_icon
end