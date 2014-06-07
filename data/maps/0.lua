local map = ...
local game = map:get_game()
local particle_system = require("particles")
local emitter = particle_system:new(game)

function map:on_started(destination)

end

function sensor:on_activated()
  emitter:set_type("sparkle")
  emitter:set_position(100, 100)
  emitter:set_particle_count(50)
  emitter:set_decay_time(10)
  emitter:initialize()
  sol.timer.start(map, 1000, function()
    if emitter ~= nil then emitter:on_update(1) end
    return true
  end)
end

function map:on_draw(dst_surface)
  if emitter ~= nil then emitter:on_draw(dst_surface) end
end
