local map = ...
local game = map:get_game()

---------------------------------------------------
-- Outside C4 (Calatia Outskirts) - Enemy Hoarde --
---------------------------------------------------

function map:on_started(destination)
  if not game:get_value("swamp_camp_crystal") then chest_crystal:set_enabled(false) end
end

for enemy in map:get_entities("zola") do
  enemy.on_dead = function()
    if not map:has_entities("zola") and not game:get_value("swamp_camp_crystal") then
      chest_crystal:set_enabled(true)
      sol.audio.play_sound("chest_appears")
    end
  end
end

if game:get_time_of_day() ~= "night" then
  function map:on_draw(dst_surface)
    if game.deception_fog_overlay ~= nil then game.deception_fog_overlay:draw(dst_surface) end
  end
end