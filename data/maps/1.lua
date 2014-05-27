local map = ...
local game = map:get_game()

-----------------------------------------------
-- Ordon Village Houses (Link's house, etc.) --
-----------------------------------------------

local odd_potion_counter = 0
if game:get_value("i1027")==nil then game:set_value("i1027", 0) end
if game:get_value("i1032")==nil then game:set_value("i1032", 0) end
if game:get_value("i1068")==nil then game:set_value("i1068", 0) end
if game:get_value("i2021")==nil then game:set_value("i2021", 0) end
if game:get_value("i1602")==nil then game:set_value("i1602", 0) end

function map:on_started(destination)
  -- increment potion counter
  if game:get_value("i2021") >= 1 then game:set_value("i2021", game:get_value("i2021")+1) end
  if destination == main_entrance_shop and game:get_value("i2021") >= 10 then
    game:start_dialog("crista.0.shop_mushroom_done", function()
      hero:start_treasure("trading", 2) -- give Odd Potion...
      game:set_value("b2022", true)
      game:set_value("i2021", 0) -- and get rid of potion counter
    end)
  end
  if destination == from_intro then
    bed:get_sprite():set_animation("hero_sleeping")
    hero:freeze()
    hero:set_visible(false)
    sol.timer.start(1000, function()
      snores:remove()
      bed:get_sprite():set_animation("hero_waking")
      sleep_timer = sol.timer.start(1000, function()
        hero:set_visible(true)
        hero:start_jumping(4, 24, true)
        bed:get_sprite():set_animation("empty_open")
        sol.audio.play_sound("hero_lands")
      end)
      sleep_timer:set_with_sound(false)
    end)
  else
    snores:remove()
  end
  if game:get_value("i1027") == 4 then
    npc_crista:remove()
  end
  if game:get_value("i1027") < 5 then
    npc_julita:remove()
    npc_bilo:remove()
  end
  if game:get_value("i1032") >= 3 then
    for entity in map:get_entities("box") do
      entity:remove()
    end
    bed_bilo:set_enabled(true)
    -- Julita and Crista switch places at this time:
    -- Crista at home, Julita running the shop
    npc_crista:remove()
    npc_julita:remove()
  else
    npc_ulo:remove()
    -- Normally Crista is at the shop and Julita is at home.
    npc_crista_house:remove()
    npc_julita_shop:remove()
  end
  if game:get_value("i1602") < 3 then
    npc_deacon:remove()
    npc_gaira:remove()
  elseif game:get_value("i1602") < 6 then
    npc_gaira:remove()
  end

  -- Activate any night-specific dynamic tiles
  if game:get_time_of_day() == "night" then
    for entity in map:get_entities("night_") do
      entity:set_enabled(true)
    end
  end
end

function shop_potion_red:on_buying()
  if self:get_game():get_first_empty_bottle() == nil then
    game:start_dialog("shop.no_bottle")
    return false
  else
    hero:start_treasure("potion", 1)
    game:remove_money(50)
  end
end

function shop_potion_green:on_buying()
  if self:get_game():get_first_empty_bottle() == nil then
    game:start_dialog("shop.no_bottle")
    return false
  else
    hero:start_treasure("potion", 2)
    game:remove_money(100)
  end
end

function npc_bilo:on_interaction()
  if map:get_game():get_value("i3005") == 0 then
    game:start_dialog("bilo.0")
  else
    if game:get_value("i1032") >= 3 then
      game:start_dialog("bilo.2")
    else
      game:start_dialog("bilo.1")
    end
  end
end

function npc_ulo:on_interaction()
  if game:get_value("b1117") and game:get_value("i1030") < 2 then
    game:start_dialog("ulo.5.ordon")
  elseif game:get_value("i1029") >= 6 then
    game:start_dialog("ulo.4.ordon")
  else
    game:start_dialog("ulo.3.ordon")
  end
end

function npc_julita:on_interaction()
  if game:get_value("i1029") >= 6 then
    game:start_dialog("julita.4.house")
  else
    game:start_dialog("julita.3.house")
  end
end

function npc_crista:on_interaction()
  if game:get_value("b2020") and not game:get_value("b2022") then
    if game:get_value("i2021") >= 1 then
      game:start_dialog("crista.0.shop_mushroom_work", function()
        if game:get_value("i2021") < 10 then game:set_value("i2021", game:get_value("i2021")+1) end
      end)
    else
      game:start_dialog("crista.0.shop_mushroom", function(answer)
        if answer == 1 then
          game:start_dialog("crista.0.shop_mushroom_yes", function()
            game:set_value("i2021", 1) -- start potion counter
	  end)
        else
          game:start_dialog("crista.0.shop_mushroom_no")
        end
      end)
    end
  else
    local rand = math.random(4)
    if rand == 1 and game:get_item("trading"):get_variant() < 1 then
      -- Randomly mention the mushroom on occasion (if not already obtained)
      game:start_dialog("crista.1.shop", game:get_player_name())
    elseif game:get_value("b1117") and game:get_value("i1030") < 1 then
      game:start_dialog("crista.4.shop")
    elseif game:get_value("i1032") >= 6 then
      game:start_dialog("crista.3.shop")
    elseif game:get_value("i1068") > 3 then
      game:start_dialog("crista.2.house", game:get_player_name())
    else
      game:start_dialog("crista.0.shop")
    end
  end
end

function npc_deacon:on_interaction()
  if game:get_value("i1602") == 3 then
    game:start_dialog("deacon.3.house", function()
      game:set_value("i1602", 4)
    end)
  elseif game:get_value("i1602") == 6 and not game:get_value("b1117") then
    game:start_dialog("deacon.5.faron", game:get_player_name())
  else
    if game:get_value("i1913") >= 3 and game:get_value("b1117") then
      game:start_dialog("deacon.6.house", function()
	game:set_value("i1030", 1)
      end)
    else
      game:start_dialog("deacon.0.faron")
      game:set_value("i1913", game:get_value("i1913")+1)
    end
  end
end

function npc_gaira:on_interaction()
  if game:get_value("i1030") == 1 then
    game:start_dialog("gaira.6.house")
  else
    game:start_dialog("gaira.5.faron", game:get_player_name())
  end
end

function npc_impa:on_interaction()
  if game:get_value("i1032") >= 2 then
    game:start_dialog("impa.2.house")
  else
    game:start_dialog("impa.0.house", function()
      if game:has_item("ocarina") then
        game:start_dialog("impa.1.house_2")
      else
        game:start_dialog("impa.0.house_2")
      end
    end)
  end
end
