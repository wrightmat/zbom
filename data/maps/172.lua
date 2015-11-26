local map = ...
local game = map:get_game()

-------------------------------------------
-- Fire Sanctuary - Mini Dungeon, Hammer --
-------------------------------------------

function map:on_started(destination)
  chest_rupees:set_enabled(false)
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

function switch_rust_3:on_activated()
  map:create_chest({ layer = 0, x = 496, y = 621, treasure_name = "hammer", sprite = "entities/chest" })
end

function switch_rust_4:on_activated()
  if switch_rust_5:is_activated() and switch_rust_6:is_activated() then
    chest_rupees:set_enabled(true)
  end
end

function switch_rust_5:on_activated()
  if switch_rust_4:is_activated() and switch_rust_6:is_activated() then
    chest_rupees:set_enabled(true)
  end
end

function switch_rust_6:on_activated()
  if switch_rust_5:is_activated() and switch_rust_4:is_activated() then
    chest_rupees:set_enabled(true)
  end
end