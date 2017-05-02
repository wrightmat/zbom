local map = ...
local game = map:get_game()

---------------------------------
-- Inside Zora/Septen/Subrosia --
---------------------------------

local function random_walk(npc)
  local m = sol.movement.create("random_path")
  m:set_speed(32)
  m:start(npc)
  npc:get_sprite():set_animation("walking")
end

function map:on_started()
  if game:get_time_of_day() == "day" then
    npc_quinn:remove()
  end
  random_walk(npc_vogoli)
  if not game:get_value("b2032") then quest_trading_feather:remove() end
  shop_world_map_2:get_sprite():set_animation("world_map")
  shop_world_map_2:get_sprite():set_direction(1)
  shop_poe_soul:get_sprite():set_animation("poe_soul")
  shop_poe_soul:get_sprite():set_direction(0)
  
  -- Replace shop items if they're bought
  if game:get_item("world_map"):get_variant() > 1 then --world map
    shop_world_map_2:remove()
    self:create_shop_treasure({
	name = "shop_shovel",
	layer = 0,
	x = 128,
	y = 144,
	price = 5000,
	dialog = "_item_description.shovel.1",
	treasure_name = "shovel",
	treasure_variant = 1
    })
  end
  
  if game:get_value("b2019") then -- Giant wallet
    self:create_shop_treasure({
	name = "shop_treasure_2",
	layer = 0,
	x = 176,
	y = 880,
	price = 20,
	dialog = "_item_description.apple.1",
	treasure_name = "apple",
	treasure_variant = 1
    })
  end
end

npc_quinn:register_event("on_interaction", function()
  if game:get_value("b1150") then
    game:start_dialog("rito_3.1.septen")
  else
    game:start_dialog("rito_3.0.septen")
  end
end)

npc_vogoli:register_event("on_interaction", function()
  game:set_dialog_style("default")
  if game:is_dungeon_finished(7) then
    game:start_dialog("rito_4.1.septen")
  else
    game:start_dialog("rito_4.0.septen")
  end
end)

npc_negili:register_event("on_interaction", function()
  game:set_dialog_style("default")
  if not game:get_value("b1150") then
    game:start_dialog("rito_5.0.septen")
  else
    game:start_dialog("rito_5.1.septen")
  end
end)

npc_podoli:register_event("on_interaction", function()
  if game:get_value("b2032") then
    game:start_dialog("rito.0.trading", function(answer)
      if answer == 1 then
        -- Give him the cookbook, get the feather
        game:start_dialog("rito.0.trading_yes", function()
          hero:start_treasure("feather")
          game:get_item("trading"):set_variant(13)
          game:set_value("b2033", true)
          game:set_value("b2032", false)
          quest_trading_feather:remove()
        end)
      else
        -- Don't give him the cookbook
        game:start_dialog("rito.0.trading_no")
      end
    end)
  else
    game:start_dialog("rito.0.trading_hint")
  end
end)

npc_revin:register_event("on_interaction", function()
  game:start_dialog("shopkeep.0")
end)

npc_rozalin:register_event("on_interaction", function()
  if math.random(5) < 3 then
    game:start_dialog("subrosian_1.0.house_1")
  else
    game:start_dialog("subrosian_1.0.house_2")
  end
end)

npc_subro:register_event("on_interaction", function()
  if game:get_item("bottle_1"):get_variant() == 8 or game:get_item("bottle_2"):get_variant() == 8 or game:get_item("bottle_3"):get_variant() == 8 or game:get_item("bottle_4"):get_variant() == 8 then
    -- If hero has a Poe Soul.
    game:start_dialog("subrosian_2.1.poes", function(answer)
      if answer == 1 then
        if game:get_item("bottle_1"):get_variant() == 8 then game:get_item("bottle_1"):set_variant(0)
        elseif game:get_item("bottle_2"):get_variant() == 8 then game:get_item("bottle_2"):set_variant(0)
        elseif game:get_item("bottle_3"):get_variant() == 8 then game:get_item("bottle_3"):set_variant(0)
        elseif game:get_item("bottle_4"):get_variant() == 8 then game:get_item("bottle_4"):set_variant(0) end
        game:add_money(20)
      end
    end)
  elseif game:get_value("i1806") == nil or game:get_value("i1806") == 0 then
    game:start_dialog("subrosian_2.0.house_2")
  else
    game:start_dialog("subrosian_2.0.house_1")
  end
end)

if shop_world_map_2 ~= nil then
  function shop_world_map_2:on_interaction()
    -- Custom shop script to subtract ore instead of rupees
    game:start_dialog("shop.world_map", function()
      game:start_dialog("_shop.question_ore", 30, function(answer)
        if answer == 1 then
          if game:get_value("i1836") >= 30 then
            hero:start_treasure("world_map", 2)
            game:set_value("i1836",game:get_value("i1836")-30)
            shop_world_map_2:set_enabled(false)
          else
            game:start_dialog("_shop.not_enough_money")
          end
        end
      end)
    end)
  end
end

function shop_poe_soul:on_interaction()
  -- Custom shop script to subtract ore instead of rupees
  game:start_dialog("shop.poe_soul", function()
    game:start_dialog("_shop.question_ore", 80, function(answer)
      if answer == 1 then
        if game:get_value("i1836") >= 80 then
          hero:start_treasure("poe_soul")
          game:set_value("i1836",game:get_value("i1836")-80)
        else
          game:start_dialog("_shop.not_enough_money")
        end
      end
    end)
  end)
end