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
  self.action_effect = "speak"
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

function entity:on_post_draw()
  -- Draw the NPC's name above the entity.
  local name = string.sub(entity:get_name(), 5):gsub("^%l", string.upper)
  local name_surface = sol.text_surface.create({ font = 'bom', font_size = 11, text = name })
  local x, y, l = entity:get_position()
  local w, h = entity:get_sprite():get_size()
  if self:get_distance(map:get_hero()) < 100 then
    entity:get_map():draw_visual(name_surface, x-(w/2), y-(h-4))
  end
end