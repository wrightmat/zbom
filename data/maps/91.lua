local map = ...
local game = map:get_game()

--------------------------------------------
-- Outside World B4 (Forest of Deception) --
--------------------------------------------

local fog_overlay = nil

if game:get_item("bottle_1"):get_variant() == 9 or -- If hero has a Poe Soul,
   game:get_item("bottle_2"):get_variant() == 9 or -- then it's easier to see.
   game:get_item("bottle_3"):get_variant() == 9 or
   game:get_item("bottle_4"):get_variant() == 9 then
  fog_overlay = sol.surface.create("effects/fog.png")
  fog_overlay:set_opacity(55)
else
  fog_overlay = sol.surface.create("effects/fog.png")
  fog_overlay:set_opacity(128)
end

function map:on_draw(dst_surface)
  if fog_overlay ~= nil then
    fog_overlay:draw(dst_surface)
  end
end

function map:on_finished()
  if fog_overlay then
    fog_overlay:fade_out()
    fog_overlay = nil
  end
end