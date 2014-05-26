local map = ...
local game = map:get_game()

---------------------------
-- Kakariko City houses  --
---------------------------

if game:get_value("i1918")==nil then game:set_value("i1918", 0) end
if game:get_value("i1919")==nil then game:set_value("i1919", 0) end
if game:get_value("i1920")==nil then game:set_value("i1920", 0) end

local function random_walk(npc)
  local m = sol.movement.create("random_path")
  m:set_speed(32)
  m:start(npc)
  npc:get_sprite():set_animation("walking")
end

function map:on_started(destination)
  if not game:has_item("bomb_bag") then
    if item_bomb_1 ~= nil then item_bomb_1:remove() end
    if item_bomb_2 ~= nil then item_bomb_2:remove() end
    if item_bomb_3 ~= nil then item_bomb_3:remove() end
  end
  random_walk(npc_etnaya)

  if destination == inn_bed then
    bed:get_sprite():set_animation("hero_sleeping")
    hero:freeze()
    hero:set_visible(false)
    sol.timer.start(1000, function()
      snores:remove()
      bed:get_sprite():set_animation("hero_waking")
      sleep_timer = sol.timer.start(1000, function()
        hero:set_visible(true)
        hero:start_jumping(0, 24, true)
        bed:get_sprite():set_animation("empty_open")
        sol.audio.play_sound("hero_lands")
      end)
      sleep_timer:set_with_sound(false)
    end)
  else
    snores:remove()
    bed:remove()
  end
end

function npc_etnaya:on_interaction()
  game:start_dialog("etnaya.0")
end

function npc_gartan:on_interaction()
  game:start_dialog("gartan.0.pub")
end

function npc_moriss:on_interaction()
  if game:get_value("i1920") > 0 then
    game:start_dialog("moriss.1.pub")
  else
    game:start_dialog("moriss.0.pub", function()
      game:set_value("i1919", game:get_value("i1919")+1)
    end)
  end
end

function npc_rowin:on_interaction()
  game:start_dialog("rowin.0.pub", function()
    game:set_value("i1920", game:get_value("i1920")+1)
  end)
end

function npc_garroth_sensor:on_interaction()
  if game:get_value("i1918") <= 5 then
    game:start_dialog("garroth."..game:get_value("i1918")..".pub", function()
      game:set_value("i1918", game:get_value("i1918")+1)
    end)
  else
    if game:get_value("i1830") >= 75 then
      game:start_dialog("garroth.8.pub", game:get_value("i1830"), function()
	-- what to give when player has more than 75 alchemy stones?
      end)
    elseif game:get_value("i1830") >= 50 then
      game:start_dialog("garroth.7.pub", game:get_value("i1830"), function()
	hero:start_treasure("rupees", 5)
      end)
    elseif game:get_value("i1830") >= 25 then
      game:start_dialog("garroth.6.pub", game:get_value("i1830"), function()
	hero:start_treasure("rupees", 4)
      end)
    else
      game:start_dialog("garroth.5.pub")
    end
  end
end

function npc_turt_sensor:on_interaction()
  game:start_dialog("turt.0.inn", function(answer)
    if answer == 1 then
      game:remove_money(20)
      hero:teleport("4", "inn_bed", "fade")
      game:set_life(game:get_max_life())
      if game.time_of_day == day then
	game.time_of_day = night
      else
	game.time_of_day = day
      end
    end
  end)
end
