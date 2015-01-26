local map = ...
local game = map:get_game()

---------------------------
-- Kakariko City houses  --
---------------------------

if game:get_value("i1918")==nil then game:set_value("i1918", 0) end
if game:get_value("i1919")==nil then game:set_value("i1919", 0) end
if game:get_value("i1920")==nil then game:set_value("i1920", 0) end
if game:get_value("i1830")==nil then game:set_value("i1830", 0) end

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
  if game:get_time_of_day() == "night" then
    npc_rowin:remove()
    npc_moriss:remove()
    npc_etnaya:remove()

    -- Activate any night-specific dynamic tiles
    for entity in map:get_entities("night_") do
      entity:set_enabled(true)
    end
  end

  if destination ~= inn_bed then
    snores:set_enabled(false)
    bed:set_enabled(false)
  end
end

function inn_bed:on_activated()
  snores:set_enabled(true)
  bed:set_enabled(true)
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
end

function npc_etnaya:on_interaction()
  local rand = math.random(4)
  if rand == 1 then
  -- Randomly mention the show
    game:start_dialog("etnaya.0.show")
  else
    game:start_dialog("etnaya.0")
  end
end

function npc_gartan:on_interaction()
  game:start_dialog("gartan.0.pub")
end

function npc_moriss:on_interaction()
  if game:get_value("i1920") > 0 then
    game:start_dialog("moriss.1.pub", game:get_player_name())
  else
    game:start_dialog("moriss.0.pub", function()
      game:set_value("i1919", 1)
    end)
  end
end

function npc_rowin:on_interaction()
  if game:get_value("i1920") >= 2 then
    game:start_dialog("rowin.2.pub")
  else
    game:start_dialog("rowin.0.pub", function()
      game:set_value("i1920", 1)
    end)
  end
end

function npc_garroth_sensor:on_interaction()
  if game:get_value("i1918") <= 5 then
    if (game:get_value("i1918") >= 0 and game:get_value("i1918") <= 1 and game:get_time_of_day() == "day") or game:get_value("i1918") >= 3 then
      game:start_dialog("garroth."..game:get_value("i1918")..".pub", function()
        game:set_value("i1918", game:get_value("i1918")+1)
      end)
    elseif game:get_value("i1918") <= 5 and game:get_time_of_day() == "night" then
      game:start_dialog("garroth."..game:get_value("i1918")..".pub", function()
        game:set_value("i1918", game:get_value("i1918")+1)
      end)
    end
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
