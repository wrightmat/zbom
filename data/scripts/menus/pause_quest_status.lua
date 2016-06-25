local submenu = require("scripts/menus/pause_submenu")
local quest_status_submenu = submenu:new()

function quest_status_submenu:on_started()
  submenu.on_started(self)
  self.quest_items_surface = sol.surface.create(320, 240)
  self.quest_dialog_surface = sol.surface.create(160, 48)
  self.cursor_sprite = sol.sprite.create("menus/pause_cursor")
  self.quest_dialog_sprite = sol.sprite.create("menus/quest_dialog")
  self.cursor_sprite_x = 0
  self.cursor_sprite_y = 0
  self.cursor_position = nil
  self.quest_dialog_state = 0
  self.caption_text_keys = {}

  local item_sprite = sol.sprite.create("entities/items")

  -- Draw the items on a surface.
  self.quest_items_surface:clear()

  -- Wallet.
  local rupee_bag = self.game:get_item("rupee_bag"):get_variant()
  if rupee_bag > 0 then
    item_sprite:set_animation("rupee_bag")
    item_sprite:set_direction(rupee_bag - 1)
    item_sprite:draw(self.quest_items_surface, 68, 84)
    self.caption_text_keys[0] = "quest_status.caption.rupee_bag_" .. rupee_bag
  end

  -- Bomb bag.
  if self.game:get_item("bomb_bag") ~= nil then
    local bomb_bag = self.game:get_item("bomb_bag"):get_variant()
    if bomb_bag > 0 then
      item_sprite:set_animation("bomb_bag")
      item_sprite:set_direction(bomb_bag - 1)
      item_sprite:draw(self.quest_items_surface, 68, 113)
      self.caption_text_keys[1] = "quest_status.caption.bomb_bag_" .. bomb_bag
    end
  end

  -- Quiver.
  if self.game:get_item("quiver") ~= nil then
    local quiver = self.game:get_item("quiver"):get_variant()
    if quiver > 0 then
      item_sprite:set_animation("quiver")
      item_sprite:set_direction(quiver - 1)
      item_sprite:draw(self.quest_items_surface, 68, 143)
      self.caption_text_keys[2] = "quest_status.caption.quiver_" .. quiver
    end
  end

  -- Ocarina.
  local ocarina = self.game:get_item("ocarina"):get_variant()
  if ocarina > 0 then
    item_sprite:set_animation("ocarina")
    item_sprite:set_direction(ocarina - 1)
    item_sprite:draw(self.quest_items_surface, 68, 177)
    self.caption_text_keys[3] = "quest_status.caption.ocarina_" .. ocarina
  end

  -- Pieces of heart.
  local pieces_of_heart_img = sol.surface.create("menus/quest_status_pieces_of_heart.png")
  local x = 51 * (self.game:get_value("i1700") or 0)
  pieces_of_heart_img:draw_region(x, 0, 51, 50, self.quest_items_surface, 101, 81)
  self.caption_text_keys[4] = "quest_status.caption.pieces_of_heart"

  -- Bracelet/Glove.
  local glove = self.game:get_item("glove"):get_variant()
  if glove > 0 then
    item_sprite:set_animation("glove")
    item_sprite:set_direction(glove - 1)
    item_sprite:draw(self.quest_items_surface, 116, 177)
    self.caption_text_keys[5] = "quest_status.caption.glove_" .. glove
  end

  -- Flippers.
  local flippers = self.game:get_item("flippers"):get_variant()
  if flippers > 0 then
    item_sprite:set_animation("flippers")
    item_sprite:set_direction(flippers - 1)
    item_sprite:draw(self.quest_items_surface, 150, 177)
    self.caption_text_keys[6] = "quest_status.caption.flippers_" .. flippers
  end

  -- Tunic.
  self.tunic = self.game:get_item("tunic"):get_variant()
  self.tunic_equipped = self.game:get_value("tunic_equipped")
  item_sprite:set_animation("tunic")
  item_sprite:set_direction(self.tunic_equipped - 1)
  item_sprite:draw(self.quest_items_surface, 185, 177)
  self.caption_text_keys[7] = "quest_status.caption.tunic_" .. self.tunic_equipped

  -- Sword.
  local sword = self.game:get_item("sword"):get_variant()
  if sword > 0 then
    item_sprite:set_animation("sword")
    item_sprite:set_direction(sword - 1)
    item_sprite:draw(self.quest_items_surface, 219, 177)
    self.caption_text_keys[8] = "quest_status.caption.sword_" .. sword
  end

  -- Shield.
  local shield = self.game:get_item("shield"):get_variant()
  if shield > 0 then
    item_sprite:set_animation("shield")
    item_sprite:set_direction(shield - 1)
    item_sprite:draw(self.quest_items_surface, 253, 177)
    self.caption_text_keys[9] = "quest_status.caption.shield_" .. shield
  end

  -- Dungeons finished
  local dungeons_img = sol.surface.create("menus/quest_status_dungeons.png")
  local dst_positions = {
    { 209,  69 },
    { 232,  74 },
    { 243,  97 },
    { 232, 120 },
    { 209, 127 },
    { 186, 120 },
    { 175,  97 },
    { 186,  74 },
  }
  for i, dst_position in ipairs(dst_positions) do
    if self.game:is_dungeon_finished(i) then
      dungeons_img:draw_region(20 * (i - 1), 0, 20, 20,
          self.quest_items_surface, dst_position[1], dst_position[2])
    end
  end

  -- Cursor.
  self:set_cursor_position(0)
end

function quest_status_submenu:set_cursor_position(position)
  if position ~= self.cursor_position then
    self.cursor_position = position
    if position <= 3 then
      self.cursor_sprite_x = 68
    elseif position == 4 then
      self.cursor_sprite_x = 126
      self.cursor_sprite_y = 107
    else
      self.cursor_sprite_x = -53 + 34 * position
    end

    if position == 0 then
      self.cursor_sprite_y = 79
    elseif position == 1 then
      self.cursor_sprite_y = 108
    elseif position == 2 then
      self.cursor_sprite_y = 138
    elseif position == 4 then
      self.cursor_sprite_y = 107
    else
      self.cursor_sprite_y = 172
    end

    self:set_caption(self.caption_text_keys[position])
  end
end

function quest_status_submenu:on_command_pressed(command)
  local handled = submenu.on_command_pressed(self, command)

  if self.quest_dialog_state == 1 then
    if command == "left" or command == "down" then
      self.quest_dialog_choice = self.quest_dialog_choice - 1
      if self.quest_dialog_choice < 0 then self.quest_dialog_choice = self.tunic - 1 end
      self.quest_dialog_sprite:set_direction(self.quest_dialog_choice)
      self:set_caption("quest_status.caption.tunic_" .. self.quest_dialog_choice + 1)
    elseif command == "right" or command == "up" then
      self.quest_dialog_choice = self.quest_dialog_choice + 1
      if self.quest_dialog_choice >= self.tunic then self.quest_dialog_choice = 0 end
      self.quest_dialog_sprite:set_direction(self.quest_dialog_choice)
      self:set_caption("quest_status.caption.tunic_" .. self.quest_dialog_choice + 1)
    elseif command == "action" or command == "attack" then
      self.game:set_value("tunic_equipped", self.quest_dialog_choice + 1)
      self.tunic_equipped = self.quest_dialog_choice + 1
      sol.audio.play_sound("throw")
      self.quest_dialog_state = 0
      -- Redraw the new tunic in the menu
      self.quest_dialog_surface:clear()
      self.game:set_custom_command_effect("action", nil)
      local item_sprite = sol.sprite.create("entities/items")
      item_sprite:set_animation("tunic")
      item_sprite:set_direction(self.quest_dialog_choice)
      item_sprite:draw(self.quest_items_surface, 185, 177)
      self.caption_text_keys[7] = "quest_status.caption.tunic_" .. self.tunic_equipped
      self.game:get_hero():set_tunic_sprite_id("hero/tunic" .. self.tunic_equipped)
    end

  elseif not handled then
    if command == "left" then
      if self.cursor_position <= 3 then
        self:previous_submenu()
      else
        sol.audio.play_sound("cursor")
        if self.cursor_position == 4 then
          self:set_cursor_position(0)
        elseif self.cursor_position == 5 then
          self:set_cursor_position(3)
        else
          self:set_cursor_position(self.cursor_position - 1)
        end
      end
      handled = true

    elseif command == "right" then
      if self.cursor_position == 4 or self.cursor_position == 9 then
        self:next_submenu()
      else
        sol.audio.play_sound("cursor")
        if self.cursor_position <= 2 then
          self:set_cursor_position(4)
        elseif self.cursor_position == 3 then
          self:set_cursor_position(5)
        else
          self:set_cursor_position(self.cursor_position + 1)
        end
      end
      handled = true

    elseif command == "down" then
      sol.audio.play_sound("cursor")
      self:set_cursor_position((self.cursor_position + 1) % 10)
      handled = true

    elseif command == "up" then
      sol.audio.play_sound("cursor")
      self:set_cursor_position((self.cursor_position + 9) % 10)
      handled = true

    elseif command == "action" then
      if self.cursor_position == 7 then
        -- Cursor is over the Tunic
        sol.audio.play_sound("message_end")
        self.quest_dialog_choice = (self.tunic_equipped - 1) or 0
        self.quest_dialog_sprite:set_direction(self.quest_dialog_choice)
        self.game:set_custom_command_effect("action", "validate")
        self.quest_dialog_state = 1
        handled = true
      end
    end

  end

  return handled
end

function quest_status_submenu:on_draw(dst_surface)
  local width, height = dst_surface:get_size()
  local x = width / 2 - 160
  local y = height / 2 - 120
  self:draw_background(dst_surface)
  self:draw_caption(dst_surface)
  self.quest_items_surface:draw(dst_surface, x, y)
  self.cursor_sprite:draw(dst_surface, x + self.cursor_sprite_x, y + self.cursor_sprite_y)
  if self.quest_dialog_state == 1 then
    self.quest_dialog_sprite:draw(self.quest_dialog_surface, 0, 0)
    local item_sprite = sol.sprite.create("entities/items")
    item_sprite:set_animation("tunic")
    for i = 0, self.tunic - 1 do
      item_sprite:set_direction(i)
      item_sprite:draw(self.quest_dialog_surface, 23+(i*38), 30)
    end
    self.quest_dialog_surface:draw(dst_surface, x + 105, y + 145)
  end
  self:draw_save_dialog_if_any(dst_surface)
end

return quest_status_submenu