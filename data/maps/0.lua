local map = ...

-- This will be cool intro stuff... eventually...
-- For now it's my cool boss test ground!
function map:on_started(destination)
  hero:teleport(1, "from_intro")
  --boss:set_enabled(false)
  --hero:start_treasure("sword")
end

--function sensor:on_activated()
  --hero:start_treasure("bow")
  --boss:set_enabled(true)
  --sensor:set_enabled(false)
--end
