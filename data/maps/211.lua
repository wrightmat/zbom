local map = ...
local game = map:get_game()

---------------------------------------------
-- Dungeon 7: Tower of the Winds (Floor 2) --
---------------------------------------------

map:register_event("on_started", function(self, destination)
  if game:get_value("b1163") then
    map:open_doors("door_shutter")
    map:open_doors("door_puzzle")
    map:remove_entities("keese")
  end
end)

for enemy in map:get_entities("keese") do
  enemy.on_dead = function()
    if not map:has_entities("keese") then
      map:open_doors("door_shutter")
      game:set_value("b1163", true)
    end
  end
end

function switch_arrow_1:on_activated()
  self:set_locked(true)
  if switch_arrow_2:is_activated() and switch_arrow_3:is_activated() and switch_arrow_4:is_activated() then
    map:open_doors("door_puzzle")
  end
end
function switch_arrow_2:on_activated()
  self:set_locked(true)
  if switch_arrow_1:is_activated() and switch_arrow_3:is_activated() and switch_arrow_4:is_activated() then
    map:open_doors("door_puzzle")
  end
end
function switch_arrow_3:on_activated()
  self:set_locked(true)
  if switch_arrow_1:is_activated() and switch_arrow_2:is_activated() and switch_arrow_4:is_activated() then
    map:open_doors("door_puzzle")
  end
end
function switch_arrow_4:on_activated()
  self:set_locked(true)
  if switch_arrow_1:is_activated() and switch_arrow_2:is_activated() and switch_arrow_3:is_activated() then
    map:open_doors("door_puzzle")
  end
end
