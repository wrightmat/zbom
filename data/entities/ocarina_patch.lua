local entity = ...
local game = entity:get_game()
local map = entity:get_map()
entity.action_effect = "look"
local matched = false
local warps = {
  -- Warp point name, companion point, warp to map
  b1500 = { "b1501", "133" }, -- Old Kasuto / Hidden Village
  b1501 = { "b1500", "46" },
  b1502 = { "b1503", "51" }, -- Kakariko / Ordon Village
  b1503 = { "b1502", "11" },
  b1504 = { "b1505", "72" }, -- Goron City / Gerudo Camp
  b1505 = { "b1504", "66" },
  b1506 = { "b1507", "82" }, -- Beach / Lost Woods
  b1507 = { "b1506", "37" },
  b1508 = { "b1509", "60" }, -- Snowpeak / Calatia
  b1509 = { "b1508", "88" }, 
  b1510 = { "b1511", "56" }, -- Septen / Three Eye
  b1511 = { "b1510", "139" },
  b1512 = { "b1513", "57" }, -- Zora's Domain / Rito Town
  b1513 = { "b1512", "93" },
  b1514 = { "b1515", "34" }, -- Lake Hylia / Floria Peninsula
  b1515 = { "b1514", "13" }
}

-- Ocarina patch: a special map entity that allows the hero
-- to warp to a paired point if he has the Ocarina of Wind.

function entity:on_created()
  self:create_sprite("entities/ocarina_patch")
  self:set_size(16, 16)
  self:set_origin(8, 13)
  self:set_traversable_by(true)
  game:set_interaction_enabled(entity, true)
  -- If other point is discovered, visually display on the tile.
  for k, v in pairs(warps) do
    if k == self:get_name() and game:get_value(v[1]) then
      self:get_sprite():set_animation("linked")
    elseif k == self:get_name() and game:get_value(self:get_name()) then
      self:get_sprite():set_animation("activated")
    end
  end
end

function entity:on_custom_interaction()
  game:set_custom_command_effect("action", nil) -- Change the custom action effects.
  game:set_dialog_style("default")
  matched = false
  -- If this point not previously discovered then add it.
  if not game:get_value(entity:get_name()) then
    game:start_dialog("warp.new_point", function()
      game:set_value(entity:get_name(), true)
    end)
  else
    -- If other paired point is discovered (and they have the Ocarina),
    -- then ask the player if they want to warp there.
    if game:has_item("ocarina") then
      for k, v in pairs(warps) do
        if k == self:get_name() and game:get_value(v[1]) then
          matched = true
          game:start_dialog("warp.to_"..v[2], function(answer)
            if answer == 1 then
              map:get_hero():set_animation("ocarina")
              sol.audio.play_sound("ocarina_wind")
              map:get_entity("hero"):teleport(v[2], "ocarina_warp", "fade")
            end
          end)
        end
      end
      if not matched then game:start_dialog("warp.interaction") end -- Paired point not discovered.
    else
      -- No ocarina.
    end
  end
end