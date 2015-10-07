local map = ...
local game = map:get_game()

--------------------------------------------------------------------------
-- Outside World H14 (Floria Peninsula) - Floria Babas (Overworld Boss) --
--------------------------------------------------------------------------

function map:on_started()
  if not game:get_value("b1704") then chest_heart_piece:set_enabled(false) end
end

for enemy in map:get_entities("baba_floria") do
  enemy.on_dead = function()
    if not map:has_entities("baba_floria") and not game:get_value("b1704") then
      chest_heart_piece:set_enabled(true)
      sol.audio.play_sound("chest_appears")
    end
  end
end