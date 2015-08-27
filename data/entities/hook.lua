-- An entity the hookshot can attach to.
-- To be used with the scripted hookshot item.
local hook = ...

-- Tell the hookshot that it can hook to us.
function hook:is_hookshot_hook()
  return true
end

hook:set_traversable_by(false)