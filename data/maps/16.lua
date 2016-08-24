local map = ...
local game = map:get_game()

--------------------------------------------------------------------------------------
-- Outside World E13 (Faron Woods-Poisoned) - Poisonsed Trees, Great Fairy Fountain --
--------------------------------------------------------------------------------------

if game:get_value("i1602")==nil then game:set_value("i1602", 0) end

function map:on_started(destination)
  if game:get_value("i1602") < 1 or game:get_value("i1602") >= 4 then
    npc_gaira:remove()
  end
  if game:get_value("b1699") and game:get_value("i1603") >= 5 then
    -- If main quest and Great Fairy side quest are complete, remove the poison.
    map:set_entities_enabled("trees", false)
    if npc_gaira ~= nil then npc_gaira:remove() end
  end
end