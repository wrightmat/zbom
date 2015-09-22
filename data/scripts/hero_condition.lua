local condition_manager = {}
local in_command_pressed = false
local in_command_release = false
local sword_level = 0

condition_manager.timers = {
  slow = nil,
  frozen = nil,
  poison = nil,
  confusion = nil,
  electrocution = nil,
  cursed = nil
}

function condition_manager:initialize(game)
  local hero = game:get_hero()
  hero.condition = {
    slow = false,
    frozen = false,
    poison = false,
    confusion = false,
    electrocution = false,
    cursed = false,
    exhausted = false
  }

  function hero:is_condition_active(condition)
    return hero.condition[condition]
  end

  function hero:set_condition(condition, active)
    hero.condition[condition] = active
  end

  function game:on_command_pressed(command)

    if command == "action" then
      local action_effect = game:get_custom_command_effect("action")
      -- Custom action effects. THIS IS NEEDED FOR THE GENERIC_PORTABLE.LUA SCRIPT!!!!
      if action_effect and game:get_interaction_entity() then
        game:get_hero().custom_interaction:on_custom_interaction(); return true
      elseif game:get_hero().custom_carry then
        game:get_hero().custom_carry:throw(); return true
      end
    end

    -- It takes stamina to use an attack, action or item - but only if it's actually equipped
    if (command == "item_1" or command == "item_2" or command == "attack" or command == "action") and game:get_command_effect(command) ~= nil then
      if (command == "item_1" and game:get_item_assigned(1) == nil) or (command == "item_2" and game:get_item_assigned(2) == nil) then return false end
      if game:get_max_stamina() > 0 then
        if game:get_stamina() == 0 then
	if not hero:is_condition_active('exhausted') then -- when stamina out, set exhaustion
           hero:set_condition('exhausted', true)
	  if not game:get_value("exhausted_once") then
             game:start_dialog("_exhausted")
             game:set_value("exhausted_once", true)
           end
	else
	  if math.random(4) == 1 then  -- when stamina out, buttons don't always work
	    sol.audio.play_sound("wrong")
	    return true
	  else
	    return false
	  end
	end
        elseif game:get_stamina() < (game:get_max_stamina()/6) then -- if stamina too low, play heavy breathing
	game:remove_stamina(1)
	hero:set_condition('exhausted', false)
	if not breathing_timer then
	  breathing_timer = sol.timer.start(8000, function()
	    sol.audio.play_sound("breathing")
	    return true
	  end)
	end
	return false
        else
	game:remove_stamina(1)
	hero:set_condition('exhausted', false)
	if breathing_timer ~= nil then breathing_timer:stop() end
	return false
        end --game:get_stamina() == 0
      end --game:get_max_stamina() > 0
    end

    if not hero:is_condition_active('confusion') or in_command_pressed or game:is_paused() then
      return false
    end

    if command == "left" then
      game:simulate_command_released("left")
      in_command_pressed = true
      game:simulate_command_pressed("right")
      in_command_pressed = false
      return true
    elseif command == "right" then
      game:simulate_command_released("right")
      in_command_pressed = true
      game:simulate_command_pressed("left")
      in_command_pressed = false
      return true
    elseif command == "up" then
      game:simulate_command_released("up")
      in_command_pressed = true
      game:simulate_command_pressed("down")
      in_command_pressed = false
      return true
    elseif command == "down" then
      game:simulate_command_released("down")
      in_command_pressed = true
      game:simulate_command_pressed("up")
      in_command_pressed = false
      return true
    end
    return false
  end

  function game:on_command_released(command)
    if not hero:is_condition_active('confusion') or in_command_release or game:is_paused() then
      return false
    end

    if command == "left" then
      in_command_release = true
      game:simulate_command_released("right")
      in_command_release = false
      return true
    elseif command == "right" then
      in_command_release = true
      game:simulate_command_released("left")
      in_command_release = false
      return true
    elseif command == "up" then
      in_command_release = true
      game:simulate_command_released("down")
      in_command_release = false
      return true
    elseif command == "down" then
      in_command_release = true
      game:simulate_command_released("up")
      in_command_release = false
      return true
    end
    return false
  end

  function hero:on_taking_damage(in_damage)
    local damage = in_damage

    if hero:is_condition_active('frozen') then
      damage = damage * 3
      hero:stop_frozen(true)
    end

    if damage == 0 then
      return
    end

    local shield_level = game:get_ability('shield')
    local tunic_level = game:get_ability('tunic')

    local protection_divider = tunic_level * math.ceil(shield_level / 2)
    if protection_divider == 0 then
      protection_divider = 1
    end
    damage = math.floor(damage / protection_divider)

    if damage < 1 then
      damage = 1
    end

    game:remove_life(damage)
  end

  function hero:start_confusion(delay)
    local aDirectionPressed = {
      right = false,
      left = false,
      up = false,
      down = false
    }
    local bAlreadyConfused = hero:is_condition_active('confusion')

    if hero:is_condition_active('confusion') and condition_manager.timers['confusion'] ~= nil then
      condition_manager.timers['confusion']:stop()
    end

    if not bAlreadyConfused then
      for key, value in pairs(aDirectionPressed) do
        if game:is_command_pressed(key) then
          aDirectionPressed[key] = true
          game:simulate_command_released(key)
        end
      end
    end

    hero:set_condition('confusion', true)
    if not game:get_value("confusion_once") then
      game:start_dialog("_confusion")
      game:set_value("confusion_once", true)
    end

    condition_manager.timers['confusion'] = sol.timer.start(hero, delay, function()
      hero:stop_confusion()
    end)

    if not bAlreadyConfused then
      for key, value in pairs(aDirectionPressed) do
        if value then
          game:simulate_command_pressed(key)
        end
      end
    end
  end

  function hero:start_frozen(delay)
    if hero:is_condition_active('frozen') then
      return
    end

    hero:freeze()
    hero:set_animation("frozen")
    sol.audio.play_sound("freeze")

    hero:set_condition('frozen', true)
    condition_manager.timers['frozen'] = sol.timer.start(hero, delay, function()
      hero:stop_frozen()
    end)
  end

  function hero:start_electrocution(delay)
    if hero:is_condition_active('electrocution') then
      return
    end

    hero:freeze()
    hero:set_animation("electrocuted")
    sol.audio.play_sound("spark")
    game:remove_life(2)

    hero:set_condition('electrocution', true)
    condition_manager.timers['electrocution'] = sol.timer.start(hero, delay, function()
      hero:stop_electrocution()
    end)
  end

  function hero:start_poison(damage, delay, max_iteration)
    if hero:is_condition_active('poison') and condition_manager.timers['poison'] ~= nil then
      condition_manager.timers['poison']:stop()
    end

    local iteration_poison = 0
    function do_poison()
      if hero:is_condition_active("poison") and iteration_poison < max_iteration then
        sol.audio.play_sound("hero_hurt")
        game:remove_life(damage)
        iteration_poison = iteration_poison + 1
      end

      if iteration_poison == max_iteration then
        hero:set_blinking(false)
        hero:set_condition('poison', false)
      else
        condition_manager.timers['poison'] = sol.timer.start(hero, delay, do_poison)
      end
    end

    hero:set_blinking(true, delay)
    hero:set_condition('poison', true)
    if not game:get_value("poison_once") then
      game:start_dialog("_poison")
      game:set_value("poison_once", true)
    end
    do_poison()
  end

  function hero:start_slow(delay)
    if hero:is_condition_active('slow') and condition_manager.timers['slow'] ~= nil then
      condition_manager.timers['slow']:stop()
    end

    hero:set_condition('slow', true)
    hero:set_walking_speed(48)
    condition_manager.timers['slow'] = sol.timer.start(hero, delay, function()
      hero:stop_slow()
    end)
  end

  function hero:start_cursed(delay)
    if hero:is_condition_active('cursed') and condition_manager.timers['cursed'] ~= nil then
      condition_manager.timers['cursed']:stop()
    else
      hero:set_condition('cursed', true)
      if game:get_ability("sword") > 0 then sword_level = game:get_ability("sword") end
      game:set_ability("sword", 0)
      if not game:get_value("cursed_once") then
        game:start_dialog("_cursed")
        game:set_value("cursed_once", true)
      end

      condition_manager.timers['cursed'] = sol.timer.start(hero, delay, function()
        hero:stop_cursed()
      end)
    end
  end

  function hero:stop_confusion()
    local aDirectionPressed = {
      right = {"left", false},
      left = {"right", false},
      up = {"down", false},
      down = {"up", false}
    }

    if hero:is_condition_active('confusion') and condition_manager.timers['confusion'] ~= nil then
      condition_manager.timers['confusion']:stop()
    end

    for key, value in pairs(aDirectionPressed) do
      if game:is_command_pressed(key) then
        aDirectionPressed[key][2] = true
        game:simulate_command_released(key)
      end
    end

    hero:set_condition('confusion', false)

    for key, value in pairs(aDirectionPressed) do
      if value[2] then
        game:simulate_command_pressed(value[1])
      end
    end
  end

  function hero:stop_frozen()
    if hero:is_condition_active('frozen') and condition_manager.timers['frozen'] ~= nil then
      condition_manager.timers['frozen']:stop()
    end

    hero:unfreeze()
    hero:set_animation("walking")
    hero:set_condition('frozen', false)
    sol.audio.play_sound("ice_shatter")
  end

  function hero:stop_electrocution()
    if hero:is_condition_active('electrocution') and condition_manager.timers['electrocution'] ~= nil then
      condition_manager.timers['electrocution']:stop()
    end

    hero:unfreeze()
    hero:set_animation("walking")
    hero:set_condition('electrocution', false)
  end

  function hero:stop_slow()
    if hero:is_condition_active('slow') and condition_manager.timers['slow'] ~= nil then
      condition_manager.timers['slow']:stop()
    end

    hero:set_condition('slow', false)
    hero:set_walking_speed(88)
  end

  function hero:stop_cursed()
    if hero:is_condition_active('cursed') and condition_manager.timers['cursed'] ~= nil then
      condition_manager.timers['cursed']:stop()
    end

    hero:set_condition('cursed', false)
    game:set_ability("sword", sword_level)
  end
end

return condition_manager