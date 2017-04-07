local entity = ...
local game = entity:get_game()
local map = entity:get_game():get_map()

if game:get_value("i1027")==nil then game:set_value("i1027", 0) end
if game:get_value("i1032")==nil then game:set_value("i1032", 0) end
if game:get_value("i1905")==nil then game:set_value("i1905", 0) end

-- Bilo is a minor NPC who lives in Ordon.
-- He can be found traveling around, looking for a more permanent home.

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
  if map:get_id() == "32" then random_walk() end
end

function entity:on_interaction()
  -- First, make the NPC face the hero when interacting
  self:get_sprite():set_direction(self:get_direction4_to(game:get_hero()))

  if map:get_id() == "32" then
    game:start_dialog("bilo.0.field")
  else
    if game:get_value("i1027") < 5 then
      game:start_dialog("bilo.0.festival")
    elseif game:get_value("i1032") >= 3 then
      game:start_dialog("bilo.2")
    elseif game:get_value("i1905") >= 1 and game:get_value("i1027") >= 4 then
      game:start_dialog("bilo.1")
    else
      game:start_dialog("bilo.0")
    end
  end
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