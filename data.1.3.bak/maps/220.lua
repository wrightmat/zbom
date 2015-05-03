local map = ...
local game = map:get_game()

function map:on_started()

end

function switch:on_activated()
  print("activated")
end
function switch:on_inactivated()
  print("inactivated")
end
