local map = ...
local game = map:get_game()

-----------------------------------------------------
-- Outside World G6 (Zora's Domain/Death Mountain) --
-----------------------------------------------------

if game:get_value("i1923")==nil then game:set_value("i1923", 0) end

function map:on_started(destination)

end

function zora_gatekeeper:on_interaction()
  if game:get_value("i1923") <= 4 then
    game:start_dialog("zora_gatekeeper."..game:get_value("i1923")..".domain")
    game:set_value("i1923", game:get_value("i1923")+1)
  elseif game:get_value("i1924") >= 2 then
    game:start_dialog("zora_gatekeeper.5.domain")
    game:set_value("i1923", 5)
  else
    game:start_dialog("zora_gatekeeper.4.domain")
  end
end
