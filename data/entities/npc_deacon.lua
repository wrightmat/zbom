local entity = ...
local game = entity:get_game()
local map = entity:get_game():get_map()
local hero = entity:get_game():get_hero()
local name = string.sub(entity:get_name(), 5):gsub("^%l", string.upper)
local font, font_size = sol.language.get_dialog_font()

if game:get_value("i1602")==nil then game:set_value("i1602", 0) end
if game:get_value("i1913")==nil then game:set_value("i1913", 0) end

-- Deacon is a minor NPC who lives outside of Ordon.
-- He is a lumberjack who helps direct our hero through the woods.
-- There is a small "match maker" sidequest between Deacon and Gaira.

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
end

function entity:on_interaction()
  -- First, make the NPC face the hero when interacting and put name above the dialog box.
  self:get_sprite():set_direction(self:get_direction4_to(hero))
  game:set_dialog_name(name)
  
  if game:get_value("b1117") and not game:get_value("b1134") then
    -- Finished Mausoleum but not Lakebed, so direct to Lake Hylia.
    game:start_dialog("deacon.6.house")
    game:set_value("i1030", 1)
  elseif game:get_value("i1602") == 6 then
    game:start_dialog("deacon.5.faron", game:get_player_name())
  elseif game:get_value("i1602") == 3 then
    game:start_dialog("deacon.3.house", function() game:set_value("i1602", 4) end)
  elseif game:get_value("i1602") == 1 then
    game:start_dialog("deacon.2.faron", function() game:set_value("i1602", 2) end)
  else
    if game:get_value("i1913") >= 3 and not game:get_value("b1134") then
      game:start_dialog("deacon.6.house")
      game:set_value("i1030", 1)
    elseif game:get_value("i1913") == 1 then
      game:start_dialog("deacon.1.faron")
    else
      game:start_dialog("deacon.0.faron")
    end
  end
  game:set_value("i1913", game:get_value("i1913")+1)
end

function entity:on_movement_changed(movement)
  local direction = movement:get_direction4()
  entity:get_sprite():set_direction(direction)
end

function entity:on_post_draw()
  if game:get_value("i1913") > 0 then
    -- Draw the NPC's name above the entity.
    local name_surface = sol.text_surface.create({ font = font, font_size = 8, text = name })
    local x, y, l = entity:get_position()
    local w, h = entity:get_sprite():get_size()
    if self:get_distance(hero) < 100 then
      entity:get_map():draw_visual(name_surface, x-(w/2), y-(h-4))
    end
  end
end