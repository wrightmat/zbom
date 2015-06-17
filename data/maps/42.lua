local map = ...
local game = map:get_game()

--------------------------------------------------------------------
-- Outside World D9 (Field/Lake Hylia) - Peahats (Overworld Boss) --
--------------------------------------------------------------------

function map:on_started()
  if not game:get_value("b1705") then chest_heart_piece:set_enabled(false) end
end

for enemy in map:get_entities("peahat") do
  enemy.on_dead = function()
    if not map:has_entities("peahat") and not game:get_value("b1705") then
      chest_heart_piece:set_enabled(true)
      sol.audio.play_sound("chest_appears")
    end
  end
end