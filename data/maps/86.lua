local map = ...
local game = map:get_game()

-----------------------------------------------
-- Outside A2 (Calatia Peaks) - Enemy Hoarde --
-----------------------------------------------

local function random_walk(npc)
  local m = sol.movement.create("random_path")
  m:set_speed(32)
  m:start(npc)
  npc:get_sprite():set_animation("walking")
end

function map:on_started(destination)
  if not game:get_value("pengator_camp_crystal") then chest_crystal:set_enabled(false) end
  random_walk(npc_earmuffs)
end

for enemy in map:get_entities("pengator") do
  enemy.on_dead = function()
    if not map:has_entities("pengator") and not game:get_value("pengator_camp_crystal") then
      chest_crystal:set_enabled(true)
      sol.audio.play_sound("chest_appears")
    end
  end
end

function npc_earmuffs:on_interaction()
  game:start_dialog("hylian_earmuffs.0.calatia")
end

if game:get_time_of_day() ~= "night" then
  function map:on_draw(dst_surface)
    if game.deception_fog_overlay ~= nil then game.deception_fog_overlay:draw(dst_surface) end
  end
end