local condition_manager = {}
local in_command_pressed = false
local in_command_release = false

condition_manager.timers = {
  slow = nil,
  frozen = nil,
  poison = nil,
  confusion = nil,
  electrocution = nil,
}

function condition_manager:initialize(game)
  local hero = game:get_hero()
  hero.condition = {
    slow = false,
    frozen = false,
    poison = false,
    confusion = false,
    electrocution = false
  }

  function hero:is_condition_active(condition)
    return hero.condition[condition]
  end

  function hero:set_condition(condition, active)
    hero.condition[condition] = active
  end

  function game:on_command_pressed(command)
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
    --print(damage,in_damage,protection_divider,tunic_level,shield_level)
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
end

return condition_manager
