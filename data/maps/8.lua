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
  if game:get_value("i1068") == 9 then game:set_value("i1068", 10) end
  
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
    npc_mr_Write:set_enabled(false)
  end
  -- All the plant fetch quest helpers
  if game:get_value("b1632") then plant_baba:get_sprite():set_animation("plant_baba") else plant_baba:remove() end
  if game:get_value("b1633") then plant_corydalis:get_sprite():set_animation("plant_corydalis") else plant_corydalis:remove() end
  if game:get_value("b1634") then plant_deku:get_sprite():set_animation("plant_deku") else plant_deku:remove() end
  if game:get_value("b1635") then plant_exotic:get_sprite():set_animation("plant_exotic") else plant_exotic:remove() end
  if game:get_value("b1636") then plant_flame:get_sprite():set_animation("plant_flame") else plant_flame:remove() end
  if game:get_value("b1637") then plant_frost:get_sprite():set_animation("plant_frost") else plant_frost:remove() end
  if game:get_value("b1638") then plant_gnarled:get_sprite():set_animation("plant_gnarled") else plant_gnarled:remove() end
  if game:get_value("b1639") then plant_goponga:get_sprite():set_animation("plant_goponga") else plant_goponga:remove() end
  if game:get_value("b1640") then plant_hibiscus:get_sprite():set_animation("plant_hibiscus") else plant_hibiscus:remove() end
  if game:get_value("b1641") then plant_lavender:get_sprite():set_animation("plant_lavender") else plant_lavender:remove() end
  if game:get_value("b1642") then plant_milkweed:get_sprite():set_animation("plant_milkweed") else plant_milkweed:remove() end
  if game:get_value("b1643") then plant_mystical:get_sprite():set_animation("plant_mystical") else plant_mystical:remove() end
  if game:get_value("b1644") then plant_pikit:get_sprite():set_animation("plant_pikit") else plant_pikit:remove() end
  if game:get_value("b1645") then plant_sea:get_sprite():set_animation("plant_sea") else plant_sea:remove() end
  if game:get_value("b1646") then plant_simple:get_sprite():set_animation("plant_simple") else plant_simple:remove() end
  if game:get_value("b1647") then plant_town:get_sprite():set_animation("plant_town") else plant_town:remove() end
  for entity in game:get_map():get_entities("plant_") do entity:set_drawn_in_y_order(true) end
  -- All the book fetch quest helpers
  if game:get_value("b1623") then bookshelf_ordon:get_sprite():set_animation("book_ordon") else bookshelf_ordon:remove() end
  if game:get_value("b1617") then bookshelf_kokiri:get_sprite():set_animation("book_kokiri") else bookshelf_kokiri:remove() end
  if game:get_value("b1626") then bookshelf_tokay:get_sprite():set_animation("book_tokay") else bookshelf_tokay:remove() end
  if game:get_value("b1618") then bookshelf_gerudo:get_sprite():set_animation("book_gerudo") else bookshelf_gerudo:remove() end
  if game:get_value("b1620") then bookshelf_hylian:get_sprite():set_animation("book_hylian") else bookshelf_hylian:remove() end
  if game:get_value("b1621") then bookshelf_kakariko:get_sprite():set_animation("book_kakariko") else bookshelf_kakariko:remove() end
  if game:get_value("b1619") then bookshelf_goron:get_sprite():set_animation("book_goron") else bookshelf_goron:remove() end
  if game:get_value("b1628") then bookshelf_zora:get_sprite():set_animation("book_zora") else bookshelf_zora:remove() end
  if game:get_value("b1616") then bookshelf_anouki:get_sprite():set_animation("book_anouki") else bookshelf_anouki:remove() end
  if game:get_value("b1625") then bookshelf_rito:get_sprite():set_animation("book_rito") else bookshelf_rito:remove() end
  if game:get_value("b1624") then bookshelf_rauru:get_sprite():set_animation("book_rauru") else bookshelf_rauru:remove() end
  if game:get_value("b1622") then bookshelf_kasuto:get_sprite():set_animation("book_kasuto") else bookshelf_kasuto:remove() end
  if game:get_value("b1627") then bookshelf_zola:get_sprite():set_animation("book_zola") else bookshelf_zola:remove() end
end

function shelf_quest:on_interaction() game:start_dialog("library_shelf.quest") end
function pot_plant_baba:on_interaction() game:start_dialog("plants.plaque", function() game:start_dialog("plants.plant_baba") end) end
function pot_plant_corydalis:on_interaction() game:start_dialog("plants.plaque", function() game:start_dialog("plants.plant_corydalis") end) end
function pot_plant_deku:on_interaction() game:start_dialog("plants.plaque", function() game:start_dialog("plants.plant_deku") end) end
function pot_plant_exotic:on_interaction() game:start_dialog("plants.plaque", function() game:start_dialog("plants.plant_exotic") end) end
function pot_plant_flame:on_interaction() game:start_dialog("plants.plaque", function() game:start_dialog("plants.plant_flame") end) end
function pot_plant_frost:on_interaction() game:start_dialog("plants.plaque", function() game:start_dialog("plants.plant_frost") end) end
function pot_plant_gnarled:on_interaction() game:start_dialog("plants.plaque", function() game:start_dialog("plants.plant_gnarled") end) end
function pot_plant_goponga:on_interaction() game:start_dialog("plants.plaque", function() game:start_dialog("plants.plant_goponga") end) end
function pot_plant_hibiscus:on_interaction() game:start_dialog("plants.plaque", function() game:start_dialog("plants.plant_hibiscus") end) end
function pot_plant_lavender:on_interaction() game:start_dialog("plants.plaque", function() game:start_dialog("plants.plant_lavender") end) end
function pot_plant_milkweed:on_interaction() game:start_dialog("plants.plaque", function() game:start_dialog("plants.plant_milkweed") end) end
function pot_plant_mystical:on_interaction() game:start_dialog("plants.plaque", function() game:start_dialog("plants.plant_mystical") end) end
function pot_plant_pikit:on_interaction() game:start_dialog("plants.plaque", function() game:start_dialog("plants.plant_pikit") end) end
function pot_plant_sea:on_interaction() game:start_dialog("plants.plaque", function() game:start_dialog("plants.plant_sea") end) end
function pot_plant_simple:on_interaction() game:start_dialog("plants.plaque", function() game:start_dialog("plants.plant_simple") end) end
function pot_plant_town:on_interaction() game:start_dialog("plants.plaque", function() game:start_dialog("plants.plant_town") end) end

npc_isan:register_event("on_interaction", function()
  if game:get_value("b2031") then
    game:start_dialog("isan.0.trading", function(answer)
      if answer == 1 then
        -- Give him the fish, get the cookbook.
        game:start_dialog("isan.0.trading_yes", function()
          hero:start_treasure("trading", 12)
          game:set_value("b2032", true)
          game:set_value("b2031", false)
          if quest_book ~= nil then quest_book:remove() end
        end)
      else
        -- Don't give him the fish.
        game:start_dialog("isan.0.trading_no")
      end
    end)
  elseif game:get_value("i1615") >= 1 and game:get_value("b1614") then
    if game:get_value("i1615") >= 13 then
      game:start_dialog("isan.2.library.2_done", function()
        game:set_value("b1614", false)
        map:get_hero():start_treasure("rupees", 5)
        if quest_book ~= nil then quest_book:remove() end
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
    if index == 2 then
      game:set_value("b1614", true)
      game:set_value("i1615", 0)
      if quest_book ~= nil then quest_book:remove() end
    end
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
end)

npc_witch:register_event("on_interaction", function()
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
end)

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
  if game:get_value("i1631") >= 16 and not game:get_value("b1648") then
    game:start_dialog("kokiri_1.0.plants", function()
      map:get_hero():start_treasure("crystal") -- Give a total of 5 Magic Crystals.
      game:set_value("i1834", game:get_value("i1834" + 5))
      game:set_value("b1648", true)
    end)
  else
    game:start_dialog("kokiri_1.0.saria")
  end
end
function npc_kokiri_2:on_interaction()
  if game:get_value("i1631") >= 1 and game:get_value("b1630") then
    if game:get_value("i1631") >= 16 then
      game:start_dialog("kokiri_2.0.saria_done", function()
        game:set_value("b1630", false)
        map:get_hero():start_treasure("rupees", 5)
        if quest_plants ~= nil then quest_plants:remove() end
      end)
    else
      game:start_dialog("kokiri_2.0.saria_count", game:get_value("i1631"))
    end
  elseif game:get_value("i1631") == 0 then
    -- Give the plants fetch quest
    game:start_dialog("kokiri_2.0.saria", function() game:set_value("b1630", true) end)
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

npc_sisil:register_event("on_interaction", function()
  game:start_dialog("gerudo_1.0.nabooru")
end)
npc_mubeis:register_event("on_interaction", function()
  game:start_dialog("gerudo_2.0.nabooru")
end)
npc_gruce:register_event("on_interaction", function()
  game:start_dialog("gruce.0.nabooru", function(answer)
    if answer == 1 then
      game:set_value("i1230", 1)
      game:start_dialog("gruce.0.nabooru_yes")
    else
      game:start_dialog("gruce.0.nabooru_no")
    end
  end)
end)

np1_zora_Guard:register_event("on_interaction", function()
  game:start_dialog("zora_guard.0.great_hall")
end)
np2_zora_Guard:register_event("on_interaction", function()
  game:start_dialog("zora_guard.0.great_hall")
end)
np3_zora_Guard:register_event("on_interaction", function()
  game:start_dialog("zora_guard.0.great_hall")
end)
np4_zora_Guard:register_event("on_interaction", function()
  game:start_dialog("zora_guard.0.great_hall")
end)

npc_ejon:register_event("on_interaction", function()
  game:start_dialog("zora_1.0.ruto")
end)
npc_lula:register_event("on_interaction", function()
  game:start_dialog("zora_2.0.ruto")
end)
npc_nura:register_event("on_interaction", function()
  game:start_dialog("zora_3.0.ruto")
end)

npc_ralis:register_event("on_interaction", function()
  -- If player still doesn't have flippers, give them.
  if zora_king_spoken and not game:get_value("b1816") then
    game:start_dialog("zora_king.0.flippers", function()
      hero:start_treasure("flippers", 1)
    end)
  end
  game:start_dialog("zora_king.0.great_hall", function()
    zora_king_spoken = true
  end)
end)

npc_priest:register_event("on_interaction", function()
  if priest_spoken then
    game:start_dialog("priest.0.explain")
  else
    game:start_dialog("priest.0.sanctuary", function() priest_spoken = true end)
  end
end)

npc_mr_Write:register_event("on_interaction", function()
  -- Mr. Write is enabled only when the books are found, so no need to do the check here.
  game:start_dialog("mr_write.0.house", function()
    map:get_hero():start_treasure("crystal") -- Give a total of 5 Magic Crystals.
    game:set_value("i1834", game:get_value("i1834"+4))
  end)
end)

npc_sanday:register_event("on_interaction", function()
  -- If hero has spoken with Mosq (astronomer) the dialog changes.
  if game:get_value("astronomer_spoken") and game:get_value("sanday_spoken") then
    game:start_dialog("sanday.1.house")
  else
    game:start_dialog("sanday.0.house")
    game:set_value("sanday_spoken", true)
  end
end)

npc_mayor:register_event("on_interaction", function()
  if game:get_max_life() >= 40 and game:get_item("world_map"):get_variant() < 3 then
    game:start_dialog("mayor.1.kasuto", function()
      hero:start_treasure("world_map", 3)
    end)
  elseif game:get_max_life() < 40 then
    game:start_dialog("mayor.0.kasuto")
  else
    game:start_dialog("mayor.2.kasuto")
  end
end)

np1_guard:register_event("on_interaction", function()
  game:start_dialog("guard.0.north_castle")
end)
np2_guard:register_event("on_interaction", function()
  game:start_dialog("guard.0.north_castle")
end)
np3_guard:register_event("on_interaction", function()
  game:start_dialog("guard.0.north_castle")
end)
np4_guard:register_event("on_interaction", function()
  game:start_dialog("guard.0.north_castle")
end)