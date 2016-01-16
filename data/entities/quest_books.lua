local entity = ...
local game = entity:get_game()
local map = entity:get_map()
local hero_facing = false
local action_command = false

function entity:on_created()
  self:set_traversable_by("hero", false)
  if game:get_value("b1614") then
    entity:get_sprite():set_animation(entity:get_name())
  else
    -- Fetch Quest hasn't been initiated, so remove the entity.
    entity:remove()
  end
  if entity:get_name() == "book_anouki" and game:get_value("b1616") then entity:remove() end
    if entity:get_name() == "book_deku" and game:get_value("b1617") then entity:remove() end
    if entity:get_name() == "book_gerudo" and game:get_value("b1618") then entity:remove() end
    if entity:get_name() == "book_goron" and game:get_value("b1619") then entity:remove() end
    if entity:get_name() == "book_hylian" and game:get_value("b1620") then entity:remove() end
    if entity:get_name() == "book_kakariko" and game:get_value("b1621") then entity:remove() end
    if entity:get_name() == "book_kasuto" and game:get_value("b1622") then entity:remove() end
    if entity:get_name() == "book_ordon" and game:get_value("b1623") then entity:remove() end
    if entity:get_name() == "book_rauru" and game:get_value("b1624") then entity:remove() end
    if entity:get_name() == "book_rito" and game:get_value("b1625") then entity:remove() end
    if entity:get_name() == "book_tokay" and game:get_value("b1626") then entity:remove() end
    if entity:get_name() == "book_zola" and game:get_value("b1627") then entity:remove() end
    if entity:get_name() == "book_zora" and game:get_value("b1628") then entity:remove() end
end

entity:add_collision_test("facing", function(entity, other)
  if other:get_type() == "hero" then 
    hero_facing = true
    if hero_facing then
      game:set_custom_command_effect("action", "look")
      action_command = true
    else
      game:set_custom_command_effect("action", nil)
    end
  end
end)

function entity:on_interaction()
  -- If the book is interacted with, then start
  -- the dialog and increment the quest counter.
  game:start_dialog("library_shelf."..entity:get_name(), function()
    game:set_value("i1615", game:get_value("i1615")+1)
    if entity:get_name() == "book_anouki" then game:set_value("b1616", true) end
    if entity:get_name() == "book_deku" then game:set_value("b1617", true) end
    if entity:get_name() == "book_gerudo" then game:set_value("b1618", true) end
    if entity:get_name() == "book_goron" then game:set_value("b1619", true) end
    if entity:get_name() == "book_hylian" then game:set_value("b1620", true) end
    if entity:get_name() == "book_kakariko" then game:set_value("b1621", true) end
    if entity:get_name() == "book_kasuto" then game:set_value("b1622", true) end
    if entity:get_name() == "book_ordon" then game:set_value("b1623", true) end
    if entity:get_name() == "book_rauru" then game:set_value("b1624", true) end
    if entity:get_name() == "book_rito" then game:set_value("b1625", true) end
    if entity:get_name() == "book_tokay" then game:set_value("b1626", true) end
    if entity:get_name() == "book_zola" then game:set_value("b1627", true) end
    if entity:get_name() == "book_zora" then game:set_value("b1628", true) end
  end)
  -- Lastly, remove the book - it's taken.
  entity:remove()
end

function entity:on_update()
  if action_command and not hero_facing then
    game:set_custom_command_effect("action", nil)
    action_command = false
  end
  hero_facing = false
end