local item = ...

function item:on_created()
  item:set_savegame_variable("i1839")
  item:set_assignable(true)
  item:set_pushed_stake(false)
end

function item:on_using()
  local game = item:get_game()
  local hero = game:get_hero()

  -- Handle stakes.
  item:set_pushed_stake(false)
  sol.timer.start(item, 50, function()
    if item:has_pushed_stake() then
      sol.audio.play_sound("hammer_stake")  -- Successfully pushed a stake.
    else
      sol.audio.play_sound("hammer")  -- No stake was pushed.
    end
    item:set_pushed_stake(false)
  end)
 
  -- Detect enemies and switches with an invisible custom entity.
  local x, y, layer = hero:get_position()
  local direction4 = hero:get_direction()
  if direction4 == 0 then x = x + 12
  elseif direction4 == 1 then y = y - 12
  elseif direction4 == 2 then x = x - 12
  else y = y + 12
  end

  local hammer = game:get_map():create_custom_entity{
    x = x,
    y = y,
    layer = layer,
    width = 8,
    height = 8,
    direction = 0,
  }
  local enemies_touched = { }
  hammer:set_origin(4, 5)
  hammer:add_collision_test("overlapping", function(hammer, entity)
    if entity:get_type() == "enemy" then
      local enemy = entity
      if enemies_touched[enemy] then
        return  -- If protected we don't want to play the sound repeatedly.
      end
      enemies_touched[enemy] = true
      local reaction = enemy:get_attack_hammer(enemy_sprite)
      enemy:receive_attack_consequence("hammer", reaction)
    end
  end)

  -- Start the animation.
  hero:set_animation("hammer", function()
    hero:unfreeze()
    hammer:remove()
  end)
end

function item:has_pushed_stake()
  return item.pushed_stake
end

function item:set_pushed_stake(pushed_stake)
  item.pushed_stake = pushed_stake
end

-- Initialize the metatable of appropriate entities to work with the hammer.
local function initialize_meta()
  -- Add Lua hammer properties to enemies.
  local enemy_meta = sol.main.get_metatable("enemy")
  if enemy_meta.get_attack_hammer ~= nil then
    -- Already done.
    return
  end

  enemy_meta.attack_hammer = 3  -- 3 life points by default.
  enemy_meta.attack_hammer_sprite = {}
  function enemy_meta:get_attack_hammer(sprite)
    if sprite ~= nil and self.attack_hammer_sprite[sprite] ~= nil then
      return self.attack_hammer_sprite[sprite]
    end
    return self.attack_hammer
  end

  function enemy_meta:set_attack_hammer(reaction, sprite)
    self.attack_hammer = reaction
  end

  function enemy_meta:set_attack_hammer_sprite(sprite, reaction)
    self.attack_hammer_sprite[sprite] = reaction
  end

  -- Change the default enemy:set_invincible() to also take into account the hammer.
  local previous_set_invincible = enemy_meta.set_invincible
  function enemy_meta:set_invincible()
    previous_set_invincible(self)
    self:set_attack_hammer("ignored")
  end
  local previous_set_invincible_sprite = enemy_meta.set_invincible_sprite
  function enemy_meta:set_invincible_sprite(sprite)
    previous_set_invincible_sprite(self, sprite)
    self:set_attack_hammer_sprite(sprite, "ignored")
  end
end

initialize_meta()