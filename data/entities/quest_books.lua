local game = self:get_game()
local map = game:get_map()

function self:on_created()
  if game:get_value("b1614") then
    self:get_sprite():set_animation(self:get_name())
  else
    -- Fetch Quest hasn't been initiated, so remove the entity.
    self:remove()
  end
end

function self:on_interaction()
  -- If the book is interacted with, then start
  -- the dialog and increment the quest counter.
  game:start_dialog("library_shelf."..self:get_name(), function()
    game:set_value("i1615", game:get_value("i1615")+1)
    if self:get_name() == "book_anouki" then game:set_value("b1616", true) end
    if self:get_name() == "book_deku" then game:set_value("b1617", true) end
    if self:get_name() == "book_gerudo" then game:set_value("b1618", true) end
    if self:get_name() == "book_goron" then game:set_value("b1619", true) end
    if self:get_name() == "book_hylian" then game:set_value("b1620", true) end
    if self:get_name() == "book_kakariko" then game:set_value("b1621", true) end
    if self:get_name() == "book_kasuto" then game:set_value("b1622", true) end
    if self:get_name() == "book_ordon" then game:set_value("b1623", true) end
    if self:get_name() == "book_rauru" then game:set_value("b1624", true) end
    if self:get_name() == "book_rito" then game:set_value("b1625", true) end
    if self:get_name() == "book_tokay" then game:set_value("b1626", true) end
    if self:get_name() == "book_zola" then game:set_value("b1627", true) end
    if self:get_name() == "book_zora" then game:set_value("b1628", true) end
  end)
  -- Lastly, remove the book - it's taken.
  self:remove()
end