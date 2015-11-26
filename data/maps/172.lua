local map = ...
local game = map:get_game()

-------------------------------------------
-- Fire Sanctuary - Mini Dungeon, Hammer --
-------------------------------------------

function map:on_started(destination)

end

function switch_rust_1:on_activated()
  map:open_doors("door_w")
  if switch_rust_2:is_activated() then map:open_doors("door_n") end
end

function switch_rust_1:on_inactivated()
  map:close_doors("door_w")
end

function switch_rust_2:on_activated()
  map:open_doors("door_e")
  if switch_rust_1:is_activated() then map:open_doors("door_n") end
end

function switch_rust_2:on_inactivated()
  map:close_doors("door_e")
end