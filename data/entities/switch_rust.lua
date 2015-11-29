--[[

Script for a custom entity button detecting the hero, npc_heroes, and blocks. Properties (default values are false):
   savegame: if true, the value of "activated" is saved by the game in some variable (with name: map + "button" + x + y + z).
   stay_down: if true, after activation the button stays down.
  The method entity:on_activated() can be defined in the map script, and will be called when the button is pushed or unpushed.
  When activated, calls the function button:on_activated(), if defined by the map. Usage:
  my_button = map:create_custom_entity(properties) -- with: properties.model = "button"
  my_button:set_properties(prop) -- with: prop = {savegame = ..., stay_down = ...}
--]]

local entity = ...

entity.is_block_traversable = true
local savegame = false
local stay_down = false
local button_x, button_y, button_z, sprite
local savegame_variable 
local activated = false
local checking = true

-- Function to set the initial properties after creation, by the map script.
function entity:set_properties(prop)
  if prop.savegame ~= nil then savegame = prop.savegame end
  if prop.stay_down ~= nil then stay_down = prop.stay_down end
  if savegame then 
    activated = entity:get_game():get_value(savegame_variable)
    if activated and stay_down then checking = false; entity:draw_activated(true) end
  end
end

-- Called when this entity has just been created on the map.
function entity:on_created()
  -- Initialize variables and sprite. Starts checking.
  self:set_size(16, 16); self:set_origin(8, 13)
  self:snap_to_grid()
  self.unique_id = entity:get_name()

  button_x, button_y, button_z = entity:get_position()
  local map_name = entity:get_map():get_id()
  savegame_variable = map_name .."_button_".. button_x .."_".. button_y
  sprite = self:get_sprite() -- Create sprite if necessary.
  if not sprite then sprite = entity:create_sprite("entities/switch_rust") end

  entity:draw_activated(false)
  entity:check()
end

-- Function to check if the hero, npc_heroes or blocks are pushing the button.
function entity:check()
  if not checking then return end
  local map = entity:get_map()
  local entity_list = {} -- Create a list of entities that can push the button.

  -- Add custom entities that can push buttons.
  for entity in map:get_entities("") do
    if entity.can_push_buttons then table.insert(entity_list, entity) end
  end

  -- Check if some entity is pushing the button.
  for _, e in pairs(entity_list) do
    if entity:is_under(e) then
      if (not entity:is_activated()) then entity:set_activated(true) end
      sol.timer.start(entity:get_map(), 50, function() entity:check() end)
      return
    end
  end

  -- Hammer also activates switches.
  local hero = entity:get_game():get_hero()

  if hero:get_animation() == "hammer" and entity:is_under_hero_hammer() then
    if (not entity:is_activated()) then entity:set_activated(true) end
    sol.timer.start(entity:get_map(), 50, function() entity:check() end)
    return
  end

  if entity:is_activated() then entity:set_activated(false) end
  sol.timer.start(entity:get_map(), 50, function() entity:check() end)
end

-- Returns boolean. True if the given entity is over the button.
function entity:is_under(entity)
  local x, y, z = entity:get_position()
  return (z == button_z) and (math.abs(x-button_x)<=4) and (math.abs(y-button_y)<=4)
end

function entity:is_under_hero_hammer()
  local hero = entity:get_game():get_hero()

  local x, y, z = hero:get_position()
  local direction4 = hero:get_direction()
  if direction4 == 0 then x = x + 12
  elseif direction4 == 1 then y = y - 12
  elseif direction4 == 2 then x = x - 12
  else y = y + 12 end

  return (z == button_z) and (math.abs(x-button_x)<=8) and (math.abs(y-button_y)<=8)
end

function entity:is_activated()
  return activated
end

-- Called when the button is pushed/unpushed by heroes and blocks.
function entity:set_activated(enable)
  if activated ~= enable then
    activated = enable
    if activated then
      sol.audio.play_sound("switch")
      if stay_down then checking = false end
      if savegame then entity:get_game():set_value(savegame_variable, true) end
    end

    entity:draw_activated(enable)

    -- Call the custom button:function on_activated() when it has been defined (by the map script).
    if enable then
      if entity.on_activated ~= nil then entity:on_activated() end
    else
      if entity.on_inactivated ~= nil then entity:on_inactivated() end
    end
  end
end

-- Draw the button pushed or not pushed.
function entity:draw_activated(enable)
  if enable then sprite:set_animation("activated") else sprite:set_animation("inactivated") end 
end

-- Functions to save and get saved info between maps.
function entity:get_saved_info()
  local info = {savegame = savegame, stay_down = stay_down,
  savegame_variable = savegame_variable, activated = activated}
  return info
end

function entity:set_saved_info(info)
  savegame = info.savegame; stay_down = info.stay_down
  savegame_variable = info.savegame_variable
  if activated ~= info.activated then 
    entity:set_activated(activated)
    activated = info.activated
  end
end