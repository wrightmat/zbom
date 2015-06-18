local map = ...
local game = map:get_game()

-----------------------------------------------
-- Ordon Village Houses (Link's house, etc.) --
-----------------------------------------------

local odd_potion_counter = 0
if game:get_value("i1026")==nil then game:set_value("i1026", 0) end
if game:get_value("i1027")==nil then game:set_value("i1027", 0) end
if game:get_value("i1029")==nil then game:set_value("i1029", 0) end
if game:get_value("i1602")==nil then game:set_value("i1602", 0) end
if game:get_value("i1913")==nil then game:set_value("i1913", 0) end
if game:get_value("i1921")==nil then game:set_value("i1921", 0) end
if game:get_value("i2014")==nil then game:set_value("i2014", 0) end
if game:get_value("i2015")==nil then game:set_value("i2015", 0) end
if game:get_value("i2021")==nil then game:set_value("i2021", 0) end

function map:on_started(destination)
  -- increment potion counters
  if game:get_value("i2014") >= 1 then game:set_value("i2014", game:get_value("i2014")+1) end  -- Blue
  if game:get_value("i2015") >= 1 then game:set_value("i2015", game:get_value("i2015")+1) end  -- Revitalizing
  if game:get_value("i2021") >= 1 then game:set_value("i2021", game:get_value("i2021")+1) end  -- Odd (trading)
  if destination == main_entrance_shop and game:get_value("i2021") >= 10 then
    game:start_dialog("crista.0.potion_done", function()
      hero:start_treasure("trading", 2) -- give Odd Potion...
      game:set_value("b2022", true)
      game:set_value("b2020", false) -- take mushroom
      game:set_value("i2021", 0) -- and get rid of potion counter
    end)
  elseif destination == main_entrance_shop and game:get_value("i2015") >= 10 then
    game:start_dialog("crista.0.potion_done", function()
      hero:start_treasure("potion", 4) -- give Revitalizing Potion...
      game:set_value("i1847", game:get_value("i1847")-25)
      game:set_value("i2015", 0) -- and get rid of potion counter
    end)
  elseif destination == main_entrance_shop and game:get_value("i2014") >= 10 then
    game:start_dialog("crista.0.potion_done", function()
      hero:start_treasure("potion", 3) -- give Blue Potion...
      game:set_value("i1847", game:get_value("i1847")-10)
      game:set_value("i2014", 0) -- and get rid of potion counter
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
	sensor_sleep:set_enabled(false)
        hero:set_visible(true)
        hero:start_jumping(4, 24, true)
        bed:get_sprite():set_animation("empty_open")
        sol.audio.play_sound("hero_lands")
      end)
      sleep_timer:set_with_sound(false)
    end)
  else
    snores:set_enabled(false)
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
  else
    npc_ulo:remove()
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

function house_bed:on_activated()
  snores:set_enabled(true)
  bed:set_enabled(true)
  bed:get_sprite():set_animation("hero_sleeping")
  hero:freeze()
  hero:set_visible(false)
  sol.timer.start(1000, function()
    snores:remove()
    bed:get_sprite():set_animation("hero_waking")
    sleep_timer = sol.timer.start(1000, function()
      sensor_sleep:set_enabled(false)
      hero:set_visible(true)
      hero:start_jumping(4, 24, true)
      bed:get_sprite():set_animation("empty_open")
      sol.audio.play_sound("hero_lands")
    end)
    sleep_timer:set_with_sound(false)
  end)
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
  if game:get_value("b2025") then
    game:start_dialog("impa.0.trading", function(answer)
      if answer == 1 then
        -- give her the crystal ball, get the tasty meat
        game:start_dialog("impa.0.trading_yes", function()
          hero:start_treasure("trading", 6)
          game:set_value("b2026", true)
          game:set_value("b2025", false)
        end)
      else
        -- don't give her the crystal ball
        game:start_dialog("impa.0.trading_no")
      end
    end)
  elseif game:get_value("b1117") then
    if game:get_value("i1921") < 6 then
      game:start_dialog("impa."..game:get_value("i1921")..".house")
      game:set_value("i1921", game:get_value("i1921")+1)
    end
  elseif game:get_value("i1032") >= 2 then
    game:start_dialog("impa.2.house")
    game:set_value("i1921", 3)
  else
    game:start_dialog("impa.0.house", function()
      if game:has_item("ocarina") then
        game:start_dialog("impa.1.house_2", function()
          if not game:has_item("glove") then
            game:start_dialog("impa.1.house_3")
          end
        end)
      else
        game:start_dialog("impa.0.house_2")
      end
    end)
  end
end

function sensor_sleep:on_activated()
 if game:get_value("i1027") >= 6 then
  game:start_dialog("_sleep_bed", function(answer)
    if answer == 1 then
      hero:teleport("1", "house_bed", "fade")
      game:set_life(game:get_max_life())
      game:set_stamina(game:get_max_stamina())
      if game:get_value("i1026") < 1 then game:set_max_stamina(game:get_max_stamina()-20) end
      if game:get_value("i1026") > 3 then game:set_max_stamina(game:get_max_stamina()+20) end
      game:set_value("i1026", 0)
      game:switch_time_of_day()
      if game:get_time_of_day() == "day" then
        for entity in map:get_entities("night_") do
          entity:set_enabled(false)
        end
        night_overlay = nil
      else
        for entity in map:get_entities("night_") do
          entity:set_enabled(true)
        end
      end
    end
  end)
 end
end

function shelf_1:on_interaction()
  game:start_dialog("pim.1.house")
end