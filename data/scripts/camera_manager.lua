local camera_manager = {}
local camera_speed = 128

-- This script moves the camera when pressing Ctrl + direction.

function camera_manager:create(game)
  local camera_menu = {}

  local moving = false
  local initial_x, initial_y, camera_width, camera_height

  -- Moves the camera back to the hero.
  local function restore_camera()
    if not moving then
      return
    end

    local map = game:get_map()
    if map == nil then
      return
    end

    local hero = map:get_hero()
    local hero_x, hero_y = hero:get_center_position()

    map:move_camera(hero_x, hero_y, camera_speed, function() end, 0, 0)
    moving = false
  end

  -- Updates the camera movement depending on commands pressed.
  local function update_camera()
    if game:is_suspended() and not moving then
      -- The game is suspended for a reason other than us: don't
      -- do a camera movement now.
      return
    end

    local map = game:get_map()
    if map == nil then
      return
    end

    local hero = map:get_hero()
    if hero:get_state() ~= "free" then
      -- Don't interrupt special states.
      return
    end

    if not sol.input.is_key_pressed("left control") and
        not sol.input.is_key_pressed("right control") then
      -- Releasing control: restore the camera.
      restore_camera()
      return
    end

    local right = game:is_command_pressed("right")
    local up = game:is_command_pressed("up")
    local left = game:is_command_pressed("left")
    local down = game:is_command_pressed("down")

    if not right and not up and not left and not down then
      restore_camera()
      return
    end

    if not moving then
      initial_x, initial_y, camera_width, camera_height = map:get_camera_position()
    end
    moving = true

    local dx = 0
    if right and not left then
      dx = 64
    elseif left and not right then
      dx = -64
    end

    local dy = 0
    if down and not up then
      dy = 64
    elseif up and not down then
      dy = -64
    end

    local x = initial_x + camera_width / 2 + dx
    local y = initial_y + camera_height / 2 + dy

    map:move_camera(x, y, camera_speed, function()
      local current_x, current_y = map:get_camera_position()
      if sol.main.get_distance(current_x, current_y, initial_x, initial_y) < 4 then
        -- The camera did not move because of separators or because of a small map.
        -- In this case, don't keep the game suspended but restore control to the player.
        restore_camera()
      end
    end, 0, 1e9)
  end

  function camera_menu:on_command_pressed(command)
    local handled = false
    local control = sol.input.is_key_pressed("left control") or sol.input.is_key_pressed("right control")
    if control and
        (command == "right" or command == "up" or command == "left" or command == "down") then
      update_camera()
      handled = true
    end

    return handled
  end

  function camera_menu:on_command_released(command)
    local handled = false
    if not moving then
      return handled
    end

    if command == "right" or command == "up" or command == "left" or command == "down" then
      update_camera()
      handled = true
    end

    return handled
  end

  function camera_menu:on_key_released(key)
    local handled = false
    if not moving then
      return handled
    end

    if key == "left control" or key == "right control" then
      update_camera()
      handled = true
    end

    return handled
  end
  sol.menu.start(game, camera_menu)

  return camera_menu
end

return camera_manager