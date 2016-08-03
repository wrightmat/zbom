local item = ...
local game = item:get_game()

function item:on_created()
  self:set_sound_when_picked(nil)
  self:set_sound_when_brandished("heart_container")
end

function item:on_obtaining(variant, savegame_variable)
  game:add_max_life(4)
  game:set_life(game:get_max_life())
  self:get_game():add_stamina(50)
end