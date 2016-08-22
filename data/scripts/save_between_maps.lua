
--[[ 
Script to save position/state of custom entity when left behind in some map.

In case the state of the entity is complex, two methods should be included in the script of the entity:
entity:get_saved_info() -- Return a list with the info of the extra properties to save.
entity:set_saved_info(properties) -- Load a list with info of the extra properties to load.
In case these methods are nil, only the position and direction of the entity will be saved.

There are some functions used to disable all teletransporters when some generic_portable entity is 
thrown, or when the hero is jumping.

To make some entities unique (they appear only in one of the current maps), give a string value to "entity.unique id"

To make an entity independent, so that it preserves its position/state in any map, set entity.is_independent = true,
and also give a value to entity.unique id (this is necessary). Independent entities are unique. To decide if an
independent entity will change map (following the hero), define a boolean function called
entity:can_change_map_now(). (This is not necessary if the independent entity is carried by the hero!!!)
--]]

local save_between_maps = {}

-- Function called when the player goes to another map. Save the state of some the entities left in the map.
function save_between_maps:save_map(map) 
  local game = map:get_game(); local hero = game:get_hero()
  local map_info = {}
  -- Save carried entity, if any. This includes independent entities.
  if hero.custom_carry then
    self.custom_carry = self:get_entity_info(hero.custom_carry)
  end
  -- Save remaining entities (not carried by the hero).
  self.following_entities = {}
  for entity in map:get_entities("") do
    -- Save independent entities left on the map.
    if entity.is_independent and hero.custom_carry ~= entity then
      local is_changing_map = false
      if entity.can_change_map_now then is_changing_map = entity:can_change_map_now() end
      local entity_properties = self:get_entity_info(entity)
      if not entity.unique_id then error("Variable entity.unique_id not defined.") end
      if entity_properties then 
        if is_changing_map then
          self.following_entities[entity.unique_id] = entity_properties
        else
          game.independent_entities[entity.unique_id] = entity_properties
        end
      end
    end
  end
end

-- Return a list with the info from custom entities which are carried or independent.
function save_between_maps:get_entity_info(entity)
  local entity_properties
  local hero = entity:get_map():get_hero()
  if entity.is_independent or hero.custom_carry == entity then
	  --Save type, position and direction.
    entity_properties = {}
	  local x,y,layer = entity:get_position()
    local name = entity:get_name()
    local sprite = entity:get_sprite()
    local animation_set = sprite:get_animation_set()
    local model = entity:get_model()
    local direction = sprite:get_direction()
    entity_properties.properties = {x = x, y = y, width = 16, height = 16, layer = layer, name = name, sprite = animation_set, model = model, 
        direction = direction, entity_type = "custom_entity"}
  end
  if entity_properties then
    if entity.get_saved_info ~= nil then entity_properties.extra_properties = entity:get_saved_info() end
    entity_properties.unique_id = entity.unique_id -- Get  unique id.
    entity_properties.is_independent = entity.is_independent
    entity_properties.map = entity:get_map():get_id() -- Get map.
  end
  return entity_properties
end

-- Create entity on the map with the saved info.
function save_between_maps:create_entity(map, info)
  local entity = map:create_custom_entity(info.properties)
  if info.extra_properties then entity:set_saved_info(info.extra_properties) end
  entity.unique_id = info.unique_id -- Set entity unique id.
  entity.is_independent = info.is_independent
  return entity
end

-- Start the map with the saved information. This includes entities being carried by the hero.
function save_between_maps:load_map(map)
  local game = map:get_game(); local hero = map:get_hero()
  -- Create carried entity for the current hero, if any.
  local info = self.custom_carry
  if info then
    local portable = save_between_maps:create_entity(map, info)
    hero.custom_carry = portable
    self.custom_carry = nil
  end
  -- Create independent entities left on this map.
  for unique_id, entity_info in pairs(game.independent_entities) do
    if entity_info.map == map:get_id() then
      local entity = save_between_maps:create_entity(map, entity_info)
      entity.is_independent = true
      game.independent_entities[unique_id] = nil -- Destroy the info.
    end
  end  
  -- Create independent entities that are following the hero (excluding carried entities).
  if self.following_entities then
    for _, entity_info in pairs(self.following_entities) do
      local x, y, layer = hero:get_position()
      entity_info.properties.x = x; entity_info.properties.y = y; entity_info.properties.layer = layer
      save_between_maps:create_entity(map, entity_info)
    end
    self.following_entities = nil
  end
end

-- Returns boolean. True if the entity of this unique_id exists in some of the current maps.
function save_between_maps:entity_exists(game, unique_id)
  -- Check if the entity exists in the current map.
  local map = game:get_map()
  for e in map:get_entities("") do
    if e.unique_id == unique_id then return true end
  end
  -- Check again for carried entities and followers (that may have not been created yet).
  if self.custom_carry then if self.custom_carry.unique_id == unique_id then return true end end
  if self.following_entities then
    if self.following_entities[unique_id] ~= nil then return true end
  end
  -- Check if the entity exists in some other map.
  if game.independent_entities[unique_id] ~= nil then return true end
  -- Return false otherwise.
  return false
end

-- Disable all active teletransporters in the map. This is called when some entity starts falling, or if the hero starts jumping.
function save_between_maps:disable_teletransporters(map)
  -- Get enabled teletransporters and disable them temporarily, during 1 second approximately.
  if not map.enabled_teletransporters then map.enabled_teletransporters = {} end
  for e in map:get_entities("") do
    if e:get_type() == "teletransporter" and e:is_enabled() then
      e:set_enabled(false)
      table.insert(map.enabled_teletransporters, e) 
    end
  end
  local timer = map.disabling_teletransporters_timer
  if timer then
    -- Restart remaining time of the timer.
    timer:set_remaining_time(1050)
  else
    -- Create timer to reactivate teletransporters.
    map.disabling_teletransporters_timer = sol.timer.start(map, 1050, function()
      for _, e in pairs(map.enabled_teletransporters) do
        e:set_enabled(true)
      end
      map.enabled_teletransporters = nil
      map.disabling_teletransporters_timer = nil
    end)
  end
end

return save_between_maps