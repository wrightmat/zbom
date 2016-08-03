local map = ...
local game = map:get_game()

if game:get_time_of_day() ~= "night" then
  function map:on_draw(dst_surface)
    if game.deception_fog_overlay ~= nil then game.deception_fog_overlay:draw(dst_surface) end
  end
end