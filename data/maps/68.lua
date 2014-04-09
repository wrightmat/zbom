local map = ...
local game = map:get_game()

------------------------------------------------------
-- Outside World I6 (Death Mountain/Mausoleum Entr) --
------------------------------------------------------

function map:on_started(destination)

end

function game:on_map_changed(map)
  function map:on_draw(dst_surface)
    if map:get_id() == "68" and lantern_overlay then lantern_overlay:fade_out() end
  end
end
