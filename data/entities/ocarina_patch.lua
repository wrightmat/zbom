local entity = ...
local game = entity:get_game()
local map = entity:get_map()
local matched = false
local paired = false

-- Ocarina patch: a special map entity that allows the hero
-- to warp to a paired point if he has the Ocarina of Wind.

function entity:on_created()
  self:create_sprite("entities/ocarina_patch")
  self:set_size(16, 16)
  self:set_origin(8, 13)
  self:set_traversable_by(true)
  self.action_effect = "look"
  -- If other point is discovered, visually display on the tile.
  for k, v in pairs(warp_points) do
    if game:get_value(v[1]) then paired = true end
    if k == self:get_name() and game:get_value(v[1]) and game:get_value(self:get_name()) then
      -- Shining effect only if both paired points are discovered.
      self:get_sprite():set_animation("linked")
    elseif k == self:get_name() and game:get_value(self:get_name()) then
      -- Lighter sprite if this point is discovered.
      self:get_sprite():set_animation("activated")
    end
  end
end

function entity:on_interaction()
  -- If this point not previously discovered then add it.
  if not game:get_value(entity:get_name()) then
    game:start_dialog("warp.new_point", function()
      game:set_value(entity:get_name(), true)
      if paired then
        self:get_sprite():set_animation("linked")
      else
        self:get_sprite():set_animation("activated")
      end
    end)
  else
    -- If player has the Ocarina, then show warp selection menu.
    if game:has_item("ocarina") then
      for k, v in pairs(warp_points) do
        if k == self:get_name() then
          game:on_warp_started(self:get_name())
        end
      end
    else
      game:start_dialog("warp.interaction")
    end
  end
end