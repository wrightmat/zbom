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
if game:get_value("i1806")==nil then game:set_value("i1806", 0) end
if game:get_value("i1820")==nil then game:set_value("i1820", 0) end
if game:get_value("i1913")==nil then game:set_value("i1913", 0) end
if game:get_value("i1921")==nil then game:set_value("i1921", 0) end
if game:get_value("i2014")==nil then game:set_value("i2014", 0) end
if game:get_value("i2015")==nil then game:set_value("i2015", 0) end
if game:get_value("i2021")==nil then game:set_value("i2021", 0) end

function map:on_started(destination)
  if game:get_item("trading"):get_variant() >= 6 then table_crystal_ball:set_enabled(true) end
  if not game:get_value("b2020") then quest_trading_potion:remove() end
  if not game:get_value("b2025") then quest_trading_meat:remove() end

  if destination == main_entrance_shop and game:get_value("i2021") >= 5 then
    game:start_dialog("crista.0.potion_done", function()
      hero:start_treasure("trading", 2) -- Give Odd Potion...
      game:set_value("b2022", true)
      game:set_value("b2020", false) -- take Odd Mushroom...
      game:set_value("i2021", 0) -- and get rid of potion counter.
      quest_trading_potion:remove()
    end)
  elseif destination == main_entrance_shop and game:get_value("i2015") >= 10 and game:get_value("i2015") <= 19 then
    game:start_dialog("shopkeep.potion", function()
      game:set_value("i1847", game:get_value("i1847")-25)
      game:set_value("i2015", 20) -- Allow potion to be bought.
    end)
  elseif destination == main_entrance_shop and game:get_value("i2014") >= 10 and game:get_value("i2014") <= 19 then
    game:start_dialog("shopkeep.potion", function()
      game:set_value("i1847", game:get_value("i1847")-10)
      game:set_value("i2014", 20) -- Allow potion to be bought.
    end)
  end

  -- Increment potion counters.
  if game:get_value("i1631") == 13 then
    -- If all herbs are found in fetch quest, the final potion becomes available.
    local tx,ty,tl = shop_potion_2:get_position()
    shop_potion_2:remove()  -- Revitalizing Potion replaces Green Potion.
    map:create_shop_treasure({x=tx,y=ty,layer=tl,name="shop_potion",treasure_name="potion",treasure_variant=4,dialog="shop.potion_revitalizing",price=200})
  end
  if game:get_value("i2014") >= 10 then
    local tx,ty,tl = shop_potion_2:get_position()
    shop_potion_2:remove()  -- Green Potion takes second spot, which is empty (placeholder to make positioning easier).
    if game:get_value("i2014") == 20 then
      map:create_shop_treasure({x=tx,y=ty,layer=tl,name="shop_potion",treasure_name="potion",treasure_variant=2,dialog="shop.potion_green",price=0})
    else
      map:create_shop_treasure({x=tx,y=ty,layer=tl,name="shop_potion",treasure_name="potion",treasure_variant=2,dialog="shop.potion_green",price=100})
    end
  elseif game:get_value("i2014") >= 1 then
    game:set_value("i2014", game:get_value("i2014")+1)  -- Green Potion.
    shop_potion_2:remove()
  else
    shop_potion_2:remove()
  end
  if game:get_value("i2015") >= 10 then
    local tx,ty,tl = shop_potion_1:get_position()
    shop_potion_1:remove()  -- Blue Potion replaces Red Potion.
    if game:get_value("i2015") == 20 then
      map:create_shop_treasure({x=tx,y=ty,layer=tl,name="shop_potion",treasure_name="potion",treasure_variant=3,dialog="shop.potion_blue",price=0})
    else
      map:create_shop_treasure({x=tx,y=ty,layer=tl,name="shop_potion",treasure_name="potion",treasure_variant=3,dialog="shop.potion_blue",price=150})
    end
  elseif game:get_value("i2015") >= 1 then
    game:set_value("i2015", game:get_value("i2015")+1)  -- Blue Potion.
  end
  if game:get_value("i2021") >= 1 then game:set_value("i2021", game:get_value("i2021")+1) end  -- Odd (trading)

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
        map:get_game().hud:set_enabled(true)
      end)
      sleep_timer:set_with_sound(false)
    end)
  else
    snores:set_enabled(false)
    impa_snores:set_enabled(false)
  end
  if game:get_value("i1027") < 5 then
    npc_julita:remove()
    npc_bilo:remove()
  elseif game:get_value("b1117") then
    npc_bilo:remove() -- Bilo is headed to Hyrule Castle Town.
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

  -- Replace shop items as the game progresses.
  if game:get_value("i2015") >= 10 then -- Apples replaced by red potion if it's no longer available on potion side.
    shop_ordon_apple:remove()
    self:create_shop_treasure({
	name = "shop_potion",
	layer = 0,
	x = 144,
	y = 504,
	price = 60,
	dialog = "shop.potion_red",
	treasure_name = "potion",
	treasure_variant = 1
    })
  end

  if game:get_value("i1820") >= 2 then  -- Shield. Don't allow lesser version to be bought after Hylian or Light.
    shop_ordon_shield:remove()
    self:create_shop_treasure({
	name = "shop_arrow",
	layer = 0,
	x = 96,
	y = 504,
	price = 40,
	dialog = "shop.arrow",
	treasure_name = "arrow",
	treasure_variant = 3
    })
  end

  -- Activate any night-specific dynamic tiles.
  if game:get_time_of_day() == "night" then
    for entity in game:get_map():get_entities("night_") do
      entity:set_enabled(true)
    end
  end

  -- Apply to all potions, even dynamically created ones.
  for treasure in map:get_entities("shop_potion") do
    treasure.on_buying = function()
      if treasure:get_game():get_first_empty_bottle() == nil then
        game:start_dialog("shop.no_bottle")
        return false
      else
        return true
      end
    end
    treasure.on_bought = function()
      if treasure:get_game():get_value("i2014") == 20 then treasure:get_game():set_value("i2014", 30) end
      if treasure:get_game():get_value("i2015") == 20 then treasure:get_game():set_value("i2015", 30) end
    end
  end
end

function npc_ulo:on_interaction()
  game:set_dialog_style("default")
  if game:get_value("b1117") and game:get_value("i1030") < 2 then
    game:start_dialog("ulo.5.ordon", game:get_player_name())
  elseif game:get_value("i1029") >= 6 then
    game:start_dialog("ulo.4.ordon")
  else
    game:start_dialog("ulo.3.ordon")
  end
end

function npc_deacon:on_interaction()
  game:set_dialog_style("default")
  if game:get_value("i1602") == 3 then
    game:start_dialog("deacon.3.house", function()
      game:set_value("i1602", 4)
    end)
  elseif game:get_value("i1602") == 6 then
    game:start_dialog("deacon.5.faron", game:get_player_name())
  else
    if game:get_value("i1913") >= 3 and not game:get_value("b1134") then
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
  game:set_dialog_style("default")
  if not game:get_value("b1722") then
    game:start_dialog("gaira.5.faron", game:get_player_name(), function()
      hero:start_treasure("heart_piece", 1, "b1722")
    end)
  elseif game:get_value("i1030") < 2 then
    game:start_dialog("gaira.6.house")
  else
    game:start_dialog("gaira.5.forest")
  end
end

function npc_impa:on_interaction()
  game:set_dialog_style("default")
  if game:get_value("b2025") then
    game:start_dialog("impa.0.trading", function(answer)
      if answer == 1 then
        -- Give her the crystal ball, get the tasty meat.
        game:start_dialog("impa.0.trading_yes", function()
          hero:start_treasure("trading", 6)
          game:set_value("b2026", true)
          game:set_value("b2025", false)
          quest_trading_meat:remove()
        end)
      else
        -- Don't give her the crystal ball.
        game:start_dialog("impa.0.trading_no")
      end
    end)
  elseif game:get_value("b1117") then
    if game:get_value("i1921") < 6 then
      game:start_dialog("impa."..game:get_value("i1921")..".house")
      game:set_value("i1921", game:get_value("i1921")+1)
    else
      game:start_dialog("impa.1.house")
    end
  elseif game:get_value("i1032") >= 2 then
    game:start_dialog("impa.2.house")
    game:set_value("i1921", 3)
  else
    game:start_dialog("impa.0.house", function()
      if game:has_item("ocarina") then
        game:start_dialog("impa.1.house_2", function()
          if not game:has_item("glove") then game:start_dialog("impa.1.house_3") end
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

function sensor_sleep_impa:on_activated()
  if game:get_value("i1027") >= 6 then
    game:start_dialog("_sleep_bed", function(answer)
      if answer == 1 then
        hero:teleport("1", "impa_bed_dest", "fade")
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

function impa_bed_dest:on_activated()
  impa_snores:set_enabled(true)
  impa_bed:set_enabled(true)
  impa_bed:get_sprite():set_animation("hero_sleeping")
  hero:freeze()
  hero:set_visible(false)
  sol.timer.start(1000, function()
    impa_snores:remove()
    impa_bed:get_sprite():set_animation("hero_waking")
    sleep_timer = sol.timer.start(1000, function()
      sensor_sleep_impa:set_enabled(false)
      hero:set_visible(true)
      hero:start_jumping(4, 24, true)
      impa_bed:get_sprite():set_animation("empty_open")
      sol.audio.play_sound("hero_lands")
    end)
    sleep_timer:set_with_sound(false)
  end)
end

function shelf_1:on_interaction()
  game:set_dialog_style("default")
  game:start_dialog("pim.1.house")
end

function npc_shopkeeper:on_interaction()
  game:set_dialog_style("default")
  if math.random(4) == 1 and game:get_item("rupee_bag"):get_variant() < 2 then
    -- Randomly mention the bigger wallet.
    game:start_dialog("shopkeep.1")
  else
    game:start_dialog("shopkeep.0")
  end
end