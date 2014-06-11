local map = ...
local game = map:get_game()
local particle_system = require("particles")
local emitter = particle_system:new(game)

function map:on_started(destination)

end

function sensor:on_activated()
  emitter:set_type("fire")
  emitter:set_position(100, 100)
  emitter:set_particle_count(500000)
  emitter:set_particle_color({255,255,255})
  emitter:set_decay_time(15)
  emitter:initialize()
  sol.timer.start(map, 50, function()
    if emitter ~= nil then emitter:on_update(0.8) end
    return true
  end)
end

function map:on_draw(dst_surface)
  if emitter ~= nil then emitter:on_draw(dst_surface) end
end
