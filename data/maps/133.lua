local map = ...
local game = map:get_game()

function game:on_map_changed(map)
  function map:on_draw(dst_surface)
    -- clear away lantern overlay from sewer
    if map:get_id() == "133" and lantern_overlay then lantern_overlay:fade_out() end
  end
end
