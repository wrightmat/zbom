local submenu = require("scripts/menus/pause_submenu")
local options_submenu = submenu:new()

function options_submenu:on_started()
  submenu.on_started(self)
  
  local font, font_size = sol.language.get_menu_font()
  local width, height = sol.video.get_quest_size()
  local center_x, center_y = width / 2, height / 2
  local video_mode_text = true
  
  self.video_mode_label_text = sol.text_surface.create{
    horizontal_alignment = "left",
    vertical_alignment = "top",
    font = font,
    font_size = font_size,
    text_key = "selection_menu.options.video_mode",
  }
  self.video_mode_label_text:set_xy(center_x - 50, center_y - 58)
  
  self.video_mode_text = sol.text_surface.create{
    horizontal_alignment = "right",
    vertical_alignment = "top",
    font = font,
    font_size = font_size,
    text = sol.video.get_mode(),
  }
  self.video_mode_text:set_xy(center_x + 104, center_y - 58)
  
  self.command_column_text = sol.text_surface.create{
    horizontal_alignment = "center",
    vertical_alignment = "top",
    font = font,
    font_size = font_size,
    text_key = "options.commands_column",
  }
  self.command_column_text:set_xy(center_x - 76, center_y - 37)
  
  self.keyboard_column_text = sol.text_surface.create{
    horizontal_alignment = "center",
    vertical_alignment = "top",
    font = font,
    font_size = font_size,
    text_key = "options.keyboard_column",
  }
  self.keyboard_column_text:set_xy(center_x - 7, center_y - 37)
  
  self.joypad_column_text = sol.text_surface.create{
    horizontal_alignment = "center",
    vertical_alignment = "top",
    font = font,
    font_size = font_size,
    text_key = "options.joypad_column",
  }
  self.joypad_column_text:set_xy(center_x + 69, center_y - 37)
  
  self.commands_surface = sol.surface.create(215, 160)
  self.commands_surface:set_xy(center_x - 107, center_y - 18)
  self.commands_highest_visible = 1
  self.commands_visible_y = 0
  
  self.command_texts = {}
  self.keyboard_texts = {}
  self.joypad_texts = {}
  self.command_names = { "action", "attack", "item_1", "item_2", "pause", "left", "right", "up", "down" }
  for i = 1, #self.command_names do
    self.command_texts[i] = sol.text_surface.create{
      horizontal_alignment = "left",
      vertical_alignment = "top",
      font = font,
      font_size = font_size,
      text_key = "options.command." .. self.command_names[i],
    }
    self.keyboard_texts[i] = sol.text_surface.create{
      horizontal_alignment = "left",
      vertical_alignment = "top",
      font = font,
      font_size = font_size,
    }
    self.joypad_texts[i] = sol.text_surface.create{
      horizontal_alignment = "left",
      vertical_alignment = "top",
      font = font,
      font_size = font_size,
    }
  end
  
  self:load_command_texts()
  
  self.up_arrow_sprite = sol.sprite.create("menus/arrow")
  self.up_arrow_sprite:set_direction(1)
  self.up_arrow_sprite:set_xy(center_x - 64, center_y - 24)
  self.down_arrow_sprite = sol.sprite.create("menus/arrow")
  self.down_arrow_sprite:set_direction(3)
  self.down_arrow_sprite:set_xy(center_x - 64, center_y + 62)
  self.left_arrow_sprite = sol.sprite.create("menus/arrow")
  self.left_arrow_sprite:set_direction(2)
  self.left_arrow_sprite:set_xy(center_x - 66, center_y - 59)
  self.right_arrow_sprite = sol.sprite.create("menus/arrow")
  self.right_arrow_sprite:set_direction(0)
  self.right_arrow_sprite:set_xy(center_x + 109, center_y - 59)
  self.cursor_sprite = sol.sprite.create("menus/options_cursor")
  self.cursor_position = nil
  self:set_cursor_position(1)
  
  self.game:set_custom_command_effect("action", "change")
end

-- Loads the text displayed for each game command, for the
-- keyboard and the joypad.
function options_submenu:load_command_texts()
  self.commands_surface:clear()
  for i = 1, #self.command_names do
    local keyboard_binding = self.game:get_command_keyboard_binding(self.command_names[i])
    local joypad_binding = self.game:get_command_joypad_binding(self.command_names[i])
    self.keyboard_texts[i]:set_text(keyboard_binding:sub(1, 9))
    self.joypad_texts[i]:set_text(joypad_binding:sub(1, 9))
    
    local y = 16 * i - 14
    self.command_texts[i]:draw(self.commands_surface, 4, y)
    self.keyboard_texts[i]:draw(self.commands_surface, 74, y)
    self.joypad_texts[i]:draw(self.commands_surface, 143, y)
  end
end

function options_submenu:set_cursor_position(position)
  if position ~= self.cursor_position then
    local width, height = sol.video.get_quest_size()
    
    self.cursor_position = position
    if position == 1 then  -- Video mode.
      self:set_caption("options.caption.press_action_change_mode")
      self.cursor_sprite.x = width / 2 - 58
      self.cursor_sprite.y = height / 2 - 59
      self.cursor_sprite:set_animation("big")
      self.video_mode_label_text:set_text_key("selection_menu.options.video_mode")
      self.video_mode_text:set_text(sol.video.get_mode())
      video_mode_text = true
    elseif position == 2 then  -- Control Scheme.
      local control_scheme = self.game:get_value("control_scheme") or "keyboard"
      self:set_caption("options.caption.press_action_change_controls")
      self.cursor_sprite.x = width / 2 - 58
      self.cursor_sprite.y = height / 2 - 59
      self.cursor_sprite:set_animation("big")
      self.video_mode_label_text:set_text_key("selection_menu.options.control_scheme")
      self.video_mode_text:set_text_key("options.control_scheme."..control_scheme)
      video_mode_text = false
    else  -- Customization of a command.
      position = position - 1
      self:set_caption("options.caption.press_action_customize_key")
      
      -- Make sure the selected command is visible.
      while position <= self.commands_highest_visible do
        self.commands_highest_visible = self.commands_highest_visible - 1
        self.commands_visible_y = self.commands_visible_y - 16
      end
      
      while position > self.commands_highest_visible + 5 do
        self.commands_highest_visible = self.commands_highest_visible + 1
        self.commands_visible_y = self.commands_visible_y + 16
      end
      
      self.cursor_sprite.x = width / 2 - 105
      self.cursor_sprite.y = height / 2 - 32 + 16 * (position - self.commands_highest_visible)
      self.cursor_sprite:set_animation("small")
    end
  end
end

function options_submenu:on_draw(dst_surface)
  self:draw_background(dst_surface)
  self:draw_caption(dst_surface)
  
  -- Cursor.
  self.cursor_sprite:draw(dst_surface, self.cursor_sprite.x, self.cursor_sprite.y)
  
  -- Text.
  self.video_mode_label_text:draw(dst_surface)
  self.video_mode_text:draw(dst_surface)
  self.command_column_text:draw(dst_surface)
  self.keyboard_column_text:draw(dst_surface)
  self.joypad_column_text:draw(dst_surface)
  self.commands_surface:draw_region(0, self.commands_visible_y, 215, 84, dst_surface)
  
  -- Arrows.
  if self.commands_visible_y > 0 then
    self.up_arrow_sprite:draw(dst_surface)
    self.up_arrow_sprite:draw(dst_surface, 115, 0)
  end
  if self.commands_visible_y < 60 then
    self.down_arrow_sprite:draw(dst_surface)
    self.down_arrow_sprite:draw(dst_surface, 115, 0)
  end
  if video_mode_text then
    self.right_arrow_sprite:draw(dst_surface)
  else
    self.left_arrow_sprite:draw(dst_surface)
  end

  self:draw_save_dialog_if_any(dst_surface)
end

function options_submenu:on_command_pressed(command)
  if self.command_customizing ~= nil then
    -- We are customizing a command: any key pressed should have been handled before.
    error("options_submenu:on_command_pressed() should not called in this state")
  end

  local handled = submenu.on_command_pressed(self, command)

  if not handled then
    if command == "left" then
      if self.cursor_position == 2 then
        sol.audio.play_sound("cursor")
        self:set_cursor_position(1)
      else self:previous_submenu() end
      handled = true
    elseif command == "right" then
      if self.cursor_position == 1 then
        sol.audio.play_sound("cursor")
        self:set_cursor_position(2)
      else self:next_submenu() end
      handled = true
    elseif command == "up" then
      sol.audio.play_sound("cursor")
      if self.cursor_position == 3 then
        self:set_cursor_position(1)
      else self:set_cursor_position((self.cursor_position + 9) % 11 + 1) end
      handled = true
    elseif command == "down" then
      sol.audio.play_sound("cursor")
      if self.cursor_position == 1 then
        self:set_cursor_position(3)
      else self:set_cursor_position(self.cursor_position % 11 + 1) end
      handled = true
    elseif command == "action" then
      sol.audio.play_sound("danger")
      if self.cursor_position == 1 then
        -- Change the video mode.
        sol.video.switch_mode()
        self.video_mode_text:set_text(sol.video.get_mode())
      elseif self.cursor_position == 2 then
        -- Change the control scheme.
        local control_scheme = self.game:get_value("control_scheme") or "keyboard"
        if control_scheme == "touch_1" then control_scheme = "touch_2"
        elseif control_scheme == "keyboard" then control_scheme = "touch_1"
        elseif control_scheme == "touch_2" then control_scheme = "keyboard" end
        self.game:set_value("control_scheme", control_scheme)
        self.video_mode_text:set_text_key("options.control_scheme."..control_scheme)
      else
        -- Customize a game command.
        self:set_caption("options.caption.press_key")
        self.cursor_sprite:set_animation("small_blink")
        local command_to_customize = self.command_names[self.cursor_position - 2]
        self.game:capture_command_binding(command_to_customize, function()
          sol.audio.play_sound("danger")
          self:set_caption("options.caption.press_action_customize_key")
          self.cursor_sprite:set_animation("small")
          self:load_command_texts()
        end)
      end
      handled = true
    end
  end

  return handled
end

return options_submenu