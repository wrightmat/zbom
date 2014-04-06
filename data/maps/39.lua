local map = ...
local game = map:get_game()

------------------------------------------------------------------------
-- Outside World G9 (Eastern Ruins-Sewer Access) - To Ancient Library --
------------------------------------------------------------------------

function game:on_map_changed(map)
  function map:on_draw(dst_surface)
    -- clear away lantern overlay from sewer
    if map:get_id() == "39" and lantern_overlay then lantern_overlay:fade_out() end
  end
end
