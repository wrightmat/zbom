local entity = ...
local game = entity:get_game()
local map = entity:get_game():get_map()
local hero = game:get_map():get_entity("hero")
local name = string.sub(entity:get_name(), 5):gsub("^%l", string.upper):gsub("_", " ")
local font, font_size = sol.language.get_dialog_font()

-- Generic NPC script which prevents the hero from being stuck
-- behind non-traversable moving characters (primarily for intro).

local function random_walk()
  local m = sol.movement.create("random_path")
  m:set_ignore_obstacles(false)
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
    -- If too close to the hero (and moving), become traversable so as not to trap hero in a corner.
    if self:get_movement() ~= nil then
      local _, _, layer = self:get_position()
      local _, _, hero_layer = map:get_hero():get_position()
      local near_hero = layer == hero_layer and self:get_distance(hero) < 17
      if near_hero then
        self:set_traversable_by("hero", true)
      else
        self:set_traversable_by("hero", false)
      end
    end
    return true
  end)
end

function entity:on_movement_changed(movement)
  local direction = movement:get_direction4()
  entity:get_sprite():set_direction(direction)
end

entity:register_event("on_interaction", function()
  entity:get_sprite():set_direction(entity:get_direction4_to(hero))
  -- This doesn't run (because a map function also exists), which I believe is an engine bug.
  -- Leaving it here so the NPC name will display when the bug is fixed.
  game:set_dialog_name(name)
end)

function entity:on_post_draw()
  -- Draw the NPC's name above the entity.
  local name_surface = sol.text_surface.create({ font = font, font_size = 8, text = name })
  local x, y, l = entity:get_position()
  local w, h = entity:get_sprite():get_size()
  if self:get_distance(hero) < 100 then
    entity:get_map():draw_visual(name_surface, x-(w/2), y-(h-4))
  end
end