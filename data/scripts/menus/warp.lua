local game = ...
local warp_menu = {}  -- The warp menu.
local initial_point
local initial_y = 10
local index

-- Warp point name, Companion point, Warp to map, Coordinate x on minimap, Coordinate y on minimap, Name of warp.
warp_points = {         -- Intentionally Global!
  b1500 = { "b1501", "133", 166, 102, "Old Kasuto" },
  b1501 = { "b1500", "46", 178, 220, "Hidden Village" },
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
  b1513 = { "b1512", "93", 34, 40, "Rito Town" },
  b1514 = { "b1515", "34", 120, 258, "Lake Hylia" },
  b1515 = { "b1514", "13", 210, 365, "Floria Peninsula" }
}

function game:on_warp_started(point)
  initial_point = point
  if not sol.menu.is_started(warp_menu) then sol.menu.start(game:get_map(), warp_menu) end
end

function warp_menu:on_started()
  game:get_map():get_hero():freeze()
  self.hero_head_sprite = sol.sprite.create("menus/hero_head")
  self.hero_head_sprite:set_animation("tunic" .. game:get_item("tunic"):get_variant())
  self.background_surfaces = sol.surface.create("pause_submenus.png", true)
  self.background_surfaces:set_opacity(192)
  self.cursor_sprite = sol.sprite.create("menus/pause_cursor")
  self.caption_text_1 = sol.text_surface.create{
    horizontal_alignment = "center",
    vertical_alignment = "middle",
    font = "fixed",
    font = menu_font,
    font_size = menu_font_size,
  }
  self.caption_text_2 = sol.text_surface.create{
    horizontal_alignment = "center",
    vertical_alignment = "middle",
    font = "fixed",
    font = menu_font,
    font_size = menu_font_size,
  }

  -- Show a world map.
  self.caption_text_1:set_text(sol.language.get_string("map.caption.warp"))
  self.outside_world_minimap_size = { width = 225, height = 399 }
  self.world_minimap_img = sol.surface.create("menus/warp_map.png")
  self.world_minimap_movement = nil

  -- Initialize the cursor and scroll map to initial point.
  for k, v in pairs(warp_points) do
    if k == initial_point then
      index = k
      self:set_cursor_position(v[3], v[4])
      if v[4] >= 133 then initial_y = v[4] - 133 + 10 else initial_y = 0 end
      self.world_minimap_visible_xy = {x = 0, y = initial_y }
    end
  end
end

function warp_menu:on_command_pressed(command)
  if command == "left" or command == "up" then
    self:previous_warp_point()
    handled = true
  elseif command == "right" or command == "down" then
    self:next_warp_point()
    handled = true
  elseif command == "action" or command == "attack" then
    for k, v in pairs(warp_points) do
      if k == index and game:get_value(v[1]) then
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
  if index == "b1500" then index = "b1501"
  elseif index == "b1501" then index = "b1502"
  elseif index == "b1502" then index = "b1503"
  elseif index == "b1503" then index = "b1504"
  elseif index == "b1504" then index = "b1505"
  elseif index == "b1505" then index = "b1506"
  elseif index == "b1506" then index = "b1507"
  elseif index == "b1507" then index = "b1508"
  elseif index == "b1508" then index = "b1509"
  elseif index == "b1509" then index = "b1510"
  elseif index == "b1510" then index = "b1511"
  elseif index == "b1511" then index = "b1512"
  elseif index == "b1512" then index = "b1513"
  elseif index == "b1513" then index = "b1514"
  elseif index == "b1514" then index = "b1515"
  elseif index == "b1515" then index = "b1500" end

  -- Move cursor and scroll map to new warp point.
  for k, v in pairs(warp_points) do
    if k == index and game:get_value(v[1]) then
      self:set_cursor_position(v[3], v[4])
      if v[4] >= 133 then initial_y = v[4] - 133 + 10 else initial_y = 0 end
      self.world_minimap_visible_xy = {x = 0, y = initial_y }
    end
  end
end

function warp_menu:previous_warp_point()
  if index == "b1500" then index = "b1515"
  elseif index == "b1501" then index = "b1500"
  elseif index == "b1502" then index = "b1501"
  elseif index == "b1503" then index = "b1502"
  elseif index == "b1504" then index = "b1503"
  elseif index == "b1505" then index = "b1504"
  elseif index == "b1506" then index = "b1505"
  elseif index == "b1507" then index = "b1506"
  elseif index == "b1508" then index = "b1507"
  elseif index == "b1509" then index = "b1508"
  elseif index == "b1510" then index = "b1509"
  elseif index == "b1511" then index = "b1510"
  elseif index == "b1512" then index = "b1511"
  elseif index == "b1513" then index = "b1512"
  elseif index == "b1514" then index = "b1513"
  elseif index == "b1515" then index = "b1514" end

  -- Move cursor and scroll map to new warp point.
  for k, v in pairs(warp_points) do
    if k == index and game:get_value(v[1]) then
      self:set_cursor_position(v[3], v[4])
      if v[4] >= 133 then initial_y = v[4] - 133 + 10 else initial_y = 0 end
      self.world_minimap_visible_xy = {x = 0, y = initial_y }
    end
  end
end

function warp_menu:set_cursor_position(x, y)
  self.cursor_x = x
  self.cursor_y = y
  if y > 133 then
    if y <399 then self.world_minimap_visible_xy.y = y - 51 else self.world_minimap_visible_xy.y = 399 end
  end

  -- Update the caption text.
  for k, v in pairs(warp_points) do
    if k == initial_point then self.caption_text_2:set_text(sol.language.get_string(v[5])) end
  end
end

function warp_menu:on_draw(dst_surface)
  -- Draw background.
  local width, height = dst_surface:get_size()
  self.background_surfaces:draw_region(320, 0, 320, 240, dst_surface, (width - 320) / 2, (height - 240) / 2)

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

  -- Draw caption (Not working currently for some reason).
  local width, height = dst_surface:get_size()
  self.caption_text_1:draw(dst_surface, width / 2, 200)
  self.caption_text_2:draw(dst_surface, width / 2, 213)
end

function warp_menu:on_finished()
  game:get_map():get_hero():unfreeze()
end