local map = ...
local game = map:get_game()

function map:on_started()
  enemy:set_enabled(false)
end

function sensor:on_activated()
  enemy:set_enabled(true)
end