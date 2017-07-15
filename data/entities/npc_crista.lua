local entity = ...
local game = entity:get_game()
local map = entity:get_game():get_map()
local hero = game:get_map():get_entity("hero")
local name = string.sub(entity:get_name(), 5):gsub("^%l", string.upper)
local font, font_size = sol.language.get_dialog_font()
local last_speak = 0

-- Crista is a major NPC who lives in Ordon and makes/sells
-- potions. Childhood friend and potential love interest of our hero.

if game:get_value("i1032")==nil then game:set_value("i1032", 0) end
if game:get_value("i1068")==nil then game:set_value("i1068", 0) end
if game:get_value("i1631")==nil then game:set_value("i1631", 0) end
if game:get_value("i1847")==nil then game:set_value("i1847", 0) end
if game:get_value("i2014")==nil then game:set_value("i2014", 0) end
if game:get_value("i2015")==nil then game:set_value("i2015", 0) end
if game:get_value("i2021")==nil then game:set_value("i2021", 0) end

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
  if game:get_map():get_id() == "1" then
    if game:get_value("i1027") == 4 then self:remove() end
    if game:get_value("i1032") >= 3 then
      -- Julita and Crista switch places at this time: Crista at home, Julita running the shop.
      self:set_position(1128, 557)
    else
      -- Normally Crista is at the shop and Julita is at home.
      self:set_position(256, 469)
    end
  end
end

function entity:on_interaction()
  -- First, make the NPC face the hero when interacting and put name above the dialog box.
  self:get_sprite():set_direction(self:get_direction4_to(hero))
  game:set_dialog_name(name)
  
  if game:get_map():get_id() == "28" then
    -- Faron Woods access to sewer, to get sword.
    if game:get_value("i1901") >= 1 then
      if not map:has_entities("chuchu") and game:get_value("i1027") <= 4 then 
        game:start_dialog("crista.1.woods")
      elseif map:has_entities("chuchu") and game:get_value("i1027") <= 4 then
        game:start_dialog("crista.1.woods_chuchu", game:get_player_name())
      else
        game:start_dialog("crista.1.woods_close")
      end
    else
      if map:has_entities("chuchu") then
        game:start_dialog("crista.1.woods_chuchu", game:get_player_name())
      else
        game:start_dialog("crista.0.woods", game:get_player_name(), function(answer)
          if answer == 1 then
            game:set_value("i1901", game:get_value("i1901")+1)
            game:start_dialog("crista.0.woods_agree")
          else
            game:set_value("i1901", game:get_value("i1901")-1)
            game:start_dialog("crista.0.woods_disagree")
          end
        end)
      end
    end
  elseif game:get_value("b2020") and not game:get_value("b2022") then
    -- Has odd mushroom (trading sequence).
    if game:get_value("i2021") >= 1 then
      game:start_dialog("crista.0.potion_work", function()
        if game:get_value("i2021") < 10 then game:set_value("i2021", game:get_value("i2021")+1) end
      end)
    else
      game:start_dialog("crista.0.shop_mushroom", function(answer)
        if answer == 1 then
          game:start_dialog("crista.0.potion_work_yes", function()
            game:set_value("i2021", 1) -- Start potion counter.
            map:get_entity("quest_trading_potion"):remove()
          end)
        else
          game:start_dialog("crista.0.potion_work_no")
        end
      end)
    end
  elseif game:get_value("i1631") >= 7 and game:get_value("i2014") >= 10 and game:get_value("i2015") >= 10 and last_speak ~= 1 then
    last_speak = 1
    game:start_dialog("crista.5.shop_progress")  -- Progress on plants fetch quest.
  elseif game:get_value("i1847") >= 25 and game:get_value("i2015") < 10 then  -- Has enough deku sticks for blue potion (and hasn't been made before).
    last_speak = 2
    if game:get_value("i2015") >= 1 then
      game:start_dialog("crista.0.potion_work", function()
        if game:get_value("i2015") < 10 then game:set_value("i2015", game:get_value("i2015")+1) end
      end)
    else
      game:start_dialog("crista.0.shop_deku_sticks_2", function(answer)
        if answer == 1 then
          game:start_dialog("crista.0.potion_work_yes", function()
            game:set_value("i2015", 1) -- Start potion counter.
          end)
        else
          game:start_dialog("crista.0.potion_work_no")
        end
      end)
    end
  elseif game:get_value("i1847") >= 10 and game:get_value("i2014") < 10 then  -- Has enough deku sticks for green potion (and hasn't been made before).
    last_speak = 2
    if game:get_value("i2014") >= 1 then
      game:start_dialog("crista.0.potion_work", function()
        if game:get_value("i2014") < 10 then game:set_value("i2014", game:get_value("i2014")+1) end
      end)
    else
      game:start_dialog("crista.0.shop_deku_sticks_1", function(answer)
        if answer == 1 then
          game:start_dialog("crista.0.potion_work_yes", function()
            game:set_value("i2014", 1) -- Start potion counter.
          end)
        else
          game:start_dialog("crista.0.potion_work_no")
        end
      end)
    end
  else
    last_speak = 3
    local rand = math.random(6)
    if rand == 1 and game:get_item("trading"):get_variant() < 1 then
      -- Randomly mention the mushroom on occasion (if not already obtained) or deku sticks.
      -- Randomly mention the plant fetch quest if the first two potions are already made.
      game:start_dialog("crista.1.shop_mushroom", game:get_player_name())
    elseif rand == 2 and game:get_value("i2015") == 0 then
      game:start_dialog("crista.1.shop_deku_stick", game:get_player_name())
    elseif rand == 3 and game:get_value("i2014") >= 20 and game:get_value("i2015") >= 20 then
      game:start_dialog("crista.5.shop")
    elseif game:get_value("b1117") and game:get_value("i1030") < 1 then
      game:start_dialog("crista.4.shop")
    elseif game:get_value("i1032") >= 4 then
      game:start_dialog("crista.3.shop")
    elseif game:get_value("i1032") >= 3 then
      game:start_dialog("crista.2.house", game:get_player_name())
    elseif game:get_value("i1032") >= 1 then
      game:start_dialog("crista.2.shop", game:get_player_name())
    else
      game:start_dialog("crista.0.shop")
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