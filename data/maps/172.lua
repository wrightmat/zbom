local map = ...
local game = map:get_game()

-------------------------------------------
-- Fire Sanctuary - Mini Dungeon, Hammer --
-------------------------------------------

function map:on_started(destination)
  chest_rupees:set_enabled(false)
  switch_rust_3:set_properties({ stay_down = true })
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
  sol.audio.play_sound("secret")
  map:move_camera(496, 621, 200, function()
    if game:has_item("hammer") then
      map:create_chest({ layer = 0, x = 496, y = 621, treasure_name = "rupee", sprite = "entities/chest", 6, "b1210" })
    else
      map:create_chest({ layer = 0, x = 496, y = 621, treasure_name = "hammer", sprite = "entities/chest", 1, "b1210" })
    end
  end)
end

function switch_rust_4:on_activated()
  if switch_rust_5:is_activated() and switch_rust_6:is_activated() then
    sol.audio.play_sound("secret")
    map:move_camera(472, 101, 200, function() chest_rupees:set_enabled(true) end)
  end
end

function switch_rust_5:on_activated()
  if switch_rust_4:is_activated() and switch_rust_6:is_activated() then
    sol.audio.play_sound("secret")
    map:move_camera(472, 101, 200, function() chest_rupees:set_enabled(true) end)
  end
end

function switch_rust_6:on_activated()
  if switch_rust_5:is_activated() and switch_rust_4:is_activated() then
    sol.audio.play_sound("secret")
    map:move_camera(472, 101, 200, function() chest_rupees:set_enabled(true) end)
  end
end