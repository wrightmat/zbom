local entity = ...
local game = entity:get_game()
local map = entity:get_game():get_map()

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
  -- First, make the NPC face the hero when interacting
  self:get_sprite():set_direction(self:get_direction4_to(game:get_hero()))

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
  elseif game:get_value("i1631") >= 7 then
    game:start_dialog("crista.5.shop_progress")  -- Progress on plants fetch quest.
  elseif game:get_value("i1847") >= 25 and game:get_value("i2015") < 10 then  -- Has enough deku sticks for blue potion (and hasn't been made before).
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