local item = ...
local game = item:get_game()

function item:on_created()
  self:set_savegame_variable("i1853")
  self:set_assignable(true)
  self:set_amount_savegame_variable("i1854")
  self:set_max_amount(20)
end

function item:on_using()
  if game:get_value("i1026") == nil then game:set_value("i1026", 0) end
  if game:get_value("i1026") <= 0 then game:set_value("i1026", 0) end

  if self:get_amount() == 0 or game:get_max_stamina() == 0 then
    sol.audio.play_sound("wrong")
  else
    sol.audio.play_sound("chewing")
    self:remove_amount(1)
    game:add_life(12) -- 3 hearts
    game:set_value("i1026", game:get_value("i1026")+1)
    local amount = 300-game:get_value("i1026")*30
    if amount <= 30 then game:start_dialog("_exhausted_sleep") end
    game:add_stamina(amount)
  end
  self:set_finished()
end