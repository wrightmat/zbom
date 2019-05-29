local shader_manager = {}

local shader_ids
local shaders
local current_shader_index = 0  -- 0 means no shader.

local function initialize_shaders()
  shaders = {}
  shader_ids = sol.main.get_resource_ids("shader")
  current_shader_index = 0
end

local function get_shader(index)
  if shaders[index] == nil then
    shaders[index] = sol.shader.create(shader_ids[index])
    -- TODO check for errors
  end
  return shaders[index]
end

function shader_manager:switch_shader()
  if shaders == nil then
    initialize_shaders()
  end

  if #shader_ids == 0 then
    return
  end

  current_shader_index = current_shader_index + 1
  if current_shader_index > #shader_ids then
    current_shader_index = 0
  end

  if current_shader_index == 0 then
    sol.video.set_shader(nil)
  else
    sol.video.set_shader(get_shader(current_shader_index))
  end
end

return shader_manager