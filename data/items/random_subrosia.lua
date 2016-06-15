local item = ...

-- When it is created, this item creates another item randomly chosen
-- and then destroys itself.

-- Probability of each item between 0 and 1000.
local probabilities = {
  [{ "bomb", 1 }]       = 8,    -- 1 bomb.
  [{ "bomb", 2 }]       = 5,    -- 3 bombs.
  [{ "bomb", 3 }]       = 2,    -- 8 bombs.
  [{ "arrow", 1 }]      = 8,    -- 1 arrow.
  [{ "arrow", 2 }]      = 5,    -- 5 arrows.
  [{ "arrow", 3 }]      = 2,    -- 10 arrows.
  [{ "magic_flask", 1}] = 20,   -- Small magic jar.
  [{ "magic_flask", 2}] = 8,    -- Big magic jar.
  [{ "heart", 1}]       = 10,   -- Heart.
  [{ "fairy", 1}]       = 2,    -- Fairy.
  [{ "alchemy", 1}]     = 1.5,  -- Alchemy Stone (rare drop item).
  [{ "plume", 1 }]      = 1,    -- Goddess Plume (exceptionally rare drop item).
  [{ "amber", 1 }]      = 4,    -- Goron Amber (fairly rare drop item, only found in mountain areas).
  [{ "crystal", 1 }]    = 3,    -- Magic Crystal (fairly rare drop item, only found in North Hyrule).
  [{ "ore", 1 }]        = 50,   -- Subrosian Ore (drop item, only found in Subrosia).
  [{ "ore", 2 }]        = 20,   -- Subrosian Ore (drop item, only found in Subrosia).
}

function item:on_pickable_created(pickable)
  local treasure_name, treasure_variant = self:choose_random_item()
  if treasure_name ~= nil then
    local map = pickable:get_map()
    local x, y, layer = pickable:get_position()
    map:create_pickable{
      layer = layer,
      x = x,
      y = y,
      treasure_name = treasure_name,
      treasure_variant = treasure_variant,
    }
  end
  pickable:remove()
end

-- Returns an item name and variant.
function item:choose_random_item()
  local random = math.random(1000)
  local sum = 0
  for key, probability in pairs(probabilities) do
    sum = sum + probability
    if random < sum then
      return key[1], key[2]
    end
  end
  return nil
end