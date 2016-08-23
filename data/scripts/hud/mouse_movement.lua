-- Control the hero with the mouse.

local mouse_movement_builder = {}

function mouse_movement_builder:new(game)
  local mouse_movement = {}
  
  function mouse_movement:initialize()
    left_button_pressed = false
    
    -- Movement of the hero.
    directions = {
  	  {"right", false},
  	  {"up", false},
  	  {"left", false},
  	  {"down", false}
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
      -- Only enable mouse/touch movement if "iOS" scheme is enabled - Android will use a D-Pad overlay (more precise).
      local mouse_position = {sol.input.get_mouse_position()}
      local hero_position = {game:get_hero():get_solid_ground_position()}
      
      -- Compare the position of the hero and the mouse 
      -- and simulate the appropriate command for each directions.
      self:update_direction(1, mouse_position[1] > hero_position[1] + deadzone_ray)
      self:update_direction(2, mouse_position[2] < hero_position[2] - deadzone_ray)
      self:update_direction(3, mouse_position[1] < hero_position[1] - deadzone_ray)
      self:update_direction(4, mouse_position[2] > hero_position[2] + deadzone_ray)
    else
      for i=1, 4, 1 do 
        self:release_direction(i)
      end
    end
  end
  
  function mouse_movement:update_direction(direction_id, condition)
    if condition then
      if not directions[direction_id][2] then
        directions[direction_id][2] = true
        game:simulate_command_pressed(directions[direction_id][1])
      end
    else
      self:release_direction(direction_id)
    end
  end
  
  function mouse_movement:release_direction(direction_id)
    if directions[direction_id][2] then
      directions[direction_id][2] = false
      game:simulate_command_released(directions[direction_id][1])
    end
  end
  
  mouse_movement:initialize()
  
  return mouse_movement
end

return mouse_movement_builder