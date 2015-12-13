local item = ...
local game = item:get_game()

-- The bow has two variants: without arrows or with arrows.
-- This is necessary to allow it to have different icons in both cases.
-- Therefore, the bow of light is implement as another item (bow_light),
-- and calls code from this bow.
-- It could be simpler if it was possible to change the icon of items dynamically.

function item:on_created()
  self:set_savegame_variable("i1801")
  self:set_amount_savegame_variable("i1802")
  self:set_assignable(true)
end

function item:on_using()
  local map = game:get_map()
  local hero = map:get_hero()

  if self:get_amount() == 0 then
    sol.audio.play_sound("wrong")
    self:set_finished()
  else
    hero:set_animation("bow")

    sol.timer.start(map, 290, function()
    sol.audio.play_sound("bow")
      self:remove_amount(1)
      self:set_finished()

      local x, y = hero:get_center_position()
      local _, _, layer = hero:get_position()
      local arrow = map:create_custom_entity({
        x = x,
        y = y,
        layer = layer,
        direction = hero:get_direction(),
        model = "arrow",
      })

      arrow:set_force(self:get_force())
      arrow:set_sprite_id(self:get_arrow_sprite_id())
      arrow:go()
    end)
  end
end


function item:on_amount_changed(amount)
  if self:get_variant() ~= 0 then
    -- update the icon (with or without arrow).
    if amount == 0 then
      self:set_variant(1)
    else
      self:set_variant(2)
    end
  end
end

function item:on_obtaining(variant, savegame_variable)
  local arrow = game:get_item("arrow")
  local quiver = game:get_item("quiver")

  if not quiver:has_variant() then
    -- Give the first quiver and some arrows with the bow.
    quiver:set_variant(1)
    self:add_amount(10)
    arrow:set_obtainable(true)
  else
    -- Set the max value of the bow counter.
    local max_amounts = {10, 30, 60}
    local max_amount = max_amounts[quiver:get_variant()]
    self:set_max_amount(max_amount)
  end
  if self:get_amount() == 0 then self:set_variant(1) else self:set_variant(2) end
end

function item:get_force()
  return 2
end

function item:get_arrow_sprite_id()
  return "entities/arrow"
end

-- Initialize the metatable of appropriate entities to work with custom arrows.
local function initialize_meta()
  -- Add Lua arrow properties to enemies.
  local enemy_meta = sol.main.get_metatable("enemy")
  if enemy_meta.set_attack_arrow ~= nil then
    -- Already done.
    return
  end

  enemy_meta.arrow_reaction = "force"
  enemy_meta.arrow_reaction_sprite = {}
  function enemy_meta:get_attack_arrow(sprite)
    if sprite ~= nil and self.arrow_reaction_sprite[sprite] ~= nil then
      return self.arrow_reaction_sprite[sprite]
    end

    if self.arrow_reaction == "force" then
      -- Replace by the current force value.
      local game = self:get_game()
      if game:has_item("bow_light") then
        return game:get_item("bow_light"):get_force()
      end
      return game:get_item("bow"):get_force()
    end

    return self.arrow_reaction
  end

  function enemy_meta:set_attack_arrow(reaction)
    self.arrow_reaction = reaction
  end

  function enemy_meta:set_attack_arrow_sprite(sprite, reaction)
    self.arrow_reaction_sprite[sprite] = reaction
  end

  -- Change the default enemy:set_invincible() to also take into account arrows.
  local previous_set_invincible = enemy_meta.set_invincible
  function enemy_meta:set_invincible()
    previous_set_invincible(self)
    self:set_attack_arrow("ignored")
  end
  local previous_set_invincible_sprite = enemy_meta.set_invincible_sprite
  function enemy_meta:set_invincible_sprite(sprite)
    previous_set_invincible_sprite(self, sprite)
    self:set_attack_arrow_sprite(sprite, "ignored")
  end
end

initialize_meta()