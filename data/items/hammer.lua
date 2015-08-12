local item = ...

function item:on_created()
  self:set_savegame_variable("i1839")
  self:set_assignable(true)
end

function item:on_npc_interaction(npc)
  if npc:get_name():find("^stake^") then
    npc:set_enabled(false)
  end
end