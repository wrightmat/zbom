local map = ...

function game:on_map_changed(map)
  function map:on_draw(dst_surface)
    -- clear away lantern overlay from sewer
    lantern_overlay:fade_out()
  end
end
