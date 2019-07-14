-- Control the hero with the mouse/touch.
local mouse_movement_builder = {}

function mouse_movement_builder:new(game)
  local mouse_movement = {}
  
  function mouse_movement:initialize()
    left_button_pressed = false
    
    -- Movement of the hero.
    directions = {
  	  right = false,
  	  up = false,
  	  left = false,
  	  down = false
    }
    
    deadzone_ray = 10 -- Should be set to the max number of pixel that the hero can move in one frame.
  end
  
  function mouse_movement:on_mouse_pressed(button, x, y)
    if game ~= nil and game:get_map() ~= nil then
      left_button_pressed = true
    end 
  end
  
  function mouse_movement:on_mouse_released(button, x, y)
    if game ~= nil and game:get_map() ~= nil then
      left_button_pressed = false
    end
  end
  
  function mouse_movement:on_update()
    if left_button_pressed and game:get_value("control_scheme") == "touch_2" then
      -- Only enable mouse/touch movement if "Full Touch" scheme is enabled.
      local camera = game:get_map():get_camera()
      local hero_x, hero_y = game:get_map():get_hero():get_position()
      local camera_x, camera_y = camera:get_position()
      local mouse_x, mouse_y = sol.input.get_mouse_position()
      mouse_x = mouse_x + camera_x
      mouse_y = mouse_y + camera_y
      -- Compare the position of the hero and the mouse 
      -- and simulate the appropriate command for each directions.
      self:update_direction("right", mouse_x > hero_x + deadzone_ray)
      self:update_direction("up", mouse_y < hero_y - deadzone_ray)
      self:update_direction("left", mouse_x < hero_x - deadzone_ray)
      self:update_direction("down", mouse_y > hero_y + deadzone_ray)
    else
      for direction, _ in pairs(directions) do
        self:release_direction(direction)
      end
    end
  end
  
  function mouse_movement:update_direction(direction, condition)
    if condition then
      if not directions[direction] then
        directions[direction] = true
        game:simulate_command_pressed(direction)
      end
    else self:release_direction(direction) end
  end
  
  function mouse_movement:release_direction(direction)
    if directions[direction] then
      directions[direction] = false
      game:simulate_command_released(direction)
    end
  end
  
  mouse_movement:initialize()
  return mouse_movement
end

return mouse_movement_builder