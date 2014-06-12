local map = ...
local game = map:get_game()
local particle_system = require("particles")
local emitter = particle_system:new(game)

function map:on_started(destination)

end

function sensor:on_activated()
  emitter:set_type("fire")
  emitter:set_position(200, 200)
  emitter:set_particle_count(30)
  emitter:set_particle_color({255,255,255})
  emitter:set_decay_time(40)
  emitter:initialize()
  sol.timer.start(map, 50, function()
    if emitter ~= nil then emitter:on_update(1) end
    return true
  end)
end

function map:on_draw(dst_surface)
  if emitter ~= nil then emitter:on_draw(dst_surface) end
end
