local item = ...

function item:on_created()
  self:set_savegame_variable("i1855")
  self:set_assignable(true)
  self:set_amount_savegame_variable("i1856")
  self:set_max_amount(10)
end

function item:on_using()
  if self:get_game():get_value("i1026")==nil then self:get_game():set_value("i1026", 0) end

  if self:get_amount() == 0 or self:get_game():get_max_stamina() == 0 then
    sol.audio.play_sound("wrong")
  else
    sol.audio.play_sound("chewing")
    self:remove_amount(1)
    self:get_game():add_life(20)
    self:get_game():set_value("i1026", self:get_game():get_value("i1026")+1)
    local amount = 500-(self:get_game():get_value("i1026")*50)
    self:get_game():add_stamina(amount)
  end
  self:set_finished()
end