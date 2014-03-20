local map = ...
local game = map:get_game()

-----------------------------------------------
-- Ordon Village Houses (Link's house, etc.) --
-----------------------------------------------

local odd_potion_counter = 0
if game:get_value("i1027")==nil then game:set_value("i1027", 0) end
if game:get_value("i2021")==nil then game:set_value("i2021", 0) end

function map:on_started(destination)
  -- increment potion counter
  if game:get_value("i2021") >= 1 then game:set_value("i2021", game:get_value("i2021")+1) end
  if destination == main_entrance_shop and game:get_value("i2021") == 10 then
    game:start_dialog("crista.0.shop_mushroom.7", function()
      game:set_value("i3001", game:get_value("i3001")+1) -- increase Rep and give Odd Potion
      hero:start_treasure("trading", 2)
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
end

function shop_potion_red:on_buying()
  if self:get_game():get_first_empty_bottle() == nil then
    game:start_dialog("shop.no_bottle")
    return false
  end
end

function shop_potion_green:on_buying()
  if self:get_game():get_first_empty_bottle() == nil then
    game:start_dialog("shop.no_bottle")
    return false
  end
end

function npc_bilo:on_interaction()
  if map:get_game():get_value("i3005") == 0 then
    game:start_dialog("bilo.0")
  else
    game:start_dialog("bilo.1")
  end
end

function npc_julita:on_interaction()
  game:start_dialog("julita.3")
end

function npc_crista:on_interaction()
  if game:get_value("b2020") then
    if game:get_value("i2021") >= 1 then
      game:start_dialog("crista.0.shop_mushroom_work")
    else
      game:start_dialog("crista.0.shop_mushroom", function(answer)
        if answer == 0 then
          game:start_dialog("crista.0.shop_mushroom_yes")
          game:set_value("i2021", 1)
        else
          game:start_dialog("crista.0.shop_mushroom_no")
        end
      end)
    end
  else
    local rand = math.random(6)
    if rand == 1 and not game:get_value("b2020") then
      -- Randomly mention the mushroom on occasion (if not already obtained)
      game:start_dialog("crista.1.shop", game:get_player_name())
    else
      game:start_dialog("crista.0.shop")
    end
  end
end
