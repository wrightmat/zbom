local map = ...
local game = map:get_game()

------------------------------------------
-- Inside North Hyrule houses and such  --
------------------------------------------

local priest_spoken = false
local zora_king_spoken = false
if game:get_value("i1615")==nil then game:set_value("i1615", 0) end
if game:get_value("i1631")==nil then game:set_value("i1631", 0) end
if game:get_value("i1912")==nil then game:set_value("i1912", 0) end

function map:on_started(destination)
  if not game:get_value("b2031") and not game:get_value("b1614") then quest_book:remove() end -- Quest bubble references trading quest and fetch quest.
  if destination == from_outside_door1 or destination == from_outside_door2 then sol.audio.play_music("mudora") end
  if destination == enter_rauru_sanctuary then sol.audio.play_music("sanctuary") end
  if not game:get_value("b2024") then quest_trading_ball:remove() end
  if game:get_value("i1032") >= 2 then door:set_enabled(false) end
  if game:get_value("i1840") >= 5 then
    table_witch:set_enabled(true) -- Crystal ball is gone.
  end
  if game:get_value("i1068") == "9" then game:set_value("i1068", "10") end

  spoils_jade:get_sprite():set_animation("jade")
  spoils_stick:get_sprite():set_animation("stick")
  spoils_amber:get_sprite():set_animation("amber")
  spoils_alchemy:get_sprite():set_animation("alchemy")
  spoils_plume:get_sprite():set_animation("plume")
  spoils_ore:get_sprite():set_animation("ore")

  -- Activate any night-specific dynamic tiles.
  if game:get_time_of_day() == "night" then
    for entity in game:get_map():get_entities("night_") do
      entity:set_enabled(true)
    end
  else
    npc_mayor:remove()
  end
  -- Mr. Write will be enabled after you've collected all the books. Will reward you with treasures (magic crystal mostly).
  if game:get_value("i1615") < 13 then
    npc_mr_write:set_enabled(false)
  end
end

function npc_isan:on_interaction()
  if game:get_value("b2031") then
    game:start_dialog("isan.0.trading", function(answer)
      if answer == 1 then
        -- Give him the fish, get the cookbook.
        game:start_dialog("isan.0.trading_yes", function()
          hero:start_treasure("trading", 12)
          game:set_value("b2032", true)
          game:set_value("b2031", false)
          quest_book:remove()
        end)
      else
        -- Don't give him the fish.
        game:start_dialog("isan.0.trading_no")
      end
    end)
  elseif game:get_value("i1615") > 1 and game:get_value("b1614") then
    if game:get_value("i1615") == 12 then
      game:start_dialog("isan.2.library.2_done", function()
        game:set_value("b1614", false)
        map:get_hero():start_treasure("rupees", 5)
      end)
    else
      game:start_dialog("isan.2.library.2_count", game:get_value("i1615"))
    end
  elseif game:get_value("i1912") == 2 then
    repeat -- Make sure the same quote is not picked again.
      index = math.random(3)
    until index ~= last_message
    game:start_dialog("isan.2.library."..index)
    -- Initiate the book fetch quest after it's been referenced.
    if index == 2 then game:set_value("b1614", true) end
    last_message = index
  elseif game:get_value("i1912") == 1 then
    game:start_dialog("isan.1.library", function()
      game:set_value("i1912", game:get_value("i1912")+1)
    end)
  else
    game:start_dialog("isan.0.library", function()
      game:set_value("i1032", 1)
      game:set_value("i1912", game:get_value("i1912")+1)
    end)
  end
end

function npc_saria_witch:on_interaction()
  if game:get_value("i1840") >= 5 then
    game:start_dialog("witch.1.house")
  elseif game:get_value("b2024") then
    game:start_dialog("witch.0.trading", function(answer)
      if answer == 1 then
        -- Give her the tear, get the crystal ball.
        game:start_dialog("witch.0.trading_yes", function()
          hero:start_treasure("trading", 5)
          game:set_value("b2025", true)
          game:set_value("b2024", false)
          table_witch:set_enabled(true)
          quest_trading_ball:remove()
        end)
      else
        -- Don't give her the tear.
        game:start_dialog("witch.0.trading_no")
      end
    end)
  else
    game:start_dialog("witch.0.house")
  end
end

function shelf_1:on_interaction()
  game:start_dialog("library_shelf.1")
end
function shelf_2:on_interaction()
  game:start_dialog("library_shelf.2")
end
function shelf_3:on_interaction()
  game:start_dialog("library_shelf.3")
end
function shelf_4:on_interaction()
  game:start_dialog("library_shelf.4")
end
function shelf_5:on_interaction()
  game:start_dialog("library_shelf.5")
end
function shelf_6:on_interaction()
  game:start_dialog("library_shelf.6")
end
function shelf_7:on_interaction()
  game:start_dialog("library_shelf.7")
end
function shelf_8:on_interaction()
  game:start_dialog("library_shelf.8")
end
function shelf_9:on_interaction()
  game:start_dialog("library_shelf.9")
end
function shelf_10:on_interaction()
  game:start_dialog("library_shelf.10")
end
function shelf_11:on_interaction()
  game:start_dialog("library_shelf.11")
end
function shelf_12:on_interaction()
  game:start_dialog("library_shelf.12")
end
function shelf_13:on_interaction()
  game:start_dialog("library_shelf.13")
end
function shelf_14:on_interaction()
  game:start_dialog("library_shelf.14")
end
function shelf_15:on_interaction()
  if game:get_item("book_mudora"):get_variant() == 6 then
    game:start_dialog("library_shelf.15")
  else
    game:start_dialog("library_shelf")
  end
end
function shelf_16:on_interaction()
  if game:get_item("book_mudora"):get_variant() == 7 then
    game:start_dialog("library_shelf.16")
  else
    game:start_dialog("library_shelf")
  end
end
function shelf_17:on_interaction()
  if game:get_item("book_mudora"):get_variant() == 7 then
    game:start_dialog("library_shelf.17")
  else
    game:start_dialog("library_shelf")
  end
end
function shelf_18:on_interaction()
  if game:get_item("book_mudora"):get_variant() == 8 then
    game:start_dialog("library_shelf.18")
  else
    game:start_dialog("library_shelf")
  end
end

function npc_spoils_shopkeep:on_interaction()
  game:start_dialog("shopkeep.spoils_explain")
end

function spoils_jade:on_interaction()
  game:start_dialog("shopkeep.spoils", "mystic jade", function(answer)
    if answer == 1 then
      if game:get_value("i1849") >= 5 then
        game:set_value("i1849", game:get_value("i1849")-5)
        game:add_money(100)
        game:start_dialog("shopkeep.spoils_yes")
      else
        game:start_dialog("_shop.not_enough_money")
      end
    else
      game:start_dialog("shopkeep.spoils_no")
    end
  end)
end

function spoils_stick:on_interaction()
  game:start_dialog("shopkeep.spoils", "deku sticks", function(answer)
    if answer == 1 then
      if game:get_value("i1847") >= 5 then
        game:set_value("i1847", game:get_value("i1847")-5)
        game:add_money(100)
        game:start_dialog("shopkeep.spoils_yes")
      else
        game:start_dialog("_shop.not_enough_money")
      end
    else
      game:start_dialog("shopkeep.spoils_no")
    end
  end)
end

function spoils_amber:on_interaction()
  game:start_dialog("shopkeep.spoils", "goron amber", function(answer)
    if answer == 1 then
      if game:get_value("i1828") >= 5 then
        game:set_value("i1828", game:get_value("i1828")-5)
        game:add_money(100)
        game:start_dialog("shopkeep.spoils_yes")
      else
        game:start_dialog("_shop.not_enough_money")
      end
    else
      game:start_dialog("shopkeep.spoils_no")
    end
  end)
end

function spoils_alchemy:on_interaction()
  game:start_dialog("shopkeep.spoils", "alchemy stone", function(answer)
    if answer == 1 then
      if game:get_value("i1830") >= 5 then
        game:set_value("i1830", game:get_value("i1830")-5)
        game:add_money(100)
        game:start_dialog("shopkeep.spoils_yes")
      else
        game:start_dialog("_shop.not_enough_money")
      end
    else
      game:start_dialog("shopkeep.spoils_no")
    end
  end)
end

function spoils_plume:on_interaction()
  game:start_dialog("shopkeep.spoils", "goddess plume", function(answer)
    if answer == 1 then
      if game:get_value("i1832") >= 5 then
        game:set_value("i1832", game:get_value("i1832")-5)
        game:add_money(100)
        game:start_dialog("shopkeep.spoils_yes")
      else
        game:start_dialog("_shop.not_enough_money")
      end
    else
      game:start_dialog("shopkeep.spoils_no")
    end
  end)
end

function spoils_ore:on_interaction()
  game:start_dialog("shopkeep.spoils", "subrosian ore", function(answer)
    if answer == 1 then
      if game:get_value("i1836") >= 5 then
        game:set_value("i1836", game:get_value("i1836")-5)
        game:add_money(100)
        game:start_dialog("shopkeep.spoils_yes")
      else
        game:start_dialog("_shop.not_enough_money")
      end
    else
      game:start_dialog("shopkeep.spoils_no")
    end
  end)
end

function npc_kokiri_1:on_interaction()
  if game:get_value("i1631") >= 16 then
    game:start_dialog("kokiri_1.0.plants", function()
      map:get_hero():start_treasure("crystal") -- Give a total of 5 Magic Crystals.
      game:set_value("i1834", game:get_value("i1834"+4))
    end)
  else
    game:start_dialog("kokiri_1.0.saria")
  end
end
function npc_kokiri_2:on_interaction()
  if not game:get_value("b1630") then
    game:start_dialog("kokiri_2.0.saria", function()
      game:set_value("b1630", true)
    end)
  else
    game:start_dialog("kokiri_2.0.saria_count", game:get_value("i1631"))
    quest_plants:remove()
  end
end

function npc_hylian_2:on_interaction()
  game:start_dialog("hylian_2.0.rauru")
end
function npc_hylian_3:on_interaction()
  game:start_dialog("hylian_3.0.rauru")
end
function npc_hylian_4:on_interaction()
  game:start_dialog("hylian_4.0.rauru")
end
function npc_hylian_5:on_interaction()
  game:start_dialog("hylian_5.0.rauru")
end
function npc_kasuto_3:on_interaction()
  game:start_dialog("hylian_3.0.kasuto")
end
function npc_kasuto_4:on_interaction()
  game:start_dialog("hylian_4.0.kasuto")
end

function npc_gerudo_1:on_interaction()
  game:start_dialog("gerudo_1.0.nabooru")
end
function npc_gerudo_2:on_interaction()
  game:start_dialog("gerudo_2.0.nabooru")
end
function npc_gruce:on_interaction()
  game:start_dialog("gruce.0.nabooru", function() game:get_value("i1230", 1) end)
end

function npc_zora_guard_1:on_interaction()
  game:start_dialog("zora_guard.0.great_hall")
end
function npc_zora_guard_2:on_interaction()
  game:start_dialog("zora_guard.0.great_hall")
end
function npc_zora_guard_3:on_interaction()
  game:start_dialog("zora_guard.0.great_hall")
end
function npc_zora_guard_4:on_interaction()
  game:start_dialog("zora_guard.0.great_hall")
end

function npc_zora_1:on_interaction()
  game:start_dialog("zora_1.0.ruto")
end
function npc_zora_2:on_interaction()
  game:start_dialog("zora_2.0.ruto")
end
function npc_zora_3:on_interaction()
  game:start_dialog("zora_3.0.ruto")
end

function npc_zora_king:on_interaction()
  -- If player still doesn't have flippers, give them.
  if zora_king_spoken and not game:get_value("b1816") then
    game:start_dialog("zora_king.0.flippers", function()
      hero:start_treasure("flippers", 1)
    end)
  end
  game:start_dialog("zora_king.0.great_hall", function()
    zora_king_spoken = true
  end)
end

function npc_priest:on_interaction()
  if priest_spoken then
    game:start_dialog("priest.0.explain")
  else
    game:start_dialog("priest.0.sanctuary", function() priest_spoken = true end)
  end
end

function npc_mr_write:on_interaction()
  -- Mr. Write is enabled only when the books are found, so no need to do the check here.
  game:start_dialog("mr_write.0.house", function()
    map:get_hero():start_treasure("crystal") -- Give a total of 5 Magic Crystals.
    game:set_value("i1834", game:get_value("i1834"+4))
  end)
end

function npc_sanday:on_interaction()
  -- If hero has spoken with Mosq (astronomer) the dialog changes.
  if game:get_value("astronomer_spoken") and game:get_value("sanday_spoken") then
    game:start_dialog("sanday.1.house")
  else
    game:start_dialog("sanday.0.house")
    game:set_value("sanday_spoken", true)
  end
end

function npc_mayor:on_interaction()
  if game:get_max_life() >= 40 and game:get_item("world_map"):get_variant() < 3 then
    game:start_dialog("mayor.1.kasuto", function()
      hero:start_treasure("world_map", 3)
    end)
  elseif game:get_max_life() < 40 then
    game:start_dialog("mayor.0.kasuto")
  else
    game:start_dialog("mayor.2.kasuto")
  end
end