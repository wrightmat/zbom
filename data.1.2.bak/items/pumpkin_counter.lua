local item = ...

function item:on_created()
  self:set_savegame_variable("i1844")
  self:set_assignable(true)
  self:set_amount_savegame_variable("i1845")
  self:set_max_amount(50)
end

function item:on_using()
  if self:get_amount() == 0 then
    sol.audio.play_sound("wrong")
  else

  end
  self:set_finished()
end