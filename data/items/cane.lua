local item = ...
item.ice_block = nil  -- The block created if any.

function item:on_created()
  self:set_savegame_variable("i1814")
  self:set_assignable(true)
end

function item:on_using()
  local magic_needed = 6
  local game = self:get_game()
  local map = self:get_map()
  if game:get_magic() >= magic_needed then
    local x, y, layer = self:get_block_position_from_hero()

    if self.ice_block == nil or not self.ice_block:exists() then
      sol.audio.play_sound("cane")
      sol.audio.play_sound("magic_bar")
      game:remove_magic(magic_needed)

      -- Create the Ice block.
      self.ice_block = map:create_custom_entity{
	name = "ice_block",
	x = x,
	y = y,
	width = 16,
	height = 16,
	layer = layer,
	direction = map:get_hero():get_direction(),
	model = "ice_block"
      }
      self.created = true
    else
      -- Reuse the old one.
      local old_x, old_y, old_layer = self.ice_block:get_position()
      if x ~= old_x or y ~= old_y or layer ~= old_layer then
        sol.audio.play_sound("cane")
        sol.audio.play_sound("magic_bar")
        game:remove_magic(magic_needed)
        self.ice_block:set_position(x, y, layer)
      end
    end
  else
    -- Not enough magic.
    if self.ice_block ~= nil and self.ice_block:get_position() ~= -100 then
      -- Remove the previous block.
      sol.audio.play_sound("cane")
      self.ice_block:set_position(-100, 0)
    else
      sol.audio.play_sound("wrong")
    end
  end
  self:set_finished()
end

-- Called when the current map changes.
function item:on_map_changed()
  -- No more ice block on the new map.
  self.ice_block = nil
end

function item:get_block_position_from_hero()
  -- Compute a position
  local hero = self:get_map():get_entity("hero")
  local x, y, layer = hero:get_position()
  local direction = hero:get_direction()
  if direction == 0 then
    x = x + 21
  elseif direction == 1 then
    y = y - 21
  elseif direction == 2 then
    x = x - 21
  elseif direction == 3 then
    y = y + 21
  end

  -- Snap the center of the block to the 8*8 grid.
  x = (x + 4) - (x + 4) % 8
  y = (y - 1) - (y - 1) % 8 + 5

  return x, y, layer
end

function item:on_obtained(variant, savegame_variable)
  -- Give the magic bar if necessary.
  local magic_bar = self:get_game():get_item("magic_bar")
  if not magic_bar:has_variant() then
    magic_bar:set_variant(1)
  end
end