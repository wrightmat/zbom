local map = ...
local game = map:get_game()

------------------------
-- Goron City houses  --
------------------------

if game:get_value("i1029") == nil then game:set_value("i1029", 0) end --quest variable
if game:get_value("i1806") == nil then game:set_value("i1806", 0) end
if game:get_value("i1914") == nil then game:set_value("i1914", 0) end --Dargor rep
if game:get_value("i1916") == nil then game:set_value("i1916", 0) end --Galen rep

function map:on_started(destination)
  if not game:get_value("b2028") then quest_trading_vase:remove() end
  if game:get_value("i1032") < 4 then npc_gor_larin:remove() end -- Elder only comes back to village after Zelda is kidnapped.

  if game:get_time_of_day() == "night" then
    -- Activate any night-specific dynamic tiles
    for entity in map:get_entities("night_") do
      entity:set_enabled(true)
    end
  end

  snores:set_enabled(false)
  npc_galen_2:get_sprite():set_direction(1) -- Up

  if game:get_value("i1029") < 2 then
    npc_galen_2:remove()
  elseif game:get_value("i1029") == 2 then
    npc_galen:remove()
  elseif game:get_value("i1029") >= 3 then
    npc_osgor:remove()
    npc_galen_2:remove()
    if game:get_value("i1029") == 3 then npc_galen:remove() end
  end

  if game:get_value("i1029") == 2 and destination == from_outside_house_sick then
    sol.timer.start(1000, function()
      hero:freeze()
      game:start_dialog("dargor.3.house", game:get_player_name(), function()
        npc_galen_2:get_sprite():set_animation("walking")
	local m = sol.movement.create("target")
        m:set_target(112, 384)
	m:set_speed(32)
	m:start(npc_galen_2, function()
	  npc_galen_2:get_sprite():set_animation("stopped")
	  npc_galen_2:get_sprite():set_direction(2) -- Left / West
          sol.timer.start(2000, function()
	    npc_galen_2:get_sprite():set_direction(0) -- Right / East
	    game:start_dialog("galen.2.house", game:get_player_name(), function()
	      npc_galen_2:get_sprite():set_animation("walking")
	      local m2 = sol.movement.create("target")
              m2:set_target(160, 461)
	      m:set_speed(16)
              m2:start(npc_galen_2, function()
	        npc_galen_2:remove()
	        hero:unfreeze()
	        game:set_value("i1029", 3)
	      end)
            end)
	  end)
        end)
      end)
    end)
  end

  -- Replace shop items if they're bought
  if game:get_value("i1806") >= 1 then -- Bomb bag
    self:create_shop_treasure({
	name = "shop_item_2",
	layer = 0,
	x = 576,
	y = 392,
	price = 999,
	dialog = "shop.tunic_2",
	treasure_name = "tunic",
	treasure_variant = 2,
	treasure_savegame_variable = "b2016"
    })
  end
end

function npc_dargor:on_interaction()
  if game:get_value("i1914") == 1 then
    sol.audio.play_sound("goron_happy")
    game:start_dialog("dargor.1.house", function()
      game:set_value("i1914", game:get_value("i1914")+1)
      game:set_value("i1029", 1)
    end)
  elseif game:get_value("i1914") == 2 then
    sol.audio.play_sound("goron_happy")
    game:start_dialog("dargor.2.house", function()
      game:set_value("i1914", game:get_value("i1914")+1)
    end)
  elseif game:get_value("i1029") >= 3 then
    sol.audio.play_sound("goron_sad")
    game:start_dialog("dargor.4.house", game:get_player_name())
  else
    sol.audio.play_sound("goron_sad")
    game:start_dialog("dargor.0.house", function()
      game:set_value("i1914", game:get_value("i1914")+1)
    end)
  end
end

function npc_galen:on_interaction()
  if game:get_value("i1029") == 1 then
    sol.audio.play_sound("goron_sad")
    game:start_dialog("galen.1.house", function()
      game:set_value("i1916", game:get_value("i1916")+1)
      game:set_value("i1029", 2)
    end)
  else
    sol.audio.play_sound("goron_happy")
    game:start_dialog("galen.0.house", function()
      game:set_value("i1916", game:get_value("i1916")+1)
    end)
  end
end

function npc_osgor:on_interaction()
  game:start_dialog("osgor.0.house")
end

function npc_gor_larin:on_interaction()
  sol.audio.play_sound("goron_happy")
  if game:get_value("b1117") then
    game:start_dialog("larin.2.house")
  else
    game:start_dialog("larin.1.house")
  end
end

function npc_goron_smith:on_interaction()
  if not game:has_item("bomb_bag") then
    sol.audio.play_sound("goron_question")
    game:start_dialog("goron_smith.0.shop", function(answer)
      if answer == 1 then -- Yes
        if game:get_money() >= 300 then
	hero:start_treasure("bomb_bag")
	game:remove_money(300)
        else
	game:start_dialog("shopkeep.1")
        end
      end
    end)
  elseif game:get_value("i1805") < 5 then
    sol.audio.play_sound("goron_question")
    game:start_dialog("goron_smith.1.shop_sell", function(answer)
      if answer == 1 then -- Yes
        if game:get_money() >= 50 then
	hero:start_treasure("bomb", 3)
	game:remove_money(50)
        else
	game:start_dialog("shopkeep.1")
        end
      end
    end)
  else
    sol.audio.play_sound("goron_happy")
    game:start_dialog("goron_smith.1.shop")
  end
end

function npc_goron_trading:on_interaction()
  if game:get_value("b2028") then
    sol.audio.play_sound("goron_question")
    game:start_dialog("goron.0.trading", function(answer)
      if answer == 1 then
        -- Give him the bananas, get the Goron Vase.
        sol.audio.play_sound("goron_happy")
        game:start_dialog("goron.0.trading_yes", function()
          hero:start_treasure("trading", 9)
          game:set_value("b2029", true)
          game:set_value("b2028", false)
          quest_trading_vase:remove()
        end)
      else
        -- Don't give him the bananas.
        sol.audio.play_sound("goron_sad")
        game:start_dialog("goron.0.trading_no")
      end
    end)
  else
    sol.audio.play_sound("goron_sad")
    game:start_dialog("goron.0.house")
  end
end

function inn_bed:on_activated()
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
      hero:set_visible(true)
      hero:start_jumping(0, 24, true)
      bed:get_sprite():set_animation("empty_open")
      sol.audio.play_sound("hero_lands")
    end)
    sleep_timer:set_with_sound(false)
  end)
end

function innkeeper_sensor:on_interaction()
  sol.audio.play_sound("goron_question")
  game:start_dialog("goron.0.inn", function(answer)
    if answer == 1 then
      game:remove_money(20)
      hero:teleport("5", "inn_bed", "fade")
      game:set_life(game:get_max_life())
      game:set_magic(game:get_max_magic())
      if game:get_value("i1026") < 2 then game:set_max_stamina(game:get_max_stamina()-20) end
      if game:get_value("i1026") > 5 then game:set_max_stamina(game:get_max_stamina()+20) end
      game:set_stamina(game:get_max_stamina())
      game:set_value("i1026", 0)
    end
  end)
end
function npc_goron_innkeep:on_interaction()
  innkeeper_sensor:on_interaction()
end

function npc_shopkeeper:on_interaction()
  if math.random(4) == 1 then
    -- Randomly mention the bigger wallet
    game:start_dialog("shopkeep.1")
  else
    game:start_dialog("shopkeep.0")
  end
end