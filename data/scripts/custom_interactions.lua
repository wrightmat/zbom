local game = ...

--WARNING: collision_test_manager.lua required!!!

--[[ This script is used to notify the HUD of the possible interactions.
1)  Give a string value to entity.action_effect. The hud should be able to manage it.
2) Define the event that will be called for the interaction: entity.on_interaction(). (This is usually called by the engine, not the scripts.)
3) Enable/disable the interaction with: game:set_interaction_enabled(entity, enabled).
--]]

-- Returns true if the interaction is enabled. False otherwise.
function game:is_interaction_enabled(entity)
  return game:has_collision_test(entity, "hero_interaction")
end

-- Returns an entity that can interact with the hero, if any, or nil otherwise.
function game:get_interaction_entity()
  return game:get_hero().custom_interaction
end

-- Remove interaction state of the hero.
function game:clear_interaction()
  game:get_hero().custom_interaction = nil
end

-- Enable/disable the interaction of a custom entity ("enabled" is a boolean variable).
-- This creates a collision test if necessary (it is created only once).
-- The last parameter "direction" is optional!!!
function game:set_interaction_enabled(entity, enabled, direction)
  local timer -- Timer used to stop the collision test.
  -- Define the collision test if needed. Update variable "hero.custom_interaction".
  if enabled and not game:is_interaction_enabled(entity) then
    game:add_collision_test(entity, "hero_interaction", "facing", function(entity, other)
      -- Do nothing if there is already a different entity for interaction.
      if game:get_interaction_entity() and game:get_interaction_entity() ~= entity then return end
      -- Do nothing if the other entity is not the hero, or if the entity is carried.
      if other ~= game:get_hero() or entity.state == "carried" then return end
      -- In case a direction is given, do nothing if the direction is not the good one.
      if direction and other:get_direction() ~= direction then return end
      -- Do nothing if there is already an action effect, except for talking while carrying.
      if game:get_command_effect("action") then return end
      -- Return an error if there is no action effect for this entity.
      local effect = entity.action_effect
      if effect == nil then error("No interaction effect defined in variable entity.action_effect") end
      if game:get_hero().custom_carry and effect ~= "talk" then return end
      -- Set the effect to display in the hud. It can be modified in the variable entity.action_effect.
      game:set_custom_command_effect("action", effect)
      -- Set this entity as the one that can interact with the hero.
      game:get_hero().custom_interaction = entity
      -- Notify the hud when the effect should stop displaying, when the hero is not facing the custom entity.
      -- This timer is destroyed each time the collision test is called, to avoid stopping the collision test.
      if timer then timer:stop() end
      timer = sol.timer.start(game, 50, function()
        -- Callback of timer.
        game:clear_interaction()
        game:set_custom_command_effect("action", nil) 
      end)
    end)
  else
    -- Stop interaction with this entity.
    if game:is_interaction_enabled(entity) then
      game:clear_collision_test(entity, "hero_interaction")
    end
    if game:get_interaction_entity() == entity then game:clear_interaction() end
  end
end
