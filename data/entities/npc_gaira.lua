local entity = ...
local game = entity:get_game()
local map = entity:get_game():get_map()
local hero = entity:get_game():get_hero()
local name = string.sub(entity:get_name(), 5):gsub("^%l", string.upper)
local font, font_size = sol.language.get_dialog_font()

if game:get_value("i1602")==nil then game:set_value("i1602", 0) end
if game:get_value("i1911")==nil then game:set_value("i1911", 0) end

-- Gaira is a minor NPC who lives in Ordon.
-- She can be found in the north area of town, as a groundskeeper.
-- Speaking to her can trigger the "Lumberjack Love" sidequest.

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
  m:set_speed(48)
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
  
  if map:get_id() == "17" then
    -- Outside of Deacon's house.
    if game:get_value("i1602") == 3 then
      game:start_dialog("gaira.4.faron")
    end
  elseif map:get_id() == "16" then
    if game:get_value("i1602") >= 2 then
      game:start_dialog("gaira.3.faron", function() game:set_value("i1602", 3) end)
      follow_hero(npc_gaira)
    else
      game:start_dialog("gaira.2.faron")
    end
  -- Inside Deacon's house.
  elseif map:get_id() == "1" then
    if not game:get_value("b1722") then
      game:start_dialog("gaira.5.faron", game:get_player_name(), function()
        hero:start_treasure("heart_piece", 1, "b1722")
      end)
    elseif game:get_value("i1030") < 2 then
      game:start_dialog("gaira.6.house")
    else
      game:start_dialog("gaira.5.forest")
    end
  -- Ordon Village
  else
    if game:get_value("i1911") == 1 then
      game:start_dialog("gaira.1.ordon", function()
        game:set_value("i1911", game:get_value("i1911")+1)
      end)
    elseif game:get_value("i1911") == 2 and (not game:get_value("b1699") and game:get_value("i1603") >= 5) then
      game:start_dialog("gaira.2.ordon", function()
        game:set_value("i1911", game:get_value("i1911")+1)
        game:set_value("i1602", 1)
      end)
    else
      game:start_dialog("gaira.0.ordon", function()
        game:set_value("i1911", game:get_value("i1911")+1)
      end)
    end
  end
end

function entity:on_movement_changed(movement)
  local direction = movement:get_direction4()
  entity:get_sprite():set_direction(direction)
end

function entity:on_post_draw()
  -- Draw the NPC's name above the entity.
  local name_surface = sol.text_surface.create({ font = font, font_size = 8, text = name })
  local x, y, l = entity:get_position()
  local w, h = entity:get_sprite():get_size()
  if self:get_distance(hero) < 100 then
    entity:get_map():draw_visual(name_surface, x-(w/2), y-(h-4))
  end
end