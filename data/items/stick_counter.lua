local item = ...
local game = item:get_game()

function item:on_created()
  self:set_savegame_variable("i1846")
  self:set_amount_savegame_variable("i1847")
  self:set_max_amount(99)
end

function item:on_using()
  if self:get_amount() == 0 then
    sol.audio.play_sound("wrong")
  end
  self:set_finished()
end