local map = ...
local game = map:get_game()

function map:on_draw(dst_surface)
  if game.deception_fog_overlay ~= nil then game.deception_fog_overlay:draw(dst_surface) end
end

local function random_walk(npc)
  local m = sol.movement.create("random_path")
  m:set_speed(32)
  m:start(npc)
  npc:get_sprite():set_animation("walking")
end

function map:on_started(destination)
  random_walk(npc_earmuffs)
end

function npc_earmuffs:on_interaction()
  game:start_dialog("hylian_earmuffs.0.calatia")
end