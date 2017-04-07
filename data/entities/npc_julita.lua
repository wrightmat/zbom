local entity = ...
local game = entity:get_game()
local map = game:get_map()

-- Julita is the mothers of Crista who runs the potion
-- shop. She's also a mother-like figure to our hero.

if game:get_value("i1027")==nil then game:set_value("i1027", 0) end
if game:get_value("i1029")==nil then game:set_value("i1029", 0) end
if game:get_value("i1032")==nil then game:set_value("i1032", 0) end
if game:get_value("i1903")==nil then game:set_value("i1903", 0) end

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
  if map:get_id() == "1" then
    if game:get_value("i1032") >= 3 then
      -- Julita and Crista switch places at this time:
      -- Julita running the shop, Crista at home. 
      self:set_position(272, 469)
    else
      -- Normally Julita is at home and Crista is at the shop.
      self:set_position(1096, 533)
    end
  end
end

function entity:on_interaction()
  -- First, make the NPC face the hero when interacting
  self:get_sprite():set_direction(self:get_direction4_to(game:get_hero()))
  
  if map:get_id() == "10" then
    if game:get_value("i1027") >= 5 then
      game:start_dialog("julita.2.thanks")
    elseif game:get_value("i1027") >= 4 then
      game:start_dialog("julita.1", game:get_player_name(), function()
        game:set_value("i1903", 2)
        if map:get_entity("quest_julita") ~= nil then map:get_entity("quest_julita"):remove() end
        if not game:has_item("shield") then game:start_dialog("julita.1.shield") end
      end)
    elseif game:get_value("i1027") < 4 then
      game:start_dialog("julita.0.festival", function(answer)
        if answer == 1 then
          if game:get_magic() then
            game:add_magic(20)
            game:start_dialog("julita.0.festival_yes")
          else
            game:start_dialog("julita.0.festival_magic")
          end
        else
          game:start_dialog("julita.0.festival_no")
        end
        game:set_value("i1903", 1)
      end)
    else
      game:start_dialog("julita.0")
    end
  elseif game:get_value("i1029") >= 6 then
    game:start_dialog("julita.4.house")
  else
    game:start_dialog("julita.3.house")
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