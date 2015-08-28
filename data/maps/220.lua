local map = ...

function map:on_started(destination)
  local surface = sol.surface.create(16, 16)
  surface:fill_color({128, 64, 0, 255})

  local pixels = surface:get_pixels()
  local r, g, b, a = pixels:byte(1, 4)

  sol.timer.start(self, 5000, function()
    a = a - 100
    surface:set_pixels(r, g, b, a)
  end)
end

function map:on_draw(dst_surface)
  if surface ~= nil then surface:draw(dst_surface) end
end