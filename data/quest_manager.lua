-- This script handles global behavior of this quest,
-- that is, things not related to a particular savegame.
local quest_manager = {}

-- Initializes the behavior of destructible entities.
local function initialize_destructibles()

  -- Show a dialog when the player cannot lift them.
  local destructible_meta = sol.main.get_metatable("destructible")
  -- destructible_meta represents the shared behavior of all destructible objects.

  function destructible_meta:on_looked()

    -- Here, self is the destructible object.
    local game = self:get_game()
    if self:get_can_be_cut()
        and not self:get_can_explode()
        and not self:get_game():has_ability("sword") then
      -- The destructible can be cut, but the player no cut ability.
      game:start_dialog("_cannot_lift_should_cut");
    elseif not game:has_ability("lift") then
      -- No lift ability at all.
      game:start_dialog("_cannot_lift_too_heavy");
    else
      -- Not enough lift ability.
      game:start_dialog("_cannot_lift_still_too_heavy");
    end
  end
end

-- Initializes the behavior of enemies.
local function initialize_enemies()

  -- Enemies: redefine the damage of the hero's sword.
  -- (The default damages are less important.)
  local enemy_meta = sol.main.get_metatable("enemy")

  function enemy_meta:on_hurt_by_sword(hero, enemy_sprite)

    -- Here, self is the enemy.
    local game = self:get_game()
    local sword = game:get_ability("sword")
    local damage_factors = { 1, 2, 4, 8 }  -- Damage factor of each sword.
    local damage_factor = damage_factors[sword]
    if hero:get_state() == "sword spin attack" then
      damage_factor = damage_factor * 2  -- The spin attack is twice more powerful.
    end

    local reaction = self:get_attack_consequence_sprite(enemy_sprite, "sword")
    self:remove_life(reaction * damage_factor)
  end
end

-- Initializes map entity related behaviors.
local function initialize_entities()
  initialize_destructibles()
  initialize_enemies()
end

local function initialize_maps()
  if game.time_of_day == nil then game.time_of_day = day end

  local map_metatable = sol.main.get_metatable("map")
  function map_metatable:add_night_overlay()
    -- Here, self is the map.
    self.overlay = sol.surface.create(320, 240)
    self.overlay:fill_color{0, 51, 102}
    self.overlay:set_opacity(0.4 * 255)
  end

  -- Put the night overlay on any outdoor map if it's night time
  -- Also activate any night-specific dynamic tiles
  if game.time_of_day == night then map_metatable:add_night_overlay()
  for entity in map:get_entities("night_") do
    entity:set_enabled(true)
  end

  function map_metatable:on_draw(dst_surface)
    if self.overlay ~= nil and self:get_world == "outside_world" then
      self.overlay:draw(dst_surface)
    end
  end
end

-- Performs global initializations specific to this quest.
function quest_manager:initialize_quest()
  initialize_maps()
  initialize_entities()
end

return quest_manager
