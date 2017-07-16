local item = ...
local game = item:get_game() 

-- This script defines the behavior of pickable poe souls present on the map.

function item:on_created()
  self:set_shadow(nil)
  self:set_can_disappear(true)
  self:set_brandish_when_picked(false)
end

-- A poe soul appears on the map: create its movement.
function item:on_pickable_created(pickable)
   -- Create a movement that goes into random directions,
   -- with a speed of 28 pixels per second.
  local movement = sol.movement.create("random")
  movement:set_speed(28)
  movement:set_ignore_obstacles(true)
  movement:set_max_distance(40)  -- Don't go too far.

  -- Put the poe soul on the highest layer to show it above all walls.
  local x, y = pickable:get_position()
  pickable:set_position(x, y, 2)
  pickable:set_layer_independent_collisions(true)  -- But detect collisions with lower layers anyway

  sol.audio.play_sound("poe_soul")

  -- When the direction of the movement changes,
  -- update the direction of the soul's sprite
  function pickable:on_movement_changed(movement)
    if pickable:get_followed_entity() == nil then
      local sprite = pickable:get_sprite()
      local angle = movement:get_angle()  -- Retrieve the current movement's direction.
      if angle >= math.pi / 2 and angle < 3 * math.pi / 2 then
        sprite:set_direction(1)  -- Look to the left.
      else
        sprite:set_direction(0)  -- Look to the right.
      end
    end
  end
  movement:start(pickable)
end

-- Obtaining a poe soul.
function item:on_obtaining(variant, savegame_variable)
  local first_empty_bottle = game:get_first_empty_bottle()
  if not game:has_bottle() or first_empty_bottle == nil then
    -- The player has no bottle.
    game:start_dialog("found_fairy.no_empty_bottle")
    sol.audio.play_sound("wrong")
  else
    -- The player has a bottle: start the dialog.
    game:start_dialog("found_soul", function(answer)
      if answer == "skipped" or answer == 2 then
        -- Let go.
      else
        -- Keep the spirit in a bottle.
        first_empty_bottle:set_variant(8)
        sol.audio.play_sound("danger")
      end
    end)
  end
end
