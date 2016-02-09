local entity = ...
local game = entity:get_game()
local map = entity:get_game():get_map()

-- Generic NPC script which prevents the hero from being stuck
-- behind non-traversable moving characters (primarily for intro).

local function random_walk()
  local m = sol.movement.create("random_path")
  m:set_speed(32)
  m:start(entity)
  entity:get_sprite():set_animation("walking")
end

local function follow_hero()
 sol.timer.start(entity, 500, function()
  local hero_x, hero_y, hero_layer = hero:get_position()
  local npc_x, npc_y, npc_layer = entity:get_position()
  local distance_hero = math.abs((hero_x+hero_y)-(npc_x+npc_y))
  local m = sol.movement.create("target")
  m:set_ignore_obstacles(false)
  m:set_speed(40)
  m:start(entity)
  entity:get_sprite():set_animation("walking")
 end)
end

function entity:on_created()
  self:set_drawn_in_y_order(true)
  self:set_can_traverse("hero", false)
  self:set_traversable_by("hero", false)
  -- Don't allow NPC to traverse other NPCs when moving.
  self:set_traversable_by("npc", false)
  self:set_traversable_by("custom_entity", false)

  sol.timer.start(self, 1000, function()
    -- If too close to the hero, become traversable so as not to trap hero in a corner.
    -- TODO in the future? Check to see if the movement type is "target" because it's only needed when the NPC is following and this does odd things on "random_path" movements.
    -- if self:get_movement():get_type() == "target" then
    local _, _, layer = self:get_position()
    local _, _, hero_layer = map:get_hero():get_position()
    local near_hero = layer == hero_layer and self:get_distance(map:get_hero()) < 17
    if near_hero then self:set_traversable_by("hero", true) end

    return true
  end)
end

function entity:on_movement_changed(movement)
  local direction = movement:get_direction4()
  entity:get_sprite():set_direction(direction)
end

-- Change HUD action to "Speak" when facing the NPC.
entity:add_collision_test("facing", function(entity, other)
  if other:get_type() == "hero" then 
    hero_facing = true
    if hero_facing then
      game:set_custom_command_effect("action", "speak")
      action_command = true
    else
      game:set_custom_command_effect("action", nil)
    end
  end
end)

function entity:on_update()
  if action_command and not hero_facing then
    game:set_custom_command_effect("action", nil)
    action_command = false
  end
  hero_facing = false
end