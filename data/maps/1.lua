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

local function replace_shop_treasure(treasure,properties)
  -- ATTENTION: We can't reassign the entity inside the function
  -- so we have to use the return value.
  local tx,ty,tl = treasure:get_position()
  treasure:remove()
  properties.x,properties.y,properties.layer = tx,ty,tl
  return map:create_shop_treasure(properties)
end

function map:on_started(destination)
  if game:get_time_of_day() == "day" then npc_tern:remove() end
  if game:get_item("trading"):get_variant() >= 6 then table_crystal_ball:set_enabled(true) end
  if not game:get_value("b2020") or game:get_value("i2021") >= 1 then quest_trading_potion:remove() end
  if not game:get_value("b2025") then quest_trading_meat:remove() end

  if destination == main_entrance_shop and game:get_value("i2021") >= 5 then
    game:start_dialog("crista.0.potion_done", function()
      hero:start_treasure("trading", 2) -- Give Odd Potion...
      game:set_value("b2022", true)
      game:set_value("b2020", false) -- take Odd Mushroom...
      game:set_value("i2021", 0) -- and get rid of potion counter.
      if quest_trading_potion ~= nil then quest_trading_potion:remove() end
    end)
  elseif destination == main_entrance_shop and game:get_value("i2015") >= 10 and game:get_value("i2015") <= 19 then
    -- We don't use a dialog callback function here because we have to
    -- wait for the dialog to finish before modifying the variables.
    game:start_dialog("shopkeep.potion")
    game:set_value("i1847", game:get_value("i1847")-25)
    game:set_value("i2015", 20) -- Allow potion to be bought.
  elseif destination == main_entrance_shop and game:get_value("i2014") >= 10 and game:get_value("i2014") <= 19 then
    -- We don't use a dialog callback function here because we have to
    -- wait for the dialog to finish before modifying the variables.
    game:start_dialog("shopkeep.potion")
    game:set_value("i1847", game:get_value("i1847")-10)
    game:set_value("i2014", 20) -- Allow potion to be bought.
  end

  -- Increment potion counters.
  if game:get_value("i2014") >= 10 then
    -- Green Potion takes second spot, which is empty (placeholder to make positioning easier).
    -- The first one is for free.
    local p = game:get_value("i2014") == 20 and 0 or 100
    shop_potion_2=replace_shop_treasure(shop_potion_2,{name="shop_potion",treasure_name="potion",treasure_variant=2,dialog="shop.potion_green",price=p})
  elseif game:get_value("i2014") >= 1 then
    game:set_value("i2014", game:get_value("i2014")+1)  -- Green Potion.
  end
  if game:get_value("i2015") >= 10 then
    -- Blue Potion replaces Red Potion.
    -- The first one is for free.
    local p = game:get_value("i2015") == 20 and 0 or 150
    shop_potion_1=replace_shop_treasure(shop_potion_1,{name="shop_potion",treasure_name="potion",treasure_variant=3,dialog="shop.potion_blue",price=p})
  elseif game:get_value("i2015") >= 1 then
    game:set_value("i2015", game:get_value("i2015")+1)  -- Blue Potion.
  end
  if game:get_value("i1631") >= 16 then
    -- If all herbs are found in fetch quest, the final potion becomes available.
    -- Revitalizing Potion replaces Green Potion.
    shop_potion_2 = replace_shop_treasure(shop_potion_2,{name="shop_potion",treasure_name="potion",treasure_variant=4,dialog="shop.potion_revitalizing",price=200})
  end
  if game:get_value("i2021") >= 1 then game:set_value("i2021", game:get_value("i2021")+1) end  -- Odd (trading)

  if destination == from_intro then
    bed:get_sprite():set_animation("hero_sleeping")
    bed:get_sprite():set_direction(0)
    hero:freeze()
    hero:set_visible(false)
    sol.timer.start(1000, function()
      snores:remove()
      bed:get_sprite():set_animation("hero_waking")
      bed:get_sprite():set_direction(0)
      sleep_timer = sol.timer.start(1000, function()
        sensor_sleep:set_enabled(false)
        hero:set_visible(true)
        hero:start_jumping(4, 24, true)
        bed:get_sprite():set_animation("empty_open")
        sol.audio.play_sound("hero_lands")
        map:get_game().hud:set_enabled(true)
        game:set_value("hour_of_day", 8) -- Hero awakes at 8am
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
  if game:get_value("i2015") >= 10 then
    -- Apples replaced by red potion if it's no longer available on potion side.
    shop_ordon_apple = replace_shop_treasure(shop_ordon_apple,{
	    name = "shop_potion",
	    price = 60,
	    dialog = "shop.potion_red",
	    treasure_name = "potion",
	    treasure_variant = 1
    })
  end

  if game:get_value("i1820") >= 2 then
    -- Shield. Don't allow lesser version to be bought after Hylian or Light.
    shop_ordon_shield = replace_shop_treasure(shop_ordon_shield,{
	    name = "shop_arrow",
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
      if treasure:get_game():get_value("i2014") == 20 then
        treasure:get_game():set_value("i2014", 30)
        -- This item is not free anymore so set the price.
        -- Unfortunately the only way to do that is recreating the item...
        shop_potion_2=replace_shop_treasure(shop_potion_2,{name="shop_potion",treasure_name="potion",treasure_variant=2,dialog="shop.potion_green",price=200})
      end
      if treasure:get_game():get_value("i2015") == 20 then
        treasure:get_game():set_value("i2015", 30)
        -- This item is not free anymore so set the price.
        -- Unfortunately the only way to do that is recreating the item...
        shop_potion_1=replace_shop_treasure(shop_potion_1,{name="shop_potion",treasure_name="potion",treasure_variant=3,dialog="shop.potion_blue",price=150})
      end
    end
  end
end

npc_ulo:register_event("on_interaction", function()
  if game:get_value("b1117") and game:get_value("i1030") < 2 then
    game:start_dialog("ulo.5.ordon", game:get_player_name())
  elseif game:get_value("i1029") >= 6 then
    game:start_dialog("ulo.4.ordon")
  else
    game:start_dialog("ulo.3.ordon")
  end
end)

npc_impa:register_event("on_interaction", function()
  if game:get_value("b2025") then
    game:start_dialog("impa.0.trading", function(answer)
      if answer == 1 then
        -- Give her the crystal ball, get the tasty meat.
        game:start_dialog("impa.0.trading_yes", function()
          hero:start_treasure("trading", 6)
          game:set_value("b2026", true)
          game:set_value("b2025", false)
          game:set_value("i1921", 6) -- Immediately increase reputation.
          quest_trading_meat:remove()
        end)
      else
        -- Don't give her the crystal ball.
        game:start_dialog("impa.0.trading_no")
      end
    end)
  elseif game:get_value("b1170") and game:get_value("i1920") >= 6 then
    -- If player has finished Tower of Wind and she has crystal ball, direct to the Lost Woods.
    game:start_dialog("impa.6.house")
  elseif game:get_value("b1117") then
    if game:get_value("i1921") < 8 then
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
end)

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
      end
    end)
  end
end

function house_bed:on_activated()
  game:switch_time_of_day()
  snores:set_enabled(true)
  bed:set_enabled(true)
  bed:get_sprite():set_animation("hero_sleeping")
  bed:get_sprite():set_direction(game:get_value("tunic_equipped") - 1)
  hero:freeze()
  hero:set_visible(false)
  sol.timer.start(1000, function()
    snores:remove()
    bed:get_sprite():set_animation("hero_waking")
    bed:get_sprite():set_direction(game:get_value("tunic_equipped") - 1)
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
      end
    end)
  end
end

function impa_bed_dest:on_activated()
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
  impa_snores:set_enabled(true)
  impa_bed:set_enabled(true)
  impa_bed:get_sprite():set_animation("hero_sleeping")
  impa_bed:get_sprite():set_direction(game:get_value("tunic_equipped") - 1)
  hero:freeze()
  hero:set_visible(false)
  sol.timer.start(1000, function()
    impa_snores:remove()
    impa_bed:get_sprite():set_animation("hero_waking")
    impa_bed:get_sprite():set_direction(game:get_value("tunic_equipped") - 1)
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
  game:start_dialog("pim.1.house")
end

function npc_shopkeeper:on_interaction()
  if math.random(4) == 1 and game:get_item("rupee_bag"):get_variant() < 2 then
    -- Randomly mention the bigger wallet.
    game:start_dialog("shopkeep.1")
  else
    game:start_dialog("shopkeep.0")
  end
end

npc_tern:register_event("on_interaction", function()
  game:start_dialog("tern.1.house")
end)